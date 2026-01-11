import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'gen.dart';

Metadata newMetadata() {
  final dt = Timestamp.fromDateTime(DateTime.now());
  return Metadata(createdAt: dt, updatedAt: dt);
}

extension MetadataExtension on Metadata {
  bool get isDeleted => hasDeletedAt();

  bool isAfter(Metadata other) {
    return this.updatedAt.toDateTime().isAfter(other.updatedAt.toDateTime()) || this.deletedAt.toDateTime().isAfter(other.deletedAt.toDateTime());
  }

  Metadata rebuildUpdated() {
    return this.rebuild((meta) {
      meta.updatedAt = .fromDateTime(DateTime.now());
      if (!meta.hasCreatedAt()) meta.createdAt = meta.updatedAt;
      meta.clearDeletedAt();
    });
  }

  Metadata rebuildDeleted() {
    return this.rebuild((meta) {
      meta.deletedAt = .fromDateTime(DateTime.now());
      if (!meta.hasCreatedAt()) meta.deletedAt = meta.updatedAt;
    });
  }
}
