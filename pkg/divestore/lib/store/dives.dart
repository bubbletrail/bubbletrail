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

import '../divestore.dart';
import '../gen/internal.pb.dart';
import 'fileio.dart';

final _log = Logger('store/dives.dart');

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
        dive.clearSyncedEtag();
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
      dive.clearSyncedEtag();
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
    dive = dive.rebuild((dive) {
      dive.tags.sort((a, b) => a.compareTo(b));
      dive.events.sort((a, b) => a.time.compareTo(b.time));
    });
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
      } catch (_) {}
    }
    _rebuildTags();
  }

  void _rebuildTags() {
    _buddies.clear();
    _tags.clear();
    for (final dive in _dives.values) {
      if (dive.hasDeletedAt()) continue;
      _buddies.addAll(dive.buddies);
      _tags.addAll(dive.tags);
    }
  }

  Future<Dive> _loadMeta(String path) async {
    final bs = await File(path).readAsBytes();
    final dive = Dive.fromBuffer(bs);
    dive.freeze();
    return dive;
  }

  Future<List<Log>> _loadLogs(String path) async {
    try {
      final bs = await File(path).readAsBytes();
      final ll = InternalLogList.fromBuffer(bs);
      for (final l in ll.logs) {
        l.setUniqueID(); // no-op when already set
      }
      ll.freeze();
      return ll.logs;
    } catch (_) {
      return [];
    }
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

        if (dive.logs.isNotEmpty) {
          await atomicWriteProto(dlName(dir, dive), InternalLogList(logs: dive.logs));
        }

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

  Future<void> syncWith(SyncProvider provider) async {
    _log.fine('syncing dives');
    final seenEtags = <String, String>{}; // dive ID -> eTag
    await for (final obj in provider.listObjects()) {
      if (!obj.key.startsWith('dive-')) {
        // Not a dive
        continue;
      }

      final id = obj.key.replaceFirst('dive-', '');
      seenEtags[id] = obj.eTag;

      final cur = _dives[id];
      if (cur != null && cur.syncedEtag == obj.eTag) {
        // Identical, no change required
        continue;
      }

      // Load the dive
      final data = await provider.getObject(obj.key);
      final dive = Dive.fromBuffer(data);
      if (dive.id != id) {
        _log.warning('bug: object with id $id contained unexpected dive ${dive.id}');
        continue;
      }
      dive.syncedEtag = obj.eTag;
      dive.freeze();

      // If it's newer, replace our dive.
      if (cur == null || dive.updatedAt.toDateTime().isAfter(cur.updatedAt.toDateTime()) || dive.deletedAt.toDateTime().isAfter(cur.deletedAt.toDateTime())) {
        _log.fine('updating dive ${id} from provider');
        _dives[id] = dive;
        _scheduleSave(id);
      }
    }

    // Upload all dives with mismatched eTags. This will include the dives
    // we didn't import above because they were older than what we had.
    for (final dive in _dives.values) {
      if (seenEtags[dive.id] == dive.syncedEtag) continue;
      _log.fine('updating dive ${dive.id} in sync provider');
      final fullDive = await getById(dive.id);
      final data = fullDive!.rebuild((dive) {
        dive.clearSyncedEtag();
      }).writeToBuffer();
      final etag = await provider.putObject('dive-${dive.id}', data);
      _dives[dive.id] = dive.rebuild((dive) {
        dive.syncedEtag = etag;
      });
      _scheduleSave(dive.id);
    }

    _rebuildTags();
  }

  String diveDir(Dive dive) => "$pathPrefix/${DateFormat('yyyy-MM').format(dive.createdAt.toDateTime())}";
  String dlName(String dir, Dive dive) => "$dir/${DateFormat('yyyy-MM-dd').format(dive.createdAt.toDateTime())}.${dive.id}.logs.binpb";
  String metaName(String dir, Dive dive) => "$dir/${DateFormat('yyyy-MM-dd').format(dive.createdAt.toDateTime())}.${dive.id}.meta.binpb";
}
