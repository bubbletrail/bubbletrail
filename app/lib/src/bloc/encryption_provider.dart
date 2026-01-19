import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';

class EncryptionProvider {
  late final String _vaultKey;
  late final String _syncPrefix;
  late final SecretKey _boxKey;
  final _cipher = Chacha20.poly1305Aead();

  String get syncPrefix => _syncPrefix;

  EncryptionProvider({required String vaultKey}) : _vaultKey = vaultKey;

  Future<void> init() async {
    final (boxKey, prefKey) = await Isolate.run(() async {
      final algorithm = Argon2id(
        parallelism: 2,
        memory: 20000,
        iterations: 2,
        hashLength: 36, // 32 bytes key, 4 bytes storage prefix
      );
      final passwd = utf8.encode(_vaultKey);
      final newSecretKey = await algorithm.deriveKey(secretKey: SecretKey(passwd), nonce: utf8.encode('bubbletrail-encryption'));
      final secbytes = Uint8List.fromList(await newSecretKey.extractBytes());
      final boxKey = secbytes.slice(0, 32);
      final prefKey = secbytes.slice(32);
      return (boxKey, prefKey);
    });
    _syncPrefix = 'bubbletrail-${hex.encode(prefKey)}';
    _boxKey = SecretKey(boxKey);
  }

  Future<Uint8List> decrypt(Uint8List enc) async {
    final nonce = enc.sublist(0, 12);
    final data = enc.sublist(12, enc.length - 16);
    final mac = enc.sublist(enc.length - 16);
    final sb = SecretBox(data, nonce: nonce, mac: Mac(mac));
    return Uint8List.fromList(await _cipher.decrypt(sb, secretKey: _boxKey));
  }

  Future<Uint8List> encrypt(Uint8List data) async {
    final nonce = List<int>.generate(12, (_) => SecureRandom.fast.nextInt(256));
    final sb = await _cipher.encrypt(data, secretKey: _boxKey, nonce: nonce);
    return sb.concatenation();
  }
}
