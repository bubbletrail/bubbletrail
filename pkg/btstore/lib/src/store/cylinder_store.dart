import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

import '../../btstore.dart';
import '../gen/internal.pb.dart';
import 'entity_store.dart';

final _log = Logger('cylinder_store.dart');

class CylinderStore extends EntityStore<Cylinder, InternalCylinderList> {
  CylinderStore(String path) : super(path, syncKey: 'cylinders', entityName: 'cylinders', log: _log);

  @override
  String getId(Cylinder entity) => entity.id;

  @override
  bool hasId(Cylinder entity) => entity.id.isNotEmpty;

  @override
  Metadata getMeta(Cylinder entity) => entity.meta;

  @override
  Cylinder rebuildEntity(Cylinder entity, {String? id, Metadata? meta}) {
    return entity.rebuild((b) {
      if (id != null) b.id = id;
      if (meta != null) b.meta = meta;
    });
  }

  @override
  InternalCylinderList createList(Iterable<Cylinder> entities) => InternalCylinderList(cylinders: entities.toList());

  @override
  Iterable<Cylinder> entitiesFromList(InternalCylinderList list) => list.cylinders;

  @override
  InternalCylinderList listFromBuffer(List<int> bytes) => InternalCylinderList.fromBuffer(bytes);

  @override
  int compare(Cylinder a, Cylinder b) => a.description.compareTo(b.description);

  // Cylinder-specific methods

  Future<Cylinder?> findByProperties(double? volumeL, double? workingPressureBar, String? description) async {
    final all = await getAll();
    return all.firstWhereOrNull((c) {
      if (volumeL != null && volumeL != c.volumeL) return false;
      if (workingPressureBar != null && workingPressureBar != c.workingPressureBar) return false;
      if (description != null && description != c.description) return false;
      return true;
    });
  }

  Future<Cylinder> getOrCreate(double? size, double? workpressure, String? description) async {
    final existing = await findByProperties(size, workpressure, description);
    if (existing != null) return existing;

    final c = Cylinder(volumeL: size, workingPressureBar: workpressure, description: description);
    return await update(c);
  }

  Future<Cylinder?> getDefaultForBackgas() async {
    final all = await getAll();
    return all.firstWhereOrNull((c) => c.defaultForBackgas);
  }

  Future<Cylinder?> getDefaultForDeepDeco() async {
    final all = await getAll();
    return all.firstWhereOrNull((c) => c.defaultForDeepDeco);
  }

  Future<Cylinder?> getDefaultForShallowDeco() async {
    final all = await getAll();
    return all.firstWhereOrNull((c) => c.defaultForShallowDeco);
  }
}
