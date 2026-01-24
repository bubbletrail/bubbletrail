import 'package:logging/logging.dart';

import '../btstore.dart';
import '../gen/internal.pb.dart';
import 'entity_store.dart';

final _log = Logger('equipment_store.dart');

class EquipmentStore extends EntityStore<Equipment, InternalEquipmentList> {
  EquipmentStore(String path) : super(path, syncKey: 'equipments', entityName: 'equipments', log: _log);

  @override
  String getId(Equipment entity) => entity.id;

  @override
  bool hasId(Equipment entity) => entity.id.isNotEmpty;

  @override
  Metadata getMeta(Equipment entity) => entity.meta;

  @override
  Equipment rebuildEntity(Equipment entity, {String? id, Metadata? meta}) {
    return entity.rebuild((b) {
      if (id != null) b.id = id;
      if (meta != null) b.meta = meta;
    });
  }

  @override
  InternalEquipmentList createList(Iterable<Equipment> entities) => InternalEquipmentList(equipments: entities.toList());

  @override
  Iterable<Equipment> entitiesFromList(InternalEquipmentList list) => list.equipments;

  @override
  InternalEquipmentList listFromBuffer(List<int> bytes) => InternalEquipmentList.fromBuffer(bytes);

  @override
  int compare(Equipment a, Equipment b) => '${a.manufacturer} ${a.name}'.compareTo('${b.manufacturer} ${b.name}');
}
