import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'package:btproto/btproto.dart';

Metadata newMetadata() {
  final dt = Timestamp.fromDateTime(DateTime.now());
  return Metadata(createdAt: dt, updatedAt: dt);
}

extension MetadataExtension on Metadata {
  bool get isDeleted => hasDeletedAt();

  bool isAfter(Metadata other) {
    return updatedAt.toDateTime().isAfter(other.updatedAt.toDateTime()) ||
        (deletedAt.toDateTime().isAfter(other.deletedAt.toDateTime()) && deletedAt.toDateTime().isAfter(other.updatedAt.toDateTime()));
  }

  Metadata rebuildUpdated() {
    return rebuild((meta) {
      meta.updatedAt = .fromDateTime(DateTime.now());
      if (!meta.hasCreatedAt()) meta.createdAt = meta.updatedAt;
      meta.clearDeletedAt();
    });
  }

  Metadata rebuildDeleted() {
    return rebuild((meta) {
      meta.deletedAt = .fromDateTime(DateTime.now());
      if (!meta.hasCreatedAt()) meta.deletedAt = meta.updatedAt;
    });
  }
}
