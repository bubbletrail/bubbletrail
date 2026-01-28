import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';

import '../../btstore.dart';
import '../gen/internal.pb.dart';
import 'fileio.dart';

final _log = Logger('dive_store.dart');

class DiveStore with ChangeNotifier {
  final String pathPrefix;
  Map<String, Dive> _dives = {};
  Set<String> _tags = {};
  Set<String> _buddies = {};
  Set<String> _dirty = {};
  Timer? _saveTimer;

  DiveStore(this.pathPrefix);

  Set<String> get tags => _tags;
  Set<String> get buddies => _buddies;

  Future<void> insertAll(Iterable<Dive> dives) async {
    for (var dive in dives) {
      if (!dive.isFrozen) dive.freeze();
      dive = dive.rebuild((dive) {
        dive.clearSyncedEtag();
        if (!dive.hasId()) {
          dive.id = Uuid().v4().toString();
        }
        dive.meta = dive.meta.rebuild((meta) {
          meta.updatedAt = Timestamp.fromDateTime(DateTime.now());
          if (!meta.hasCreatedAt()) {
            if (dive.hasStart()) {
              meta.createdAt = dive.start;
            } else if (dive.logs.isNotEmpty) {
              meta.createdAt = dive.logs.first.dateTime;
            } else {
              meta.createdAt = meta.updatedAt;
            }
          }
          meta.clearDeletedAt();
        });
        for (final (idx, cyl) in dive.cylinders.indexed) {
          dive.cylinders[idx] = cyl.rebuild((cyl) {
            cyl.clearCylinder();
          });
        }
      });
      _dives[dive.id] = dive;
      _dirty.add(dive.id);
      _tags.addAll(dive.tags);
      _buddies.addAll(dive.buddies);
    }
    _scheduleSave(null);
    notifyListeners();
  }

  Future<void> update(Dive dive) async {
    if (!dive.isFrozen) dive.freeze();
    dive = dive.rebuild((dive) {
      if (dive.id.isEmpty) {
        dive.id = Uuid().v4().toString();
      }
      dive.meta = dive.meta.rebuildUpdated();
      dive.clearSyncedEtag();
    });
    _dives[dive.id] = dive;
    _tags.addAll(dive.tags);
    _buddies.addAll(dive.buddies);
    _scheduleSave(dive.id);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    if (_dives.containsKey(id)) {
      _dives[id] = _dives[id]!.rebuild((dive) {
        dive.meta = dive.meta.rebuildDeleted();
        dive.clearSyncedEtag();
      });
    }
    _scheduleSave(id);
    notifyListeners();
  }

  @internal
  Future<Dive?> getById(String id) async {
    var dive = _dives[id];
    if (dive == null) {
      _log.fine('get of nonexistant dive $id');
      return null;
    }
    if (dive.logs.isEmpty) {
      final logs = await _loadLogs(_dlName(_diveDir(dive), dive));
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
    final dives = _dives.values.where((d) => withDeleted || !d.meta.isDeleted).toList();
    dives.sort((a, b) => -a.number.compareTo(b.number));
    return dives;
  }

  Future<int> get nextDiveNo async {
    final dives = await getAll();
    final next = dives.fold(1, (n, d) => max(n, d.number + 1));
    return next;
  }

  @internal
  Future<void> init() async {
    _dives.clear();
    _tags.clear();
    _buddies.clear();
    _dirty.clear();
    _saveTimer?.cancel();
    await for (final match in Glob('$pathPrefix/*/*.meta.binpb').list()) {
      try {
        final dive = await _loadMeta(match.path);
        if (dive.id == '') {
          _log.warning('loaded invalid dive with missing ID, deleting ${match.basename}');
          await match.delete();
          continue;
        }
        _dives[dive.id] = dive;
      } catch (e) {
        _log.warning('failed to load dive, deleting ${match.basename}', e);
        await match.delete();
      }
    }
    _rebuildTags();
    notifyListeners();
  }

  void _rebuildTags() {
    _buddies.clear();
    _tags.clear();
    for (final dive in _dives.values) {
      if (dive.meta.isDeleted) continue;
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
    } catch (e) {
      _log.warning('failed to load logs', e);
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

        final dir = _diveDir(dive);
        await Directory(dir).create(recursive: true);

        if (dive.logs.isNotEmpty) {
          await atomicWriteProto(_dlName(dir, dive), InternalLogList(logs: dive.logs));
        }

        final metaOnly = dive.rebuild((dive) {
          dive.logs.clear();
          // Clear cylinder data from cylinder list (retaining only the referencing ID)
          for (final (idx, cyl) in dive.cylinders.indexed) {
            dive.cylinders[idx] = cyl.rebuild((cyl) {
              cyl.clearCylinder();
            });
          }
          // Clear equipment data, retaining only the referencing ID
          for (final (idx, eq) in dive.equipment.indexed) {
            dive.equipment[idx] = Equipment(id: eq.id);
          }
        });
        await atomicWriteProto(_metaName(dir, dive), metaOnly);
      }

      _log.info('saved ${_dirty.length} dives');
      _dirty.clear();
    } catch (e) {
      _log.warning('failed to save dives', e);
    }
  }

  @internal
  Future<void> syncWith(SyncProvider provider) async {
    _log.fine('syncing dives');
    final seenEtags = <String, String>{}; // dive ID -> eTag
    await for (final obj in provider.listObjects()) {
      if (!obj.key.startsWith('dive-')) {
        // Not a dive
        continue;
      }

      final id = obj.key.replaceFirst('dive-', '');
      if (id == '') {
        _log.warning('bug: object ${obj.key} has blank ID; deleting');
        await provider.deleteObject(obj.key);
        continue;
      }
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
        _log.warning('bug: object ${obj.key} contained unexpected dive ${dive.id}; deleting');
        await provider.deleteObject(obj.key);
        continue;
      }
      dive.syncedEtag = obj.eTag;
      dive.freeze();

      // If it's newer, replace our dive.
      if (cur == null || dive.meta.isAfter(cur.meta)) {
        _log.fine('updating dive ${id} from provider');
        _dives[id] = dive;
        _scheduleSave(id);
        notifyListeners();
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

  String _diveDir(Dive dive) => "$pathPrefix/${DateFormat('yyyy-MM').format(dive.meta.createdAt.toDateTime())}";

  String _dlName(String dir, Dive dive) => "$dir/${DateFormat('yyyy-MM-dd').format(dive.meta.createdAt.toDateTime())}.${dive.id}.logs.binpb";

  String _metaName(String dir, Dive dive) => "$dir/${DateFormat('yyyy-MM-dd').format(dive.meta.createdAt.toDateTime())}.${dive.id}.meta.binpb";
}
