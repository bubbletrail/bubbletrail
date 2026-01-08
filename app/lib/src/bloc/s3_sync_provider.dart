import 'dart:convert';

import 'package:chunked_stream/chunked_stream.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:divestore/divestore.dart';
import 'package:flutter/foundation.dart';
import 'package:minio/minio.dart';
import 'package:pinenacl/key_derivation.dart';
import 'package:pinenacl/x25519.dart';

class S3SyncProvider extends SyncProvider {
  final Minio _minio;
  final String _bucket;
  late final String _syncKey;
  late final String _syncPrefix;
  late final SecretBox _box;

  S3SyncProvider({
    required String syncKey,
    required String endpoint,
    required String bucket,
    required String rootPath,
    required String accessKey,
    required String secretKey,
    String region = 'us-east-1',
    bool useSSL = true,
  }) : _syncKey = syncKey,
       _bucket = bucket,
       _minio = Minio(endPoint: endpoint, accessKey: accessKey, secretKey: secretKey, region: region, useSSL: useSSL);

  Future<void> init() async {
    final (boxKey, prefKey) = await compute((_) {
      final boxKey = PBKDF2.hmac_sha256(utf8.encode(_syncKey), utf8.encode('bubbletrail-encryption'), 500 << 10, 32);
      final prefKey = PBKDF2.hmac_sha256(utf8.encode(_syncKey), utf8.encode('bubbletrail-prefix5'), 1 << 10, 8);
      return (boxKey, prefKey);
    }, null);
    _syncPrefix = 'bubbletrail-${hex.encode(prefKey)}';
    _box = SecretBox(boxKey);
  }

  @override
  Stream<SyncObject> listObjects() async* {
    final prefix = '$_syncPrefix/';

    await for (final result in _minio.listObjects(_bucket, prefix: prefix)) {
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
  }

  @override
  Future<Uint8List> getObject(String key) async {
    final stream = await _minio.getObject(_bucket, _fullKey(key));
    final enc = await readByteStream(stream);
    final encui8l = enc.toUint8List();
    final nonce = encui8l.sublist(0, 32);
    final data = encui8l.sublist(32);
    return _box.decrypt(ByteList(data), nonce: nonce);
  }

  @override
  Future<String> putObject(String key, Uint8List data) async {
    final nonce = sha256.convert(data).bytes;
    final enc = _box.encrypt(data, nonce: Uint8List.fromList(nonce));
    // enc includes the prepended nonce
    return await _minio.putObject(_bucket, _fullKey(key), Stream.value(enc.asTypedList));
  }

  /// Constructs the full S3 key by combining root path with the given key.
  String _fullKey(String key) {
    return '$_syncPrefix/$key';
  }

  /// Extracts the relative key by removing the root path prefix.
  String _relativeKey(String fullKey) {
    final prefix = '$_syncPrefix/';
    if (fullKey.startsWith(prefix)) {
      return fullKey.substring(prefix.length);
    }
    return fullKey;
  }
}
