import 'dart:convert';
import 'dart:typed_data';

import 'package:bubbletrail/src/bloc/encryption_provider.dart';
import 'package:test/test.dart';

void main() {
  group('EncryptionProvider', () {
    test('roundtrip encrypts and decrypts data correctly', () async {
      final provider = EncryptionProvider(vaultKey: 'test-vault-key-12345');
      await provider.init();

      final originalData = utf8.encode('Hello, World! This is a test message.');
      final encrypted = await provider.encrypt(Uint8List.fromList(originalData));
      final decrypted = await provider.decrypt(encrypted);

      expect(decrypted, equals(originalData));
    });

    test('roundtrip works with binary data', () async {
      final provider = EncryptionProvider(vaultKey: 'another-test-key');
      await provider.init();

      final originalData = Uint8List.fromList(List.generate(256, (i) => i));
      final encrypted = await provider.encrypt(originalData);
      final decrypted = await provider.decrypt(encrypted);

      expect(decrypted, equals(originalData));
    });

    test('roundtrip works with empty data', () async {
      final provider = EncryptionProvider(vaultKey: 'empty-data-key');
      await provider.init();

      final originalData = Uint8List(0);
      final encrypted = await provider.encrypt(originalData);
      final decrypted = await provider.decrypt(encrypted);

      expect(decrypted, equals(originalData));
    });

    test('same input produces same ciphertext (deterministic nonce)', () async {
      final provider = EncryptionProvider(vaultKey: 'deterministic-key');
      await provider.init();

      final data = Uint8List.fromList(utf8.encode('same data'));
      final encrypted1 = await provider.encrypt(data);
      final encrypted2 = await provider.encrypt(data);

      expect(encrypted1, equals(encrypted2));
    });

    test('syncPrefix is generated after init', () async {
      final provider = EncryptionProvider(vaultKey: 'prefix-test-key');
      await provider.init();

      expect(provider.syncPrefix, startsWith('bubbletrail-'));
      expect(provider.syncPrefix.length, greaterThan(12));
    });
  });
}
