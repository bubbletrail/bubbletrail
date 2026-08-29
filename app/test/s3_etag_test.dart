import 'package:bubbletrail/src/providers/s3_provider.dart';
import 'package:test/test.dart';

void main() {
  group('eTag normalisation', () {
    test('strips the quotes S3 wraps eTags in', () {
      expect(normaliseEtag('"d41d8cd98f00b204e9800998ecf8427e"'), 'd41d8cd98f00b204e9800998ecf8427e');
    });

    test('leaves an already unquoted eTag alone', () {
      expect(normaliseEtag('d41d8cd98f00b204e9800998ecf8427e'), 'd41d8cd98f00b204e9800998ecf8427e');
    });

    test('handles the multipart form', () {
      // Multipart completion reports an md5-of-md5s with a part count suffix.
      expect(normaliseEtag('"3858f62230ac3c915f300c664312c11f-2"'), '3858f62230ac3c915f300c664312c11f-2');
    });

    test('a quoted and an unquoted eTag for the same object compare equal', () {
      expect(normaliseEtag('"abc123"'), normaliseEtag('abc123'));
    });

    test('does not chew on an unbalanced value', () {
      expect(normaliseEtag('"abc'), '"abc');
      expect(normaliseEtag('"'), '"');
    });
  });
}
