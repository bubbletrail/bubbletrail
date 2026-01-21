import 'package:chunked_stream/chunked_stream.dart';
import 'package:divestore/divestore.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:minio/minio.dart';

import 'encryption_provider.dart';

final _log = Logger('s3_provider.dart');

class S3SyncProvider extends SyncProvider {
  final Minio _minio;
  final String _bucket;
  final EncryptionProvider _enc;

  S3SyncProvider({
    required String vaultKey,
    required String endpoint,
    required String bucket,
    required String accessKey,
    required String secretKey,
    String region = 'us-east-1',
    bool useSSL = true,
  }) : _enc = EncryptionProvider(vaultKey: vaultKey),
       _bucket = bucket,
       _minio = Minio(endPoint: endpoint, accessKey: accessKey, secretKey: secretKey, region: region, useSSL: useSSL);

  Future<void> init() async {
    await _enc.init();
  }

  @override
  Stream<SyncObject> listObjects() async* {
    final prefix = '${_enc.syncPrefix}/';
    _log.fine('listing bucket $_bucket');
    await for (final result in _minio.listObjects(_bucket, prefix: prefix)) {
      _log.fine('listing got chunk of ${result.objects.length} objects');
      for (final obj in result.objects) {
        final key = obj.key;
        if (key == null) continue;

        final lastModified = obj.lastModified;
        if (lastModified == null) continue;

        var eTag = obj.eTag;
        if (eTag == null) continue;
        eTag = eTag.replaceAll('"', '');

        yield SyncObject(_relativeKey(key), lastModified, eTag);
      }
    }
    _log.fine('listing complete');
  }

  @override
  Future<Uint8List> getObject(String key) async {
    _log.fine('loading object $_bucket/$key');
    final stream = await _minio.getObject(_bucket, _fullKey(key));
    final enc = await readByteStream(stream);
    return await _enc.decrypt(enc);
  }

  @override
  Future<String> putObject(String key, Uint8List data) async {
    _log.fine('storing object $_bucket/$key');
    final enc = await _enc.encrypt(data);
    return await _minio.putObject(_bucket, _fullKey(key), Stream.value(enc));
  }

  @override
  Future<void> deleteObject(String key) async {
    _log.fine('deleting object $_bucket/$key');
    await _minio.removeObject(_bucket, _fullKey(key));
  }

  /// Constructs the full S3 key by combining root path with the given key.
  String _fullKey(String key) {
    return '${_enc.syncPrefix}/$key';
  }

  /// Extracts the relative key by removing the root path prefix.
  String _relativeKey(String fullKey) {
    final prefix = '${_enc.syncPrefix}/';
    if (fullKey.startsWith(prefix)) {
      return fullKey.substring(prefix.length);
    }
    return fullKey;
  }
}
