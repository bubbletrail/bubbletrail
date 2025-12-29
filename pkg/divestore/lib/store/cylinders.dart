import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:divestore/store/fileio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';

import '../gen/gen.dart';
import '../gen/internal.pb.dart';

class Cylinders {
  static Cylinders _instance = Cylinders._();

  factory Cylinders() {
    return _instance;
  }

  Cylinders._() {}

  late final String path;
  Map<String, Cylinder> _cylinders = Map();
  bool _loaded = false;
  Timer? _saveTimer;

  Future<String> insert(Cylinder cylinder) async {
    if (!_loaded) await _load();
    if (!cylinder.hasId()) {
      cylinder.id = Uuid().v4().toString();
    }
    if (!_cylinders.containsKey(cylinder.id)) {
      cylinder.updatedAt = Timestamp.fromDateTime(DateTime.now());
      if (!cylinder.hasCreatedAt()) {
        cylinder.createdAt = cylinder.updatedAt;
      }
      _cylinders[cylinder.id] = cylinder;
      _scheduleSave();
    }
    return cylinder.id;
  }

  Future<void> update(Cylinder cylinder) async {
    if (!_loaded) await _load();
    cylinder.updatedAt = Timestamp.fromDateTime(DateTime.now());
    if (!cylinder.hasCreatedAt()) {
      cylinder.createdAt = cylinder.updatedAt;
    }
    _cylinders[cylinder.id] = cylinder;
    _scheduleSave();
  }

  Future<void> delete(String id) async {
    if (!_loaded) await _load();
    _cylinders[id]?.deletedAt = Timestamp.fromDateTime(DateTime.now());
    _scheduleSave();
  }

  Future<Cylinder?> getById(String id) async {
    if (!_loaded) await _load();
    return _cylinders[id];
  }

  Future<List<Cylinder>> getAll() async {
    if (!_loaded) await _load();
    return _cylinders.values.where((c) => !c.hasDeletedAt()).toList();
  }

  Future<Cylinder?> findByProperties(double? size, double? workpressure, String? description) async {
    if (!_loaded) await _load();
    return _cylinders.values.firstWhereOrNull((c) {
      if (c.hasDeletedAt()) return false;
      if (size != null && size != c.size) return false;
      if (workpressure != null && workpressure != c.workpressure) return false;
      if (description != null && description != c.description) return false;
      return true;
    });
  }

  Future<Cylinder> getOrCreate(double? size, double? workpressure, String? description) async {
    if (!_loaded) await _load();
    final existing = await findByProperties(size, workpressure, description);
    if (existing != null) return existing;

    final c = Cylinder(size: size, workpressure: workpressure, description: description);
    c.id = await insert(c);
    return c;
  }

  Future<void> _load() async {
    final dir = await getApplicationDocumentsDirectory();
    path = "${dir.path}/cylinders.json";
    try {
      final bs = await File(path).readAsString();
      final cl = InternalCylinderList.create()..mergeFromProto3Json(jsonDecode(bs));
      for (final c in cl.cylinders) {
        _cylinders[c.id] = c;
      }
    } catch (_) {
    } finally {
      _loaded = true;
    }
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 1), _save);
  }

  Future<void> _save() async {
    try {
      final cl = InternalCylinderList(cylinders: _cylinders.values);
      atomicWriteJSON(path, cl.toProto3Json());
    } catch (e) {
      print("failed to save cylinders: $e");
    }
  }
}
