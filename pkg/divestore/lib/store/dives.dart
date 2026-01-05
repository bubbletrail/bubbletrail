import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';

import '../dc_convert.dart';
import '../gen/gen.dart';
import '../gen/internal.pb.dart';
import '../gen/log_ext.dart';
import 'fileio.dart';

final _log = Logger('store/dives');

class Dives {
  final String pathPrefix;
  final bool readonly;
  Map<String, Dive> _dives = {};
  Set<String> _tags = {};
  Set<String> _buddies = {};
  Set<String> _dirty = {};
  Timer? _saveTimer;

  Dives(this.pathPrefix, {this.readonly = false});

  Set<String> get tags => _tags;
  Set<String> get buddies => _buddies;

  Future<String> insert(Dive dive) async {
    if (readonly) throw Exception('readonly');
    if (!dive.isFrozen) dive.freeze();
    dive = dive.rebuild((dive) {
      if (!dive.hasId()) {
        dive.id = Uuid().v4().toString();
      }
      dive.updatedAt = Timestamp.fromDateTime(DateTime.now());
      if (!dive.hasCreatedAt()) {
        if (dive.hasStart()) {
          dive.createdAt = dive.start;
        } else if (dive.logs.isNotEmpty) {
          dive.createdAt = dive.logs.first.dateTime;
        } else {
          dive.createdAt = dive.updatedAt;
        }
      }
    });
    _dives[dive.id] = dive;
    _tags.addAll(dive.tags);
    _buddies.addAll(dive.buddies);
    _scheduleSave(dive.id);
    return dive.id;
  }

  Future<void> insertAll(Iterable<Dive> dives) async {
    if (readonly) throw Exception('readonly');
    for (var dive in dives) {
      if (!dive.isFrozen) dive.freeze();
      dive = dive.rebuild((dive) {
        if (!dive.hasId()) {
          dive.id = Uuid().v4().toString();
        }
        dive.updatedAt = Timestamp.fromDateTime(DateTime.now());
        if (!dive.hasCreatedAt()) {
          if (dive.hasStart()) {
            dive.createdAt = dive.start;
          } else if (dive.logs.isNotEmpty) {
            dive.createdAt = dive.logs.first.dateTime;
          } else {
            dive.createdAt = dive.updatedAt;
          }
        }
        for (final (idx, cyl) in dive.cylinders.indexed) {
          dive.cylinders[idx] = cyl.rebuild((cyl) {
            cyl.clearCylinder();
          });
        }
      });
      if (!_dives.containsKey(dive.id)) {
        _dives[dive.id] = dive;
        _dirty.add(dive.id);
      }
      _tags.addAll(dive.tags);
      _buddies.addAll(dive.buddies);
    }
    _scheduleSave(null);
  }

  Future<void> update(Dive dive) async {
    if (readonly) throw Exception('readonly');
    if (!dive.isFrozen) dive.freeze();
    dive = dive.rebuild((dive) {
      dive.updatedAt = Timestamp.fromDateTime(DateTime.now());
      for (final (idx, cyl) in dive.cylinders.indexed) {
        dive.cylinders[idx] = cyl.rebuild((cyl) {
          cyl.clearCylinder();
        });
      }
    });
    _dives[dive.id] = dive;
    _tags.addAll(dive.tags);
    _buddies.addAll(dive.buddies);
    _scheduleSave(dive.id);
  }

  Future<void> _import(Dive dive) async {
    if (readonly) throw Exception('readonly');
    if (!dive.isFrozen) dive.freeze();
    _dives[dive.id] = dive;
    _tags.addAll(dive.tags);
    _buddies.addAll(dive.buddies);
    _scheduleSave(dive.id);
  }

  Future<void> delete(String id) async {
    if (readonly) throw Exception('readonly');
    if (_dives.containsKey(id)) {
      _dives[id] = _dives[id]!.rebuild((dive) {
        dive.deletedAt = Timestamp.fromDateTime(DateTime.now());
      });
    }
    _scheduleSave(id);
  }

  Future<Dive?> getById(String id) async {
    var dive = _dives[id];
    if (dive == null) return null;
    if (dive.logs.isEmpty) {
      final logs = await _loadLogs(dlName(diveDir(dive), dive));
      dive = dive.rebuild((dive) {
        dive.logs.addAll(logs);
      });
    }
    return dive;
  }

  Future<List<Dive>> getAll({bool withDeleted = false}) async {
    final dives = _dives.values.where((d) => withDeleted || !d.hasDeletedAt()).toList();
    dives.sort((a, b) => -a.number.compareTo(b.number));
    return dives;
  }

  Future<int> get nextDiveNo async {
    final dives = await getAll();
    final next = dives.fold(0, (n, d) => max(n, d.number + 1));
    return next;
  }

  Future<void> init() async {
    await for (final match in Glob('$pathPrefix/*/*.meta.binpb').list()) {
      try {
        final dive = await _loadMeta(match.path);
        _dives[dive.id] = dive;
        _tags.addAll(dive.tags);
        _buddies.addAll(dive.buddies);
      } catch (_) {}
    }
  }

  Future<Dive> _loadMeta(String path) async {
    final bs = await File(path).readAsBytes();
    final dive = Dive.fromBuffer(bs);
    dive.freeze();
    return dive;
  }

  Future<List<Log>> _loadLogs(String path) async {
    final bs = await File(path).readAsBytes();
    final ll = InternalLogList.fromBuffer(bs);
    for (final l in ll.logs) {
      l.setUniqueID(); // no-op when already set
    }
    ll.freeze();
    return ll.logs;
  }

  void _scheduleSave(String? id) {
    if (id != null) _dirty.add(id);
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 1), _save);
  }

  Future<void> _save() async {
    try {
      for (final id in _dirty) {
        final dive = _dives[id]!;

        final dir = diveDir(dive);
        await Directory(dir).create(recursive: true);

        await atomicWriteProto(dlName(dir, dive), InternalLogList(logs: dive.logs));

        final metaOnly = dive.rebuild((dive) {
          dive.logs.clear();
        });
        await atomicWriteProto(metaName(dir, dive), metaOnly);
      }

      _log.info('saved ${_dirty.length} dives');
      _dirty.clear();
    } catch (e) {
      _log.warning('failed to save dives: $e');
    }
  }

  Future<Uint8List> mergedDives() async {
    final dl = InternalDiveList();
    for (final id in _dives.keys) {
      final dive = await getById(id);
      if (dive != null) dl.dives.add(dive);
    }
    return dl.writeToBuffer();
  }

  Future<void> importFrom(Dives other) async {
    for (final dive in await other.getAll(withDeleted: true)) {
      final cur = _dives[dive.id];
      if (dive.hasDeletedAt()) {
        if (cur != null) {
          print('delete dive ${dive.id}');
          await delete(dive.id);
        }
      } else if (cur == null || dive.updatedAt.toDateTime().isAfter(cur.updatedAt.toDateTime())) {
        final rdive = await other.getById(dive.id);
        print('import dive ${rdive!.id}');
        await _import(rdive);
      }
    }
  }

  String diveDir(Dive dive) => "$pathPrefix/${DateFormat('yyyy-MM').format(dive.createdAt.toDateTime())}";
  String dlName(String dir, Dive dive) => "$dir/${DateFormat('yyyy-MM-dd').format(dive.createdAt.toDateTime())}.${dive.id}.logs.binpb";
  String metaName(String dir, Dive dive) => "$dir/${DateFormat('yyyy-MM-dd').format(dive.createdAt.toDateTime())}.${dive.id}.meta.binpb";
}
