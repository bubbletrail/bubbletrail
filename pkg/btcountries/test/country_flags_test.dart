import 'dart:io';
import 'package:test/test.dart';
import 'package:btcountries/src/countries.dart';

void main() {
  test('flags match country list', () {
    final flagsDir = Directory('assets/flags');
    final flagFiles = flagsDir.listSync().whereType<File>().map((f) => f.path).toSet();

    final missing = <String>[];
    for (final country in countries) {
      final expectedPath = 'assets/flags/${country.code.toLowerCase()}.png';
      if (!flagFiles.contains(expectedPath)) {
        missing.add('${country.code} (${country.name})');
      }
      flagFiles.remove(expectedPath);
    }

    expect(missing, isEmpty, reason: 'Missing flags: $missing');
    expect(flagFiles, isEmpty, reason: 'Unused flags: $flagFiles');
  });
}
