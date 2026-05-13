import 'package:btproto/btproto.dart';
import 'package:logging/logging.dart';

import 'entity_store.dart';

final _log = Logger('certification_store.dart');

class CertificationStore extends EntityStore<Certification, InternalCertificationList> {
  CertificationStore(super.path) : super(syncKey: 'certifications', entityName: 'certifications', log: _log);

  @override
  String getId(Certification entity) => entity.id;

  @override
  bool hasId(Certification entity) => entity.id.isNotEmpty;

  @override
  Metadata getMeta(Certification entity) => entity.meta;

  @override
  Certification rebuildEntity(Certification entity, {String? id, Metadata? meta}) {
    return entity.rebuild((b) {
      if (id != null) b.id = id;
      if (meta != null) b.meta = meta;
    });
  }

  @override
  InternalCertificationList createList(Iterable<Certification> entities) => InternalCertificationList(certifications: entities.toList());

  @override
  Iterable<Certification> entitiesFromList(InternalCertificationList list) => list.certifications;

  @override
  InternalCertificationList listFromBuffer(List<int> bytes) => InternalCertificationList.fromBuffer(bytes);

  @override
  int compare(Certification a, Certification b) => '${a.agency} ${a.certificationName}'.compareTo('${b.agency} ${b.certificationName}');
}
