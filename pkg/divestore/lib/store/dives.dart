import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:divestore/store/fileio.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';

import '../gen/gen.dart';
import '../gen/internal.pb.dart';

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
    _dives[dive.id] = dive;
    _tags.addAll(dive.tags);
    _buddies.addAll(dive.buddies);
    _scheduleSave(dive.id);
    return dive.id;
  }

  Future<void> insertAll(Iterable<Dive> dives) async {
    if (readonly) throw Exception('readonly');
    for (final dive in dives) {
      if (!dive.hasId()) {
        dive.id = Uuid().v4().toString();
      }
      if (!_dives.containsKey(dive.id)) {
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
    dive.updatedAt = Timestamp.fromDateTime(DateTime.now());
    _dives[dive.id] = dive;
    _tags.addAll(dive.tags);
    _buddies.addAll(dive.buddies);
    _scheduleSave(dive.id);
  }

  Future<void> _import(Dive dive) async {
    if (readonly) throw Exception('readonly');
    _dives[dive.id] = dive;
    _tags.addAll(dive.tags);
    _buddies.addAll(dive.buddies);
    _scheduleSave(dive.id);
  }

  Future<void> delete(String id) async {
    if (readonly) throw Exception('readonly');
    _dives[id]?.deletedAt = Timestamp.fromDateTime(DateTime.now());
    _scheduleSave(id);
  }

  Future<Dive?> getById(String id) async {
    final dive = _dives[id];
    if (dive == null) return null;
    if (dive.logs.isEmpty) {
      final logs = await _loadLogs(dlName(diveDir(dive), dive));
      dive.logs.addAll(logs);
    }
    return dive;
  }

  Future<List<Dive>> getAll() async {
    final dives = _dives.values.where((d) => !d.hasDeletedAt()).toList();
    dives.sort((a, b) => -a.number.compareTo(b.number));
    return dives;
  }

  Future<int> get nextDiveNo async {
    final dives = await getAll();
    final next = dives.fold(0, (n, d) => max(n, d.number + 1));
    return next;
  }

  Future<void> init() async {
    await for (final match in Glob("$pathPrefix/*/*.meta.binpb").list()) {
      try {
        Dive dive = await _loadMeta(match.path);
        _dives[dive.id] = dive;
        _tags.addAll(dive.tags);
        _buddies.addAll(dive.buddies);
      } catch (_) {}
    }
  }

  Future<Dive> _loadMeta(String path) async {
    final bs = await File(path).readAsBytes();
    return Dive.fromBuffer(bs);
  }

  Future<List<Log>> _loadLogs(String path) async {
    final bs = await File(path).readAsBytes();
    return InternalLogList.fromBuffer(bs).logs;
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

        atomicWriteProto(dlName(dir, dive), InternalLogList(logs: dive.logs));

        dive.logs.clear();
        atomicWriteProto(metaName(dir, dive), dive);
      }

      _log.info("saved ${_dirty.length} dives");
      _dirty.clear();
    } catch (e) {
      _log.warning("failed to save dives: $e");
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
    for (final dive in await other.getAll()) {
      final cur = _dives[dive.id];
      if (dive.hasDeletedAt()) {
        if (cur != null) {
          print("delete dive ${dive.id}");
          await delete(dive.id);
        }
      } else if (cur == null || dive.updatedAt.toDateTime().isAfter(cur.updatedAt.toDateTime())) {
        final rdive = await other.getById(dive.id);
        print("import dive ${rdive!.id}");
        await _import(rdive);
      }
    }
  }

  String diveDir(Dive dive) => "$pathPrefix/${DateFormat('yyyy-MM').format(dive.createdAt.toDateTime())}";
  String dlName(String dir, Dive dive) => "$dir/${DateFormat('yyyy-MM-dd').format(dive.createdAt.toDateTime())}.${dive.id}.logs.binpb";
  String metaName(String dir, Dive dive) => "$dir/${DateFormat('yyyy-MM-dd').format(dive.createdAt.toDateTime())}.${dive.id}.meta.binpb";
}
