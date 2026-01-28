import 'dart:io';

import 'package:btproto/btproto.dart';
import 'package:bubbletrail/src/btstore/btstore.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('UDDF Import', () {
    late Container ssrf;

    setUpAll(() {
      final file = File('test/testdata/sample-1.uddf');
      final xmlDoc = XmlDocument.parse(file.readAsStringSync());
      ssrf = UddfXml.fromXml(xmlDoc.rootElement);
    });

    test('parses sites', () {
      expect(ssrf.sites, isNotEmpty);

      // Check first site
      final site = ssrf.sites.firstWhere((s) => s.name == 'Hällebäck');
      expect(site.id, '4796AB55-6152-4943-973B-144E6A8E2B3E');
      expect(site.country, 'Sweden');
      expect(site.location, 'Gullmarn');
      expect(site.hasPosition(), isTrue);
      expect(site.position.latitude, closeTo(58.34605, 0.00001));
      expect(site.position.longitude, closeTo(11.58821, 0.00001));
    });

    test('parses dives', () {
      expect(ssrf.dives, isNotEmpty);
    });

    test('parses dive metadata', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');

      expect(dive.number, 249);
      expect(dive.hasStart(), isTrue);

      final dt = dive.start.toDateTime();
      expect(dt.year, 2024);
      expect(dt.month, 11);
      expect(dt.day, 17);
      // Hour may vary by timezone, just check it's reasonable
      expect(dt.hour, inInclusiveRange(9, 11));
      expect(dt.minute, 35);
    });

    test('parses dive duration and depth', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');

      // Duration: 3530 seconds = ~58.8 minutes
      expect(dive.duration, 3530);

      // Greatest depth: 35.70 meters
      expect(dive.maxDepth, closeTo(35.70, 0.01));
    });

    test('converts temperature from Kelvin to Celsius', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');

      // Lowest temperature: 281.15K = 8°C
      expect(dive.logs, isNotEmpty);
      expect(dive.logs[0].hasMinTemperature(), isTrue);
      expect(dive.logs[0].minTemperature, closeTo(8.0, 0.1));
    });

    test('parses rating', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      expect(dive.hasRating(), isTrue);
      expect(dive.rating, 4);
    });

    test('parses notes', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      expect(dive.hasNotes(), isTrue);
      expect(dive.notes, contains('Hällebäck'));
    });

    test('parses site reference', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      expect(dive.hasSiteId(), isTrue);
      expect(dive.siteId, '4796AB55-6152-4943-973B-144E6A8E2B3E');
    });

    test('parses buddy reference', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      expect(dive.buddies, contains('Name Namesson'));
    });

    test('parses tank data with gas mix', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');

      expect(dive.cylinders, isNotEmpty);
      final cyl = dive.cylinders[0];

      // Gas: Air (21% O2)
      expect(cyl.oxygen, closeTo(0.21, 0.01));
      expect(cyl.helium, closeTo(0.0, 0.01));

      // Volume: 0.024 m³ = 24 liters
      expect(cyl.hasCylinder(), isTrue);
      expect(cyl.cylinder.volumeL, closeTo(24.0, 0.1));

      // Begin pressure: 20822167.02 Pa = ~208 bar
      expect(cyl.hasBeginPressure(), isTrue);
      expect(cyl.beginPressure, closeTo(208.0, 1.0));

      // End pressure: 11155717.30 Pa = ~112 bar
      expect(cyl.hasEndPressure(), isTrue);
      expect(cyl.endPressure, closeTo(112.0, 1.0));
    });

    test('parses dive samples', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');

      expect(dive.logs, isNotEmpty);
      final log = dive.logs[0];
      expect(log.samples, isNotEmpty);

      // Check first few samples
      final firstSample = log.samples[0];
      expect(firstSample.time, closeTo(0.0, 0.01));
      expect(firstSample.depth, closeTo(0.0, 0.01));

      // Check a sample with temperature
      final sampleWithTemp = log.samples.firstWhere((s) => s.hasTemperature());
      // 282.15K = 9°C
      expect(sampleWithTemp.temperature, closeTo(9.0, 0.1));
    });

    test('converts sample tank pressure from Pascal to bar', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      final log = dive.logs[0];

      // Find a sample with pressure
      final sampleWithPressure = log.samples.firstWhere((s) => s.pressures.isNotEmpty);
      // 20822167.02 Pa = ~208 bar
      expect(sampleWithPressure.pressures[0].pressure, closeTo(208.0, 1.0));
    });

    test('parses gas switch events with correct cylinder index', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      final log = dive.logs[0];

      // First sample should have a gas switch event (switchmix at start)
      final firstSample = log.samples[0];
      expect(firstSample.events, isNotEmpty);

      final gasChangeEvent = firstSample.events.firstWhere((e) => e.type == SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE);
      expect(gasChangeEvent.type, SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE);

      // First dive has Air (21% O2) as first cylinder, value should be 0
      expect(gasChangeEvent.value, 0);

      // Verify the cylinder at that index is Air
      expect(dive.cylinders[gasChangeEvent.value].oxygen, closeTo(0.21, 0.01));
    });
  });

  group('UDDF Import - Subsurface format', () {
    late Container ssrf;

    setUpAll(() {
      final file = File('test/testdata/sample-2.uddf');
      final xmlDoc = XmlDocument.parse(file.readAsStringSync());
      ssrf = UddfXml.fromXml(xmlDoc.rootElement);
    });

    test('parses sites from Subsurface export', () {
      expect(ssrf.sites, isNotEmpty);

      // Check site
      final site = ssrf.sites.firstWhere((s) => s.name.contains('Hällebäck'));
      expect(site.hasPosition(), isTrue);
      expect(site.position.latitude, closeTo(58.34605, 0.00001));
      expect(site.position.longitude, closeTo(11.58821, 0.00001));
    });

    test('parses dives from Subsurface export', () {
      expect(ssrf.dives, isNotEmpty);

      // Find the same dive as in MacDive export
      final dive = ssrf.dives.firstWhere((d) => d.number == 249);
      expect(dive.hasStart(), isTrue);
      expect(dive.buddies, contains('Name Namesson'));
    });

    test('handles tank volume in liters (Subsurface style)', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 249);

      expect(dive.cylinders, isNotEmpty);
      final cyl = dive.cylinders[0];

      // Subsurface exports as liters (24.0) not m³ (0.024)
      expect(cyl.hasCylinder(), isTrue);
      expect(cyl.cylinder.volumeL, closeTo(24.0, 0.1));
    });

    test('parses air temperature from informationbeforedive', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 249);

      expect(dive.logs, isNotEmpty);
      final log = dive.logs[0];

      // Air temperature: 273.15K = 0°C
      expect(log.hasSurfaceTemperature(), isTrue);
      expect(log.surfaceTemperature, closeTo(0.0, 0.1));
    });

    test('parses lead weight from equipmentused', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 249);

      // Lead quantity: 4 kg
      expect(dive.weightsystems, isNotEmpty);
      expect(dive.weightsystems[0].weight, closeTo(4.0, 0.01));
      expect(dive.weightsystems[0].description, 'Lead');
    });
  });

  group('UDDF Import - hashtag extraction from notes', () {
    test('extracts tags from dive notes', () {
      final xml = '''
        <uddf xmlns="http://www.streit.cc/uddf/3.2/" version="3.2.0">
          <profiledata>
            <repetitiongroup id="rg1">
              <dive id="dive1">
                <informationbeforedive>
                  <divenumber>1</divenumber>
                  <datetime>2024-01-01T10:00:00</datetime>
                </informationbeforedive>
                <informationafterdive>
                  <notes>Great dive with lots of fish.

#wreck #deep #coldwater</notes>
                </informationafterdive>
              </dive>
            </repetitiongroup>
          </profiledata>
        </uddf>
      ''';

      final xmlDoc = XmlDocument.parse(xml);
      final ssrf = UddfXml.fromXml(xmlDoc.rootElement);

      expect(ssrf.dives, hasLength(1));
      final dive = ssrf.dives[0];

      // Tags should be extracted
      expect(dive.tags, containsAll(['wreck', 'deep', 'coldwater']));

      // Notes should not contain the hashtag line
      expect(dive.notes, 'Great dive with lots of fish.');
      expect(dive.notes, isNot(contains('#')));
    });

    test('extracts tags from site notes', () {
      final xml = '''
        <uddf xmlns="http://www.streit.cc/uddf/3.2/" version="3.2.0">
          <divesite>
            <site id="site1">
              <name>Test Site</name>
              <notes>Beautiful reef location.

#reef #tropical #shallows</notes>
            </site>
          </divesite>
        </uddf>
      ''';

      final xmlDoc = XmlDocument.parse(xml);
      final ssrf = UddfXml.fromXml(xmlDoc.rootElement);

      expect(ssrf.sites, hasLength(1));
      final site = ssrf.sites[0];

      // Tags should be extracted
      expect(site.tags, containsAll(['reef', 'tropical', 'shallows']));

      // Notes should not contain the hashtag line
      expect(site.notes, 'Beautiful reef location.');
      expect(site.notes, isNot(contains('#')));
    });

    test('preserves notes when no hashtags present', () {
      final xml = '''
        <uddf xmlns="http://www.streit.cc/uddf/3.2/" version="3.2.0">
          <profiledata>
            <repetitiongroup id="rg1">
              <dive id="dive1">
                <informationbeforedive>
                  <divenumber>1</divenumber>
                  <datetime>2024-01-01T10:00:00</datetime>
                </informationbeforedive>
                <informationafterdive>
                  <notes>Just a regular note without tags.</notes>
                </informationafterdive>
              </dive>
            </repetitiongroup>
          </profiledata>
        </uddf>
      ''';

      final xmlDoc = XmlDocument.parse(xml);
      final ssrf = UddfXml.fromXml(xmlDoc.rootElement);

      final dive = ssrf.dives[0];
      expect(dive.tags, isEmpty);
      expect(dive.notes, 'Just a regular note without tags.');
    });

    test('does not extract hashtags from middle of notes', () {
      final xml = '''
        <uddf xmlns="http://www.streit.cc/uddf/3.2/" version="3.2.0">
          <profiledata>
            <repetitiongroup id="rg1">
              <dive id="dive1">
                <informationbeforedive>
                  <divenumber>1</divenumber>
                  <datetime>2024-01-01T10:00:00</datetime>
                </informationbeforedive>
                <informationafterdive>
                  <notes>Saw a #shark today.
More text here.</notes>
                </informationafterdive>
              </dive>
            </repetitiongroup>
          </profiledata>
        </uddf>
      ''';

      final xmlDoc = XmlDocument.parse(xml);
      final ssrf = UddfXml.fromXml(xmlDoc.rootElement);

      final dive = ssrf.dives[0];
      // Should not extract since hashtag is not on a dedicated last line
      expect(dive.tags, isEmpty);
      expect(dive.notes, contains('#shark'));
    });

    test('handles notes that are only hashtags', () {
      final xml = '''
        <uddf xmlns="http://www.streit.cc/uddf/3.2/" version="3.2.0">
          <profiledata>
            <repetitiongroup id="rg1">
              <dive id="dive1">
                <informationbeforedive>
                  <divenumber>1</divenumber>
                  <datetime>2024-01-01T10:00:00</datetime>
                </informationbeforedive>
                <informationafterdive>
                  <notes>#training #pool</notes>
                </informationafterdive>
              </dive>
            </repetitiongroup>
          </profiledata>
        </uddf>
      ''';

      final xmlDoc = XmlDocument.parse(xml);
      final ssrf = UddfXml.fromXml(xmlDoc.rootElement);

      final dive = ssrf.dives[0];
      expect(dive.tags, containsAll(['training', 'pool']));
      expect(dive.hasNotes(), isFalse);
    });
  });
}
