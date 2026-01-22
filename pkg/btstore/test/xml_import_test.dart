import 'dart:io';

import 'package:btstore/btstore.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('XML Format Detection', () {
    test('detects UDDF format', () {
      final file = File('test/testdata/sample-1.uddf');
      final doc = XmlDocument.parse(file.readAsStringSync());

      expect(detectXmlFormat(doc), DiveLogFormat.uddf);
    });

    test('detects Subsurface format', () {
      final file = File('test/testdata/subsurface-sample.xml');
      final doc = XmlDocument.parse(file.readAsStringSync());

      expect(detectXmlFormat(doc), DiveLogFormat.subsurface);
    });

    test('detects MacDive format', () {
      final file = File('test/testdata/macdive.xml');
      final doc = XmlDocument.parse(file.readAsStringSync());

      expect(detectXmlFormat(doc), DiveLogFormat.macdive);
    });

    test('returns unknown for unrecognized format', () {
      final doc = XmlDocument.parse('<unknown><data/></unknown>');

      expect(detectXmlFormat(doc), DiveLogFormat.unknown);
    });
  });

  group('Unified XML Import', () {
    test('imports UDDF file', () {
      final file = File('test/testdata/sample-1.uddf');
      final doc = XmlDocument.parse(file.readAsStringSync());

      final ssrf = importXml(doc);

      expect(ssrf.dives, isNotEmpty);
      expect(ssrf.sites, isNotEmpty);
      // UDDF test data has specific dive
      expect(ssrf.dives.any((d) => d.number == 249), isTrue);
    });

    test('imports Subsurface file', () {
      final file = File('test/testdata/subsurface-sample.xml');
      final doc = XmlDocument.parse(file.readAsStringSync());

      final ssrf = importXml(doc);

      expect(ssrf.dives, isNotEmpty);
      expect(ssrf.sites, isNotEmpty);
    });

    test('imports MacDive file', () {
      final file = File('test/testdata/macdive.xml');
      final doc = XmlDocument.parse(file.readAsStringSync());

      final ssrf = importXml(doc);

      expect(ssrf.dives, isNotEmpty);
      expect(ssrf.sites, isNotEmpty);
      // MacDive test data has specific dive
      expect(ssrf.dives.any((d) => d.number == 250), isTrue);
    });

    test('throws FormatException for unknown format', () {
      final doc = XmlDocument.parse('<unknown><data/></unknown>');

      expect(() => importXml(doc), throwsFormatException);
    });

    test('importXmlString works with UDDF', () {
      final file = File('test/testdata/sample-1.uddf');
      final xmlString = file.readAsStringSync();

      final ssrf = importXmlString(xmlString);

      expect(ssrf.dives, isNotEmpty);
    });

    test('importXmlString works with MacDive', () {
      final file = File('test/testdata/macdive.xml');
      final xmlString = file.readAsStringSync();

      final ssrf = importXmlString(xmlString);

      expect(ssrf.dives, isNotEmpty);
    });
  });
}
