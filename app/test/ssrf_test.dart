import 'dart:io';

import 'package:divestore/divestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

void main() {
  test('Load sample SSRF file', () async {
    final xmlData = await File('./test/testdata/subsurface-sample.xml').readAsString();
    final doc = XmlDocument.parse(xmlData);
    final ssrf = SsrfXml.fromXml(doc.rootElement);

    // Test basic counts
    expect(ssrf.dives.length, 54);
    expect(ssrf.diveSites.length, 32);

    // Test diveComputers (parsed from fingerprints in settings)
    expect(ssrf.diveComputers.length, 3);
    expect(ssrf.diveComputers[0].model, '40d5bff1');

    // Test divesites
    final firstSite = ssrf.diveSites[0];
    expect(firstSite.uuid, '0e05b954');
    expect(firstSite.name, 'Xxxxxxxx / Xxx Xxx / Xxxxx Xxxx');
    expect(firstSite.position, isNotNull);
    expect(firstSite.position!.lat, closeTo(10.110830, 0.000001));
    expect(firstSite.position!.lon, closeTo(99.813260, 0.000001));

    // Test first dive with all attributes
    final firstDive = ssrf.dives[0];
    expect(firstDive.id, isNotEmpty);
    expect(firstDive.number, 257);
    expect(firstDive.rating, 5);
    expect(firstDive.sac, closeTo(13.507, 0.001));
    expect(firstDive.tags, containsAll(['Boat', 'Wet']));
    expect(firstDive.divesiteid, '4500464d');
    expect(firstDive.duration, 44 * 60 + 48);

    // Test date and time were parsed correctly
    expect(firstDive.start.year, 2025);
    expect(firstDive.start.month, 4);
    expect(firstDive.start.day, 16);
    expect(firstDive.start.hour, 8);
    expect(firstDive.start.minute, 37);
    expect(firstDive.start.second, 58);

    // Test dive child elements
    expect(firstDive.divemaster, 'Xxxx');
    expect(firstDive.buddies, containsAll(['Xxxxxx']));
    expect(firstDive.notes, isNotEmpty);

    // Test cylinder
    expect(firstDive.cylinders.length, 1);
    expect(firstDive.cylinders[0].cylinder?.size, 11.0);
    expect(firstDive.cylinders[0].cylinder?.workpressure, 230.0);
    expect(firstDive.cylinders[0].cylinder?.description, 'AL80');
    expect(firstDive.cylinders[0].start, isNull);
    expect(firstDive.cylinders[0].end, isNull);

    // Test weightsystem
    expect(firstDive.weightsystems.length, 1);
    expect(firstDive.weightsystems[0].weight, 2.4);

    // Test computerDive
    expect(firstDive.computerDives.length, 1);
    final firstCd = firstDive.computerDives[0];
    expect(firstCd.maxDepth, closeTo(23.5, 0.01));
    expect(firstCd.avgDepth, closeTo(15.881, 0.001));

    // Test temperature
    expect(firstCd.surfaceTemperature, 0.0);
    expect(firstCd.minTemperature, 29.0);

    // Test events
    expect(firstCd.events.length, greaterThan(0));
    expect(firstCd.events[0].type, SampleEventType.gasChange);

    // Test samples
    expect(firstCd.samples.length, greaterThan(0));
    expect(firstCd.samples[0].depth, closeTo(1.1, 0.01));
    expect(firstCd.samples[0].temperature, closeTo(30.0, 0.01));

    // Test last dive
    final lastDive = ssrf.dives[53];
    expect(lastDive.number, 310);
    expect(lastDive.duration, 87 * 60 + 54);
    expect(lastDive.computerDives.length, greaterThan(0));
    expect(lastDive.computerDives[0].maxDepth, 22.6);
    expect(lastDive.computerDives[0].avgDepth, closeTo(12.489, 0.001));
  });

  test('Serialize and deserialize SSRF data', () {
    // Create test data
    final originalSsrf = Ssrf(
      dives: [
        Dive(number: 1, start: DateTime(2019, 10, 30, 10, 49, 15), duration: 43 * 60 + 30, rating: 2)
          ..computerDives.add(ComputerDive(maxDepth: 8.88, avgDepth: 4.952)),
        Dive(number: 2, start: DateTime(2019, 10, 31, 10, 25, 0), duration: 41 * 60 + 30, rating: 3)
          ..computerDives.add(ComputerDive(maxDepth: 10.5, avgDepth: 5.2)),
      ],
      diveSites: [const Divesite(uuid: 'abcd1234', name: 'Test Site', position: GPSPosition(37.7749, -122.4194))],
    );

    // Serialize to XML
    final xmlDoc = originalSsrf.toXmlDocument();
    final xmlString = xmlDoc.toXmlString(pretty: true);

    // Parse back
    final parsedDoc = XmlDocument.parse(xmlString);
    final parsedSsrf = SsrfXml.fromXml(parsedDoc.rootElement);

    // Verify basic structure preserved
    expect(parsedSsrf.dives.length, 2);
    expect(parsedSsrf.diveSites.length, 1);

    // Verify dive data preserved
    expect(parsedSsrf.dives[0].number, 1);
    expect(parsedSsrf.dives[0].rating, 2);
    expect(parsedSsrf.dives[0].computerDives.length, 1);
    expect(parsedSsrf.dives[0].computerDives[0].maxDepth, closeTo(8.88, 0.01));

    // Verify dive site preserved
    expect(parsedSsrf.diveSites[0].uuid, 'abcd1234');
    expect(parsedSsrf.diveSites[0].name, 'Test Site');
  });

  test('XML with ComputerDive samples and events', () {
    final dive = Dive(number: 1, start: DateTime(2024, 6, 15, 10, 30, 0), duration: 30 * 60)
      ..computerDives.add(
        ComputerDive(
          model: 'Suunto EON Core',
          serial: '12345',
          maxDepth: 20.0,
          avgDepth: 12.0,
          surfaceTemperature: 28.0,
          minTemperature: 22.0,
          samples: [
            ComputerSample(time: 0, depth: 0.0),
            ComputerSample(time: 60, depth: 10.0, temperature: 25.0),
            ComputerSample(time: 120, depth: 20.0, temperature: 22.0),
          ],
          events: [const SampleEvent(type: SampleEventType.gasChange, time: 0, flags: SampleEventFlags(0), value: 0)],
        ),
      );

    final ssrf = Ssrf(dives: [dive], diveSites: []);
    final xmlDoc = ssrf.toXmlDocument();
    final xmlString = xmlDoc.toXmlString(pretty: true);

    // Parse back
    final parsedDoc = XmlDocument.parse(xmlString);
    final parsedSsrf = SsrfXml.fromXml(parsedDoc.rootElement);

    expect(parsedSsrf.dives.length, 1);
    final parsedDive = parsedSsrf.dives[0];
    expect(parsedDive.computerDives.length, 1);

    final cd = parsedDive.computerDives[0];
    expect(cd.model, 'Suunto EON Core');
    expect(cd.serial, '12345');
    expect(cd.samples.length, 3);
    expect(cd.events.length, 1);
    expect(cd.events[0].type, SampleEventType.gasChange);
  });

  test('tryParseDateTime helper', () {
    expect(tryParseDateTime('2024-12-25', '10:30:00'), DateTime(2024, 12, 25, 10, 30, 0));
    expect(tryParseDateTime('2024-12-25', null), DateTime(2024, 12, 25));
    expect(tryParseDateTime(null, '10:30:00'), isNull);
    expect(tryParseDateTime(null, null), isNull);
  });

  test('DiveCylinderXml parsing', () {
    const xml = '<cylinder size="11.0 l" workpressure="230.0 bar" description="AL80" start="200.0 bar" end="50.0 bar" o2="32.0%" />';
    final elem = XmlDocument.parse(xml).rootElement;
    final cyl = DiveCylinderXml.fromXml(elem);

    expect(cyl.cylinder?.size, 11.0);
    expect(cyl.cylinder?.workpressure, 230.0);
    expect(cyl.cylinder?.description, 'AL80');
    expect(cyl.start, 200.0);
    expect(cyl.end, 50.0);
    expect(cyl.o2, 32.0);
  });

  test('DiveCylinderXml serialization', () {
    final cyl = DiveCylinder(
      cylinderId: 1,
      cylinder: const Cylinder(id: 1, size: 12.0, workpressure: 200.0, description: 'Steel'),
      start: 200.0,
      end: 50.0,
      o2: 32.0,
      he: 10.0,
    );

    final elem = cyl.toXml();
    expect(elem.getAttribute('description'), 'Steel');
    expect(elem.getAttribute('size'), '12.0 l');
    expect(elem.getAttribute('o2'), '32.0%');
  });
}
