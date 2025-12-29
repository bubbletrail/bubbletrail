import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:divestore/store/fileio.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../gen/gen.dart';
import '../gen/internal.pb.dart';

class Dives {
  static Dives _instance = Dives._();

  factory Dives() {
    return _instance;
  }

  Dives._() {}

  late final String pathPrefix;
  Map<String, Dive> _dives = {};
  Set<String> _tags = {};
  Set<String> _dirty = {};
  bool _loaded = false;
  Timer? _saveTimer;

  Set<String> get tags => _tags;

  Future<String> insert(Dive dive) async {
    if (!_loaded) await _load();
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
    _scheduleSave(dive.id);
    return dive.id;
  }

  Future<void> insertAll(Iterable<Dive> dives) async {
    if (!_loaded) await _load();
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
    }
    _scheduleSave(null);
  }

  Future<void> update(Dive dive) async {
    if (!_loaded) await _load();
    dive.updatedAt = Timestamp.fromDateTime(DateTime.now());
    _dives[dive.id] = dive;
    _tags.addAll(dive.tags);
    _scheduleSave(dive.id);
  }

  Future<void> delete(String id) async {
    if (!_loaded) await _load();
    _dives[id]?.deletedAt = Timestamp.fromDateTime(DateTime.now());
    _scheduleSave(id);
  }

  Future<Dive?> getById(String id) async {
    if (!_loaded) await _load();
    final dive = _dives[id];
    if (dive == null) return null;
    if (dive.logs.isEmpty) {
      final logs = await _loadLogs(dlName(diveDir(dive), dive));
      dive.logs.addAll(logs);
    }
    return dive;
  }

  Future<List<Dive>> getAll() async {
    if (!_loaded) await _load();
    final dives = _dives.values.where((d) => !d.hasDeletedAt()).toList();
    dives.sort((a, b) => -a.number.compareTo(b.number));
    return dives;
  }

  Future<int> get nextDiveNo async {
    final dives = await getAll();
    final next = dives.fold(0, (n, d) => max(n, d.number));
    return next;
  }

  Future<void> _load() async {
    final dir = await getApplicationDocumentsDirectory();
    pathPrefix = "${dir.path}/dives";
    try {
      await for (final match in Glob("$pathPrefix/*/*.meta.json").list()) {
        Dive dive = await _loadMeta(match.path);
        _dives[dive.id] = dive;
        _tags.addAll(dive.tags);
      }
    } catch (_) {
    } finally {
      _loaded = true;
    }
  }

  Future<Dive> _loadMeta(String path) async {
    final bs = await File(path).readAsString();
    return Dive.create()..mergeFromProto3Json(jsonDecode(bs));
  }

  Future<List<Log>> _loadLogs(String path) async {
    final bs = await File(path).readAsBytes();
    return InternalDiveLogList.fromBuffer(bs).divelogs;
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
        final dlBuf = InternalDiveLogList(divelogs: dive.logs).writeToBuffer();

        final dir = diveDir(dive);
        await Directory(dir).create(recursive: true);

        dive.logs.clear();
        atomicWriteJSON(metaName(dir, dive), dive.toProto3Json());

        atomicWrite(dlName(dir, dive), dlBuf);
      }
      _dirty.clear();
      print("saved dives");
    } catch (e) {
      print("failed to save dives: $e");
    }
  }

  String diveDir(Dive dive) => "$pathPrefix/${DateFormat('yyyy-MM').format(dive.createdAt.toDateTime())}";
  String dlName(String dir, Dive dive) => "$dir/${DateFormat('yyyy-MM-dd').format(dive.createdAt.toDateTime())}-${dive.id}.logs.binpb";
  String metaName(String dir, Dive dive) => "$dir/${DateFormat('yyyy-MM-dd').format(dive.createdAt.toDateTime())}-${dive.id}.meta.json";
}
