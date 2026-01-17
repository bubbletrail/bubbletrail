import 'dart:io';

import 'package:divestore/divestore.dart';
import 'package:divestore/import/macdive.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('MacDive Import', () {
    late Container ssrf;

    setUpAll(() {
      final file = File('test/testdata/macdive.xml');
      final xmlDoc = XmlDocument.parse(file.readAsStringSync());
      ssrf = MacDiveXml.fromXml(xmlDoc.rootElement);
    });

    test('parses dives', () {
      expect(ssrf.dives, hasLength(2));
    });

    test('parses sites', () {
      expect(ssrf.sites, isNotEmpty);

      // Check first site
      final site = ssrf.sites.firstWhere((s) => s.name == 'Fortet');
      expect(site.country, 'Sweden');
      expect(site.location, 'Simrishamn');
      expect(site.bodyOfWater, 'Östersjön');
      expect(site.hasPosition(), isTrue);
      expect(site.position.latitude, closeTo(55.55478, 0.00001));
      expect(site.position.longitude, closeTo(14.36110, 0.00001));
    });

    test('parses dive metadata', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);

      expect(dive.id, '20241228095902-A0704A81');
      expect(dive.hasStart(), isTrue);

      final dt = dive.start.toDateTime();
      expect(dt.year, 2024);
      expect(dt.month, 12);
      expect(dt.day, 28);
      // Hour may vary by timezone, just check it's reasonable
      expect(dt.hour, inInclusiveRange(8, 10));
      expect(dt.minute, 59);
    });

    test('parses dive duration and depth', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);

      // Duration: 4450 seconds
      expect(dive.duration, 4450);

      // Max depth: 12.80 meters
      expect(dive.maxDepth, closeTo(12.80, 0.01));

      // Average depth: 7.91 meters
      expect(dive.meanDepth, closeTo(7.91, 0.01));
    });

    test('parses rating', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);
      expect(dive.hasRating(), isTrue);
      expect(dive.rating, 4);
    });

    test('parses notes', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);
      expect(dive.hasNotes(), isTrue);
      expect(dive.notes, contains('Väldigt fint ställe'));
    });

    test('parses CNS', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);
      expect(dive.hasCns(), isTrue);
      expect(dive.cns, 5);
    });

    test('parses site reference', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);
      expect(dive.hasSiteId(), isTrue);

      // Find the site by ID and verify it matches
      final site = ssrf.sites.firstWhere((s) => s.id == dive.siteId);
      expect(site.name, 'Fortet');
    });

    test('parses tags', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);
      expect(dive.tags, contains('Dry'));
      expect(dive.tags, contains('Shore'));
      expect(dive.tags, contains('Drill'));
    });

    test('parses buddies', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);
      expect(dive.buddies, contains('Name Namesson'));
    });

    test('parses gas/cylinder data', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);

      expect(dive.cylinders, isNotEmpty);
      final cyl = dive.cylinders[0];

      // Gas: EAN28 (28% O2)
      expect(cyl.oxygen, closeTo(0.28, 0.01));
      expect(cyl.helium, closeTo(0.0, 0.01));

      // Tank size: 14 liters
      expect(cyl.hasCylinder(), isTrue);
      expect(cyl.cylinder.volumeL, closeTo(14.0, 0.1));

      // Working pressure: 300 bar
      expect(cyl.cylinder.workingPressureBar, closeTo(300.0, 0.1));

      // Begin pressure: 282.96 bar
      expect(cyl.hasBeginPressure(), isTrue);
      expect(cyl.beginPressure, closeTo(282.96, 0.1));

      // End pressure: 70.33 bar
      expect(cyl.hasEndPressure(), isTrue);
      expect(cyl.endPressure, closeTo(70.33, 0.1));
    });

    test('parses dive computer info', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);

      expect(dive.logs, isNotEmpty);
      final log = dive.logs[0];

      expect(log.model, 'Shearwater Perdix 2');
      expect(log.serial, 'A0704A81');
    });

    test('parses dive samples', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);

      expect(dive.logs, isNotEmpty);
      final log = dive.logs[0];
      expect(log.samples, isNotEmpty);

      // Check first sample
      final firstSample = log.samples[0];
      expect(firstSample.time, closeTo(0.0, 0.01));
      expect(firstSample.depth, closeTo(1.10, 0.01));
      expect(firstSample.temperature, closeTo(7.0, 0.1));
    });

    test('parses sample pressure', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);
      final log = dive.logs[0];

      // First sample should have pressure
      final firstSample = log.samples[0];
      expect(firstSample.pressures, isNotEmpty);
      expect(firstSample.pressures[0].pressure, closeTo(282.96, 0.1));
    });

    test('parses second dive', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 249);

      expect(dive.id, '20241117103535-A0704A81');
      expect(dive.duration, 3530);
      expect(dive.maxDepth, closeTo(35.70, 0.01));

      // Should have Hällebäck site
      final site = ssrf.sites.firstWhere((s) => s.id == dive.siteId);
      expect(site.name, 'Hällebäck');
      expect(site.location, 'Gullmarn');
    });

    test('deduplicates sites with same name and coordinates', () {
      // If both dives had the same site, it should only appear once
      // In this test data, the two dives have different sites
      final fortet = ssrf.sites.where((s) => s.name == 'Fortet');
      final halleBack = ssrf.sites.where((s) => s.name == 'Hällebäck');

      expect(fortet, hasLength(1));
      expect(halleBack, hasLength(1));
    });

    test('parses weight with type abbreviation', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 250);

      // Weight string is "4wb" = 4 kg on weight belt
      expect(dive.weightsystems, isNotEmpty);
      expect(dive.weightsystems[0].weight, closeTo(4.0, 0.01));
      expect(dive.weightsystems[0].description, 'Weight belt');
    });
  });
}
