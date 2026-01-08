import 'dart:typed_data';

import 'package:chunked_stream/chunked_stream.dart';
import 'package:divestore/divestore.dart';
import 'package:minio/minio.dart';

class S3SyncProvider extends SyncProvider {
  final Minio _minio;
  final String _bucket;
  final String _rootPath;

  S3SyncProvider({
    required String endpoint,
    required String bucket,
    required String rootPath,
    required String accessKey,
    required String secretKey,
    String region = 'us-east-1',
    bool useSSL = true,
  }) : _bucket = bucket,
       _rootPath = _normalizePath(rootPath),
       _minio = Minio(endPoint: endpoint, accessKey: accessKey, secretKey: secretKey, region: region, useSSL: useSSL);

  @override
  Stream<SyncObject> listObjects() async* {
    final prefix = _rootPath.isEmpty ? '' : '$_rootPath/';

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
    return await readByteStream(stream);
  }

  @override
  Future<String> putObject(String key, Uint8List data) async {
    return await _minio.putObject(_bucket, _fullKey(key), Stream.value(data));
  }

  /// Normalizes the root path to ensure consistent formatting.
  /// Removes leading slash and ensures trailing slash if non-empty.
  static String _normalizePath(String path) {
    var normalized = path;
    // Remove leading slash
    while (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    // Remove trailing slash
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  /// Constructs the full S3 key by combining root path with the given key.
  String _fullKey(String key) {
    if (_rootPath.isEmpty) {
      return key;
    }
    return '$_rootPath/$key';
  }

  /// Extracts the relative key by removing the root path prefix.
  String _relativeKey(String fullKey) {
    if (_rootPath.isEmpty) {
      return fullKey;
    }
    final prefix = '$_rootPath/';
    if (fullKey.startsWith(prefix)) {
      return fullKey.substring(prefix.length);
    }
    return fullKey;
  }
}
