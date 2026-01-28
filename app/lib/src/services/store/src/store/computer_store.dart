import 'package:btproto/btproto.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as proto;

import '../ext/ext.dart';
import 'entity_store.dart';

final _log = Logger('computer_store.dart');

class ComputerStore extends EntityStore<Computer, InternalComputerList> {
  ComputerStore(super.path) : super(syncKey: 'computers', entityName: 'computers', log: _log);

  @override
  String getId(Computer entity) => entity.remoteId;

  @override
  bool hasId(Computer entity) => entity.remoteId.isNotEmpty;

  @override
  Metadata getMeta(Computer entity) => entity.meta;

  @override
  Computer rebuildEntity(Computer entity, {String? id, Metadata? meta}) {
    return entity.rebuild((b) {
      if (id != null) b.remoteId = id;
      if (meta != null) b.meta = meta;
    });
  }

  @override
  Computer rebuildDeleted(Computer entity) {
    return entity.rebuild((b) {
      b.meta = getMeta(entity).rebuildDeleted();
      b.clearLastLogDate();
      b.clearLdcFingerprint();
    });
  }

  @override
  InternalComputerList createList(Iterable<Computer> entities) => InternalComputerList(computers: entities);

  @override
  Iterable<Computer> entitiesFromList(InternalComputerList list) => list.computers;

  @override
  InternalComputerList listFromBuffer(List<int> bytes) => InternalComputerList.fromBuffer(bytes);

  @override
  int compare(Computer a, Computer b) {
    final vendorCmp = a.vendor.compareTo(b.vendor);
    if (vendorCmp != 0) return vendorCmp;
    return a.product.compareTo(b.product);
  }

  Future<void> updateFields({
    required String remoteId,
    String? advertisedName,
    String? vendor,
    String? product,
    List<int>? ldcFingerprint,
    String? serial,
    DateTime? lastLogDate,
  }) async {
    var computer = await getById(remoteId);
    computer ??= Computer(remoteId: remoteId, meta: newMetadata())..freeze();
    computer = computer.rebuild((b) {
      if (advertisedName != null) b.advertisedName = advertisedName;
      if (vendor != null) b.vendor = vendor;
      if (product != null) b.product = product;
      if (ldcFingerprint != null) b.ldcFingerprint = ldcFingerprint;
      if (serial != null) b.serial = serial;
      if (lastLogDate != null) b.lastLogDate = proto.Timestamp.fromDateTime(lastLogDate);
    });
    await update(computer);
  }

  Future<Computer?> getByRemoteId(String remoteId) => getById(remoteId);
}
