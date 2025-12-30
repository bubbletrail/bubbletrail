import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:divestore/store/fileio.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';

import '../gen/gen.dart';
import '../gen/internal.pb.dart';

final _log = Logger('store/cylinders');

class Cylinders {
  final String path;
  final bool readonly;

  Map<String, Cylinder> _cylinders = Map();
  Timer? _saveTimer;
  final _changes = StreamController<List<Cylinder>>.broadcast();

  Stream<List<Cylinder>> get changes => _changes.stream;

  Cylinders(this.path, {this.readonly = false});

  Future<Cylinder> insert(Cylinder cylinder) async {
    if (readonly) throw Exception('readonly');
    if (!cylinder.isFrozen) cylinder.freeze();
    cylinder = cylinder.rebuild((cylinder) {
      if (!cylinder.hasId()) {
        cylinder.id = Uuid().v4().toString();
      }
      cylinder.updatedAt = Timestamp.fromDateTime(DateTime.now());
      if (!cylinder.hasCreatedAt()) {
        cylinder.createdAt = cylinder.updatedAt;
      }
    });
    if (!_cylinders.containsKey(cylinder.id)) {
      _cylinders[cylinder.id] = cylinder;
      _scheduleSave();
    }
    return cylinder;
  }

  Future<void> update(Cylinder cylinder) async {
    if (readonly) throw Exception('readonly');
    if (!cylinder.isFrozen) cylinder.freeze();
    cylinder = cylinder.rebuild((cylinder) {
      cylinder.updatedAt = Timestamp.fromDateTime(DateTime.now());
      if (!cylinder.hasCreatedAt()) {
        cylinder.createdAt = cylinder.updatedAt;
      }
    });
    _cylinders[cylinder.id] = cylinder;
    _scheduleSave();
  }

  Future<void> _import(Cylinder cylinder) async {
    if (readonly) throw Exception('readonly');
    if (!cylinder.isFrozen) cylinder.freeze();
    _cylinders[cylinder.id] = cylinder;
    _scheduleSave();
  }

  Future<void> delete(String id) async {
    if (readonly) throw Exception('readonly');
    if (_cylinders.containsKey(id)) {
      _cylinders[id] = _cylinders[id]!.rebuild((cylinder) {
        cylinder.deletedAt = Timestamp.fromDateTime(DateTime.now());
      });
    }
    _scheduleSave();
  }

  Future<Cylinder?> getById(String id) async {
    return _cylinders[id];
  }

  Future<List<Cylinder>> getAll() async {
    final vals = _cylinders.values.where((c) => !c.hasDeletedAt()).toList();
    vals.sort((a, b) => a.description.compareTo(b.description));
    return vals;
  }

  Future<Cylinder?> findByProperties(double? size, double? workpressure, String? description) async {
    return _cylinders.values.firstWhereOrNull((c) {
      if (c.hasDeletedAt()) return false;
      if (size != null && size != c.size) return false;
      if (workpressure != null && workpressure != c.workpressure) return false;
      if (description != null && description != c.description) return false;
      return true;
    });
  }

  Future<Cylinder> getOrCreate(double? size, double? workpressure, String? description) async {
    if (readonly) throw Exception('readonly');
    final existing = await findByProperties(size, workpressure, description);
    if (existing != null) return existing;

    final c = Cylinder(size: size, workpressure: workpressure, description: description);
    return await insert(c);
  }

  Future<void> init() async {
    try {
      final bs = await File(path).readAsBytes();
      final cl = InternalCylinderList.fromBuffer(bs);
      cl.freeze();
      for (final c in cl.cylinders) {
        _cylinders[c.id] = c;
      }
    } catch (_) {}
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 1), _save);
  }

  Future<void> _save() async {
    try {
      final vals = _cylinders.values.toList();
      vals.sort((a, b) => a.description.compareTo(b.description));
      final cl = InternalCylinderList(cylinders: vals);
      atomicWriteProto(path, cl);
      _changes.add(vals);
      _log.info('saved ${_cylinders.length} cylinders');
    } catch (e) {
      _log.warning("failed to save cylinders: $e");
    }
  }

  Future<void> importFrom(Cylinders other) async {
    for (final cyl in await other.getAll()) {
      final cur = _cylinders[cyl.id];
      if (cyl.hasDeletedAt()) {
        if (cur != null) {
          print('delete cylinder ${cyl.id}');
          await delete(cyl.id);
        }
      } else if (cur == null || cyl.updatedAt.toDateTime().isAfter(cur.updatedAt.toDateTime())) {
        print('import cylinder ${cyl.id}');
        await _import(cyl);
      }
    }
  }
}
