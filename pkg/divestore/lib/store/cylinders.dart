import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../divestore.dart';
import '../gen/internal.pb.dart';
import 'fileio.dart';

final _log = Logger('store/cylinders.dart');

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
      cylinder.meta = cylinder.meta.rebuildUpdated();
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
      cylinder.meta = cylinder.meta.rebuildUpdated();
    });
    _cylinders[cylinder.id] = cylinder;
    _scheduleSave();
  }

  Future<void> delete(String id) async {
    if (readonly) throw Exception('readonly');
    if (_cylinders.containsKey(id)) {
      _cylinders[id] = _cylinders[id]!.rebuild((cylinder) {
        cylinder.meta = cylinder.meta.rebuildDeleted();
      });
    }
    _scheduleSave();
  }

  Future<Cylinder?> getById(String id) async {
    return _cylinders[id];
  }

  Future<List<Cylinder>> getAll({bool withDeleted = false}) async {
    final vals = _cylinders.values.where((c) => withDeleted || !c.meta.isDeleted).toList();
    vals.sort((a, b) => a.description.compareTo(b.description));
    return vals;
  }

  Future<Cylinder?> findByProperties(double? volumeL, double? workingPressureBar, String? description) async {
    return _cylinders.values.firstWhereOrNull((c) {
      if (c.meta.isDeleted) return false;
      if (volumeL != null && volumeL != c.volumeL) return false;
      if (workingPressureBar != null && workingPressureBar != c.workingPressureBar) return false;
      if (description != null && description != c.description) return false;
      return true;
    });
  }

  Future<Cylinder> getOrCreate(double? size, double? workpressure, String? description) async {
    if (readonly) throw Exception('readonly');
    final existing = await findByProperties(size, workpressure, description);
    if (existing != null) return existing;

    final c = Cylinder(volumeL: size, workingPressureBar: workpressure, description: description);
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
      await atomicWriteProto(path, cl);
      _changes.add(vals);
      _log.info('saved ${_cylinders.length} cylinders');
    } catch (e) {
      _log.warning('failed to save cylinders', e);
    }
  }

  Future<void> syncWith(SyncProvider provider) async {
    // Get all cylinders, merge with the list.
    _log.fine('syncing cylinders');
    try {
      final obj = await provider.getObject('cylinders');
      final cls = InternalCylinderList.fromBuffer(obj);
      cls.freeze();
      _log.fine('got ${cls.cylinders.length} cylinders from provider');
      for (final cyl in cls.cylinders) {
        final cur = _cylinders[cyl.id];
        if (cyl.meta.isDeleted) {
          if (cur != null) {
            _log.fine('deleting cylinder ${cyl.id}');
            await delete(cyl.id);
          }
        } else if (cur == null || cyl.meta.isAfter(cur.meta)) {
          _log.fine('importing cylinder ${cyl.id}');
          _cylinders[cyl.id] = cyl;
        }
      }
    } catch (e) {
      _log.warning('failed to load cylinders', e);
    }

    // Upload the new merged set.
    final vals = _cylinders.values.toList();
    _log.fine('updating ${vals.length} cylinders in sync provider');
    final cl = InternalCylinderList(cylinders: vals);
    final bs = cl.writeToBuffer();
    await provider.putObject('cylinders', bs);

    _scheduleSave();
  }
}
