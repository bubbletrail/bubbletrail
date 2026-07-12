import 'dart:io';

import 'package:btproto/btproto.dart';
import 'package:bubbletrail/src/services/store/store.dart';
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

  group('Suunto JSON Import', () {
    // A real open-circuit dive with tank pressure and a GPS fix.
    final scubaFile = File('test/testdata/suunto-json/695928f453b7400e7bceee8e.json');
    // A shallow session without tank data (no gas pressures recorded).
    final shallowFile = File('test/testdata/suunto-json/6a3ed0d031b97366e16a7e03.json');

    test('importJson detects and imports a Suunto dive', () {
      final imported = importJsonString(scubaFile.readAsStringSync());

      expect(imported.dives, hasLength(1));
      final dive = imported.dives.single;

      // Summary fields from the header.
      expect(dive.maxDepth, closeTo(30.8, 0.01));
      expect(dive.meanDepth, closeTo(16.67, 0.01));
      expect(dive.duration, 2523); // DiveTime, rounded to seconds
      // Temperature in Kelvin (280.8/281.1) converted to Celsius, extremes
      // derived rather than trusting the (swapped) Min/Max labels.
      expect(dive.minTemp, closeTo(280.8 - 273.15, 0.01));
      expect(dive.maxTemp, closeTo(281.1 - 273.15, 0.01));
    });

    test('importString auto-detects JSON', () {
      final imported = importString(scubaFile.readAsStringSync());
      expect(imported.dives, hasLength(1));
    });

    test('imports the depth profile and dive computer metadata', () {
      final dive = importJsonString(scubaFile.readAsStringSync()).dives.single;

      expect(dive.logs, hasLength(1));
      final log = dive.logs.single;

      expect(log.model, 'Suunto Nautic');
      expect(log.serial, '254410000460');
      expect(log.samples, hasLength(293));
      expect(log.diveMode, DiveMode.DIVE_MODE_OPENCIRCUIT);
      expect(log.hasUniqueID(), isTrue);

      // Samples carry depth and a sensible dive-relative time.
      final first = log.samples.first;
      expect(first.time, greaterThanOrEqualTo(0));
      expect(first.depth, greaterThan(0));
    });

    test('imports a single cylinder with begin/end pressure', () {
      final dive = importJsonString(scubaFile.readAsStringSync()).dives.single;

      expect(dive.cylinders, hasLength(1));
      final cyl = dive.cylinders.single;
      // Pressures in Pascal converted to bar (19881250 Pa -> ~198.8 bar).
      expect(cyl.beginPressure, closeTo(198.8, 0.5));
      expect(cyl.endPressure, closeTo(122.98, 0.5));
      expect(cyl.endPressure, lessThan(cyl.beginPressure));
      // No gas composition in the format, defaults to air.
      expect(cyl.oxygen, closeTo(0.21, 0.001));

      // At least one sample reports tank pressure against this cylinder.
      final withPressure = dive.logs.single.samples.where((s) => s.pressures.isNotEmpty);
      expect(withPressure, isNotEmpty);
      expect(withPressure.first.pressures.first.tankIndex, 0);
    });

    test('tracks the closest prior temperature for each sample', () {
      final samples = importJsonString(scubaFile.readAsStringSync()).dives.single.logs.single.samples;

      // The first depth sample precedes the first temperature reading, so it
      // has no temperature to inherit.
      expect(samples.first.hasTemperature(), isFalse);

      final withTemp = samples.where((s) => s.hasTemperature()).toList();
      expect(withTemp, isNotEmpty);

      // Temperature must vary across the dive (the bug froze it at the first
      // reading), and stay within the recorded 280.77-281.15 K range (~7.6-8 C).
      final values = withTemp.map((s) => s.temperature).toSet();
      expect(values.length, greaterThan(1));
      const kelvinOffset = 273.15;
      for (final t in values) {
        expect(t, inInclusiveRange(280.77 - kelvinOffset, 281.15 - kelvinOffset));
      }
    });

    test('imports the GPS position from the dive route origin', () {
      final dive = importJsonString(scubaFile.readAsStringSync()).dives.single;
      final position = dive.logs.single.position;

      // DiveRouteOrigin is in degrees (unlike the radian Latitude/Longitude samples).
      expect(position.latitude, closeTo(48.26, 0.01));
      expect(position.longitude, closeTo(7.787, 0.01));
    });

    test('imports a shallow session without tank data', () {
      final dive = importJsonString(shallowFile.readAsStringSync()).dives.single;

      expect(dive.maxDepth, closeTo(2.98, 0.01));
      expect(dive.cylinders, isEmpty); // No gas pressures recorded
      expect(dive.logs.single.samples, hasLength(251));
    });

    test('throws FormatException for unknown JSON', () {
      expect(() => importJsonString('{"Something": 1}'), throwsFormatException);
    });
  });
}
