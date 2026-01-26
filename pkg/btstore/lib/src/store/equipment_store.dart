import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import '../gen/gen.dart';
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
  int compare(Equipment a, Equipment b) => '${a.type} ${a.manufacturer} ${a.name}'.compareTo('${b.type} ${b.manufacturer} ${b.name}');

  // Equipment-specific methods

  Future<Equipment?> findByProperties({required String type, required String manufacturer, required String name, required String serial}) async {
    final all = await getAll();
    return all.firstWhereOrNull((e) {
      return e.type == type && e.manufacturer == manufacturer && e.name == name && e.serial == serial;
    });
  }

  // Get existing equipment by properties or create new. Matches on type,
  // manufacturer, name, serial. Updates the other fields if non-null.
  Future<Equipment> getOrCreate({
    required String type,
    required String manufacturer,
    required String name,
    required String serial,
    double? weight,
    Timestamp? purchaseDate,
    double? purchasePrice,
    String? shop,
    Timestamp? warrantyUntil,
    Timestamp? lastService,
  }) async {
    var eq = await findByProperties(type: type, manufacturer: manufacturer, name: name, serial: serial);
    if (eq == null) {
      eq = Equipment(type: type, manufacturer: manufacturer, name: name, serial: serial)..freeze();
    }
    eq = eq.rebuild((eq) {
      if (weight != null) eq.weight = weight;
      if (purchaseDate != null) eq.purchaseDate = purchaseDate;
      if (purchasePrice != null) eq.purchasePrice = purchasePrice;
      if (shop != null) eq.shop = shop;
      if (warrantyUntil != null) eq.warrantyUntil = warrantyUntil;
      if (lastService != null) eq.lastService = lastService;
    });
    return await update(eq);
  }
}
