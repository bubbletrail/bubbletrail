import 'dart:async';
import 'dart:typed_data';

class SyncObject {
  final String key;
  final DateTime updatedAt;
  final String eTag;

  const SyncObject(this.key, this.updatedAt, this.eTag);
}

abstract class SyncProvider {
  Stream<SyncObject> listObjects();
  Future<Uint8List> getObject(String key);
  Future<String> putObject(String key, Uint8List data);
  Future<void> deleteObject(String key);
}
