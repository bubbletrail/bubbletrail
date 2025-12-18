import 'dart:io';

import 'package:bubbletrail/src/ssrf/ssrf.dart';
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

    // Test divecomputer
    expect(firstDive.divecomputers.length, 1);
    final firstDc = firstDive.divecomputers[0];
    expect(firstDc.maxDepth, closeTo(23.5, 0.01));
    expect(firstDc.meanDepth, closeTo(15.881, 0.001));

    // Test environment
    expect(firstDc.environment, isNotNull);
    expect(firstDc.environment!.airTemperature, 0.0);
    expect(firstDc.environment!.waterTemperature, 29.0);

    // Test events
    expect(firstDc.events.length, greaterThan(0));
    expect(firstDc.events[0].name, 'gaschange');

    // Test samples
    expect(firstDc.samples.length, greaterThan(0));
    expect(firstDc.samples[0].depth, closeTo(1.1, 0.01));
    expect(firstDc.samples[0].temp, closeTo(30.0, 0.01));

    // Test last dive
    final lastDive = ssrf.dives[53];
    expect(lastDive.number, 310);
    expect(lastDive.duration, 87 * 60 + 54);
    expect(lastDive.divecomputers.length, greaterThan(0));
    expect(lastDive.divecomputers[0].maxDepth, 22.6);
    expect(lastDive.divecomputers[0].meanDepth, closeTo(12.489, 0.001));
  });

  test('Serialize and deserialize SSRF data', () {
    // Create test data
    final originalSsrf = Ssrf(
      dives: [
        Dive(number: 1, start: DateTime(2019, 10, 30, 10, 49, 15), duration: 43 * 60 + 30, rating: 2)
          ..divecomputers.add(DiveComputerLog(diveComputerId: 0, maxDepth: 8.88, meanDepth: 4.952)),
        Dive(number: 2, start: DateTime(2019, 10, 31, 10, 25, 0), duration: 41 * 60 + 30, rating: 3)
          ..divecomputers.add(DiveComputerLog(diveComputerId: 0, maxDepth: 10.5, meanDepth: 5.2)),
      ],
      diveSites: [const Divesite(uuid: 'test-uuid-123', name: 'Test Site', position: GPSPosition(56.179390, 15.070710))],
    );

    // Serialize to XML
    final xmlDoc = originalSsrf.toXmlDocument();
    final xmlString = xmlDoc.toXmlString(pretty: true);

    // Deserialize back
    final parsedDoc = XmlDocument.parse(xmlString);
    final deserializedSsrf = SsrfXml.fromXml(parsedDoc.rootElement);

    // Verify the data matches
    expect(deserializedSsrf.dives.length, 2);
    expect(deserializedSsrf.dives[0].number, 1);
    expect(deserializedSsrf.dives[0].duration, 43 * 60 + 30);
    expect(deserializedSsrf.dives[0].divecomputers.length, 1);
    expect(deserializedSsrf.dives[0].divecomputers[0].maxDepth, 8.88);
    expect(deserializedSsrf.dives[0].divecomputers[0].meanDepth, 4.952);
    expect(deserializedSsrf.dives[0].rating, 2);

    expect(deserializedSsrf.dives[1].number, 2);
    expect(deserializedSsrf.dives[1].duration, 41 * 60 + 30);
    expect(deserializedSsrf.dives[1].divecomputers.length, 1);
    expect(deserializedSsrf.dives[1].divecomputers[0].maxDepth, 10.5);
    expect(deserializedSsrf.dives[1].divecomputers[0].meanDepth, 5.2);
    expect(deserializedSsrf.dives[1].rating, 3);
  });

  test('Serialize dive with tags and environment', () {
    final dive = Dive(number: 42, start: DateTime(2023, 6, 15, 14, 30, 0), duration: 3600, rating: 5);
    dive.tags.addAll(['Boat', 'Wet', 'Deep']);
    dive.divecomputers.add(
      DiveComputerLog(diveComputerId: 0, maxDepth: 25.5, meanDepth: 15.2, environment: Environment(airTemperature: 22.5, waterTemperature: 18.3)),
    );

    final xmlElement = dive.toXml();

    // Verify attributes
    expect(xmlElement.getAttribute('number'), '42');
    expect(xmlElement.getAttribute('rating'), '5');
    expect(xmlElement.getAttribute('tags'), 'Boat, Wet, Deep');

    // Verify depth
    final depth = xmlElement.getElement('divecomputer')?.getElement('depth');
    expect(depth?.getAttribute('max'), '25.5 m');
    expect(depth?.getAttribute('mean'), '15.2 m');

    // Verify temperature
    final temp = xmlElement.getElement('divecomputer')?.getElement('temperature');
    expect(temp?.getAttribute('air'), '22.5 C');
    expect(temp?.getAttribute('water'), '18.3 C');
  });

  test('Serialize sample data', () {
    const sample = Sample(time: 125, depth: 8.88, temp: 10.5, pressure: 200.0);

    final xmlElement = sample.toXml();

    expect(xmlElement.getAttribute('time'), '2:05 min');
    expect(xmlElement.getAttribute('depth'), '8.88 m');
    expect(xmlElement.getAttribute('temp'), '10.5 C');
    expect(xmlElement.getAttribute('pressure'), '200.0 bar');
  });

  test('Serialize divesite with GPS', () {
    const site = Divesite(uuid: 'abc123', name: 'Beautiful Reef', position: GPSPosition(56.179390, 15.070710));

    final xmlElement = site.toXml();

    expect(xmlElement.getAttribute('uuid'), 'abc123');
    expect(xmlElement.getAttribute('name'), 'Beautiful Reef');
    expect(xmlElement.getAttribute('gps'), '56.179390 15.070710');
  });

  test('Complete serialization with all features', () {
    // Create a comprehensive test with all features
    final dive1 =
        Dive(
            number: 1,
            start: DateTime(2023, 6, 15, 14, 30, 0),
            duration: 3600,
            rating: 5,
            sac: 18.5,
            otu: 15,
            cns: 5,
            divesiteid: 'site-123',
            divemaster: 'John Doe',
            notes: 'Amazing dive with great visibility.',
          )
          ..tags.addAll(['Boat', 'Deep', 'Wreck'])
          ..buddies.addAll(['Jane Smith', 'Bob Jones'])
          ..cylinders.add(
            const DiveCylinder(cylinderId: 0, cylinder: Cylinder(id: 0, size: 12.0, workpressure: 200.0, description: '12x200'), start: 200.0, end: 50.0),
          )
          ..weightsystems.add(const Weightsystem(weight: 6.0, description: 'integrated'));

    final dc1 = DiveComputerLog(diveComputerId: 0, maxDepth: 25.5, meanDepth: 15.2, environment: Environment(airTemperature: 28.0, waterTemperature: 22.0))
      ..samples.addAll([
        const Sample(time: 0, depth: 0.0),
        const Sample(time: 60, depth: 5.0, temp: 22.0),
        const Sample(time: 120, depth: 10.0, temp: 21.5, pressure: 180.0),
      ])
      ..events.add(const Event(time: 0, type: 11, value: 21, name: 'gaschange', cylinder: 0))
      ..extradata['visibility'] = 'Excellent'
      ..extradata['current'] = 'Moderate';

    dive1.divecomputers.add(dc1);

    final ssrf = Ssrf(
      dives: [dive1],
      diveSites: [const Divesite(uuid: 'site-123', name: 'Test Wreck Site', position: GPSPosition(35.123456, -120.654321))],
      diveComputers: [
        const DiveComputer(id: 0, model: 'test-model', serial: 'test-serial', deviceid: 'device-123', diveid: 'dive-456', fingerprintData: 'abc123'),
      ],
    );

    // Serialize
    final xmlDoc = ssrf.toXmlDocument();
    final xmlString = xmlDoc.toXmlString(pretty: true);

    // Deserialize
    final parsedDoc = XmlDocument.parse(xmlString);
    final deserializedSsrf = SsrfXml.fromXml(parsedDoc.rootElement);

    // Verify diveComputers (serialized as fingerprints in settings)
    expect(deserializedSsrf.diveComputers.length, 1);
    expect(deserializedSsrf.diveComputers[0].model, 'test-model');

    // Verify divesites
    expect(deserializedSsrf.diveSites.length, 1);
    expect(deserializedSsrf.diveSites[0].uuid, 'site-123');
    expect(deserializedSsrf.diveSites[0].position!.lat, closeTo(35.123456, 0.000001));

    // Verify dive
    final dive = deserializedSsrf.dives[0];
    expect(dive.number, 1);
    expect(dive.rating, 5);
    expect(dive.sac, closeTo(18.5, 0.001));
    expect(dive.otu, 15);
    expect(dive.cns, 5);
    expect(dive.divesiteid, 'site-123');
    expect(dive.divemaster, 'John Doe');
    expect(dive.buddies, containsAll(['Jane Smith', 'Bob Jones']));
    expect(dive.buddies.length, 2);
    expect(dive.notes, 'Amazing dive with great visibility.');
    expect(dive.tags, containsAll(['Boat', 'Deep', 'Wreck']));

    // Verify cylinder
    expect(dive.cylinders.length, 1);
    expect(dive.cylinders[0].cylinder?.size, 12.0);
    expect(dive.cylinders[0].start, 200.0);

    // Verify weightsystem
    expect(dive.weightsystems.length, 1);
    expect(dive.weightsystems[0].weight, 6.0);

    // Verify divecomputer
    expect(dive.divecomputers.length, 1);
    final dc = dive.divecomputers[0];

    // Verify samples
    expect(dc.samples.length, 3);
    expect(dc.samples[2].pressure, closeTo(180.0, 0.1));

    // Verify events
    expect(dc.events.length, 1);
    expect(dc.events[0].name, 'gaschange');

    // Verify extradata
    expect(dc.extradata['visibility'], 'Excellent');
    expect(dc.extradata['current'], 'Moderate');

    // Verify environment
    expect(dc.environment!.airTemperature, 28.0);
    expect(dc.environment!.waterTemperature, 22.0);
  });

  test('Multiple divecomputers', () {
    // Create a dive with multiple divecomputers
    final dive = Dive(number: 100, start: DateTime(2024, 1, 15, 10, 0, 0), duration: 3000, rating: 4);

    // Add first divecomputer
    dive.divecomputers.add(
      DiveComputerLog(diveComputerId: 0, maxDepth: 30.0, meanDepth: 18.5, environment: Environment(airTemperature: 25.0, waterTemperature: 20.0))
        ..samples.addAll([const Sample(time: 0, depth: 0.0), const Sample(time: 60, depth: 10.0)]),
    );

    // Add second divecomputer
    dive.divecomputers.add(
      DiveComputerLog(diveComputerId: 0, maxDepth: 30.2, meanDepth: 18.7)
        ..samples.addAll([const Sample(time: 0, depth: 0.0), const Sample(time: 65, depth: 10.5)]),
    );

    // Serialize
    final xmlElement = dive.toXml();
    final xmlString = xmlElement.toXmlString(pretty: true);

    // Deserialize
    final parsedElement = XmlDocument.parse(xmlString).rootElement;
    final deserializedDive = DiveXml.fromXml(parsedElement);

    // Verify both divecomputers
    expect(deserializedDive.divecomputers.length, 2);

    final dc1 = deserializedDive.divecomputers[0];
    expect(dc1.maxDepth, 30.0);
    expect(dc1.meanDepth, 18.5);
    expect(dc1.environment, isNotNull);
    expect(dc1.samples.length, 2);

    final dc2 = deserializedDive.divecomputers[1];
    expect(dc2.maxDepth, 30.2);
    expect(dc2.meanDepth, 18.7);
    expect(dc2.environment, isNull);
    expect(dc2.samples.length, 2);
  });

  test('Date and time parsing', () {
    // Test date-only parsing
    final date1 = tryParseDateTime('2024-03-15', null);
    expect(date1, isNotNull);
    expect(date1!.year, 2024);
    expect(date1.month, 3);
    expect(date1.day, 15);
    expect(date1.hour, 0);
    expect(date1.minute, 0);
    expect(date1.second, 0);

    // Test date and time parsing
    final date2 = tryParseDateTime('2024-03-15', '14:30:45');
    expect(date2, isNotNull);
    expect(date2!.year, 2024);
    expect(date2.month, 3);
    expect(date2.day, 15);
    expect(date2.hour, 14);
    expect(date2.minute, 30);
    expect(date2.second, 45);

    // Test round-trip formatting
    final formatted = Dive(number: 1, start: DateTime(2024, 3, 15, 14, 30, 45), duration: 60);

    final xmlElement = formatted.toXml();
    expect(xmlElement.getAttribute('date'), '2024-03-15');
    expect(xmlElement.getAttribute('time'), '14:30:45');

    // Parse back
    final reparsed = tryParseDateTime(xmlElement.getAttribute('date'), xmlElement.getAttribute('time'));
    expect(reparsed, formatted.start);
  });

  test('Cylinder O2 and He parsing and serialization', () {
    // Test serialization of O2 (nitrox)
    const cyl1 = DiveCylinder(
      cylinderId: 0,
      cylinder: Cylinder(id: 0, size: 12.0, workpressure: 200.0, description: '12x200'),
      o2: 32.0,
      start: 200.0,
      end: 50.0,
    );
    final xml1 = cyl1.toXml();
    expect(xml1.getAttribute('o2'), '32.0%');
    expect(xml1.getAttribute('he'), isNull);

    // Test serialization of O2 and He (trimix)
    const cyl2 = DiveCylinder(
      cylinderId: 0,
      cylinder: Cylinder(id: 0, size: 24.0, workpressure: 232.0, description: 'D12x232'),
      o2: 21.0,
      he: 35.0,
      start: 210.0,
      end: 100.0,
    );
    final xml2 = cyl2.toXml();
    expect(xml2.getAttribute('o2'), '21.0%');
    expect(xml2.getAttribute('he'), '35.0%');

    // Test round-trip for nitrox
    final reparsed1 = DiveCylinderXml.fromXml(xml1);
    expect(reparsed1.o2, closeTo(32.0, 0.1));
    expect(reparsed1.he, isNull);

    // Test round-trip for trimix
    final reparsed2 = DiveCylinderXml.fromXml(xml2);
    expect(reparsed2.o2, closeTo(21.0, 0.1));
    expect(reparsed2.he, closeTo(35.0, 0.1));

    // Test parsing from XML string
    final xmlString = "<cylinder size='10.0 l' workpressure='300.0 bar' description='10x300' o2='30.0%' end='115.2 bar' />";
    final parsedFromString = DiveCylinderXml.fromXml(XmlDocument.parse(xmlString).rootElement);
    expect(parsedFromString.o2, closeTo(30.0, 0.1));
    expect(parsedFromString.he, isNull);
  });
}
