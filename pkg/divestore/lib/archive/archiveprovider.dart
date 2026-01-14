import 'dart:typed_data';

class ArchiveObject {
  final String key;
  final Uint8List data;

  const ArchiveObject(this.key, this.data);
}

abstract class ArchiveImportProvider {
  Stream<ArchiveObject> readObjects();
}

abstract class ArchiveExportProvider {
  Future<void> writeObjects(Stream<ArchiveObject> objects);
}
