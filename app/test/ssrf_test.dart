// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:osdl/src/ssrf/ssrf.dart';

void main() {
  test('Load sample SSRF file', () async {
    final xmlData = await File('./test/testdata/jakob@nym.se.ssrf').readAsString();
    final doc = XmlDocument.parse(xmlData);
    final ssrf = Ssrf.fromXml(doc.rootElement);

    // Test basic counts
    expect(ssrf.dives.length, 317);
    expect(ssrf.diveSites.length, 92);

    // Test settings
    expect(ssrf.settings, isNotNull);
    expect(ssrf.settings!.fingerprints.length, 3);
    expect(ssrf.settings!.fingerprints[0].model, '40d5bff1');

    // Test divesites
    final firstSite = ssrf.diveSites[0];
    expect(firstSite.uuid.trim(), '9a6a0ea');
    expect(firstSite.name, 'Sweden / Blekinge / Järnavik');
    expect(firstSite.position, isNotNull);
    expect(firstSite.position!.lat, closeTo(56.179390, 0.000001));
    expect(firstSite.position!.lon, closeTo(15.070710, 0.000001));

    // Test first dive with all attributes
    final firstDive = ssrf.dives[0];
    expect(firstDive.number, 1);
    expect(firstDive.rating, 2);
    expect(firstDive.sac, closeTo(26.454, 0.001));
    expect(firstDive.tags, containsAll(['Dry', 'OW', 'Shore']));
    expect(firstDive.divesiteid, 'f97fc13d');
    expect(firstDive.duration, 43 * 60 + 30);

    // Test date and time were parsed correctly
    expect(firstDive.start.year, 2019);
    expect(firstDive.start.month, 10);
    expect(firstDive.start.day, 30);
    expect(firstDive.start.hour, 10);
    expect(firstDive.start.minute, 49);
    expect(firstDive.start.second, 15);

    // Test dive child elements
    expect(firstDive.divemaster, 'Nina');
    expect(firstDive.buddies, containsAll(['Anna']));
    expect(firstDive.notes, contains('First qualification dive'));

    // Test cylinder
    expect(firstDive.cylinders.length, 1);
    expect(firstDive.cylinders[0].size, 10.0);
    expect(firstDive.cylinders[0].workpressure, 300.0);
    expect(firstDive.cylinders[0].description, '10x300');
    expect(firstDive.cylinders[0].start, 232.0);
    expect(firstDive.cylinders[0].end, 45.0);

    // Test weightsystem
    expect(firstDive.weightsystems.length, 1);
    expect(firstDive.weightsystems[0].weight, 8.0);

    // Test divecomputer
    expect(firstDive.divecomputers.length, 1);
    final firstDc = firstDive.divecomputers[0];
    expect(firstDc.maxDepth, closeTo(8.88, 0.01));
    expect(firstDc.meanDepth, closeTo(4.952, 0.001));

    // Test environment
    expect(firstDc.environment, isNotNull);
    expect(firstDc.environment!.airTemperature, 2.0);
    expect(firstDc.environment!.waterTemperature, 10.0);

    // Test extradata
    expect(firstDc.extradata['current'], 'None');
    expect(firstDc.extradata['entryType'], 'Shore');

    // Test events
    expect(firstDc.events.length, greaterThan(0));
    expect(firstDc.events[0].name, 'gaschange');

    // Test samples
    expect(firstDc.samples.length, greaterThan(0));
    expect(firstDc.samples[0].depth, 0.0);
    expect(firstDc.samples[0].temp, closeTo(10.56, 0.01));

    // Test last dive
    final lastDive = ssrf.dives[316];
    expect(lastDive.number, 307);
    expect(lastDive.duration, 75 * 60 + 24);
    expect(lastDive.divecomputers.length, greaterThan(0));
    expect(lastDive.divecomputers[0].maxDepth, 34.8);
    expect(lastDive.divecomputers[0].meanDepth, 19.385);
  });

  test('Serialize and deserialize SSRF data', () {
    // Create test data
    final originalSsrf = Ssrf(
      dives: [
        Dive(number: 1, start: DateTime(2019, 10, 30, 10, 49, 15), duration: 43 * 60 + 30, rating: 2)
          ..divecomputers.add(DiveComputer(maxDepth: 8.88, meanDepth: 4.952)),
        Dive(number: 2, start: DateTime(2019, 10, 31, 10, 25, 0), duration: 41 * 60 + 30, rating: 3)
          ..divecomputers.add(DiveComputer(maxDepth: 10.5, meanDepth: 5.2)),
      ],
    );

    // Add a divesite
    originalSsrf.diveSites.add(const Divesite(uuid: 'test-uuid-123', name: 'Test Site', position: GPSPosition(56.179390, 15.070710)));

    // Serialize to XML
    final xmlDoc = originalSsrf.toXmlDocument();
    final xmlString = xmlDoc.toXmlString(pretty: true);

    // Print for debugging
    print('Generated XML:\n$xmlString');

    // Deserialize back
    final parsedDoc = XmlDocument.parse(xmlString);
    final deserializedSsrf = Ssrf.fromXml(parsedDoc.rootElement);

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
    dive.divecomputers.add(DiveComputer(maxDepth: 25.5, meanDepth: 15.2, environment: Environment(airTemperature: 22.5, waterTemperature: 18.3)));

    final xmlElement = dive.toXml();
    final xmlString = xmlElement.toXmlString(pretty: true);

    print('Dive XML:\n$xmlString');

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
    const sample = Sample(time: 125.5, depth: 8.88, temp: 10.5, pressure: 200.0);

    final xmlElement = sample.toXml();
    final xmlString = xmlElement.toXmlString();

    print('Sample XML: $xmlString');

    expect(xmlElement.getAttribute('time'), '2:06 min');
    expect(xmlElement.getAttribute('depth'), '8.88 m');
    expect(xmlElement.getAttribute('temp'), '10.5 C');
    expect(xmlElement.getAttribute('pressure'), '200.0 bar');
  });

  test('Serialize divesite with GPS', () {
    const site = Divesite(uuid: 'abc123', name: 'Beautiful Reef', position: GPSPosition(56.179390, 15.070710));

    final xmlElement = site.toXml();
    final xmlString = xmlElement.toXmlString();

    print('Divesite XML: $xmlString');

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
          ..cylinders.add(const Cylinder(size: 12.0, workpressure: 200.0, description: '12x200', start: 200.0, end: 50.0))
          ..weightsystems.add(const Weightsystem(weight: 6.0, description: 'integrated'));

    final dc1 = DiveComputer(maxDepth: 25.5, meanDepth: 15.2, environment: Environment(airTemperature: 28.0, waterTemperature: 22.0))
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
      settings: Settings(
        fingerprints: [const Fingerprint(model: 'test-model', serial: 'test-serial', deviceid: 'device-123', diveid: 'dive-456', data: 'abc123')],
      ),
    )..diveSites.add(const Divesite(uuid: 'site-123', name: 'Test Wreck Site', position: GPSPosition(35.123456, -120.654321)));

    // Serialize
    final xmlDoc = ssrf.toXmlDocument();
    final xmlString = xmlDoc.toXmlString(pretty: true);

    print('Complete SSRF XML:\n$xmlString');

    // Deserialize
    final parsedDoc = XmlDocument.parse(xmlString);
    final deserializedSsrf = Ssrf.fromXml(parsedDoc.rootElement);

    // Verify settings
    expect(deserializedSsrf.settings, isNotNull);
    expect(deserializedSsrf.settings!.fingerprints.length, 1);
    expect(deserializedSsrf.settings!.fingerprints[0].model, 'test-model');

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
    expect(dive.cylinders[0].size, 12.0);
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
      DiveComputer(maxDepth: 30.0, meanDepth: 18.5, environment: Environment(airTemperature: 25.0, waterTemperature: 20.0))
        ..samples.addAll([const Sample(time: 0, depth: 0.0), const Sample(time: 60, depth: 10.0)]),
    );

    // Add second divecomputer
    dive.divecomputers.add(
      DiveComputer(maxDepth: 30.2, meanDepth: 18.7)..samples.addAll([const Sample(time: 0, depth: 0.0), const Sample(time: 65, depth: 10.5)]),
    );

    // Serialize
    final xmlElement = dive.toXml();
    final xmlString = xmlElement.toXmlString(pretty: true);

    print('Multiple divecomputers XML:\n$xmlString');

    // Deserialize
    final parsedElement = XmlDocument.parse(xmlString).rootElement;
    final deserializedDive = Dive.fromXml(parsedElement);

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
    final cyl1 = Cylinder(size: 12.0, workpressure: 200.0, description: '12x200', o2: 32.0, start: 200.0, end: 50.0);
    final xml1 = cyl1.toXml();
    expect(xml1.getAttribute('o2'), '32.0%');
    expect(xml1.getAttribute('he'), isNull);

    // Test serialization of O2 and He (trimix)
    final cyl2 = Cylinder(size: 24.0, workpressure: 232.0, description: 'D12x232', o2: 21.0, he: 35.0, start: 210.0, end: 100.0);
    final xml2 = cyl2.toXml();
    expect(xml2.getAttribute('o2'), '21.0%');
    expect(xml2.getAttribute('he'), '35.0%');

    // Test round-trip for nitrox
    final reparsed1 = Cylinder.fromXml(xml1);
    expect(reparsed1.o2, closeTo(32.0, 0.1));
    expect(reparsed1.he, isNull);

    // Test round-trip for trimix
    final reparsed2 = Cylinder.fromXml(xml2);
    expect(reparsed2.o2, closeTo(21.0, 0.1));
    expect(reparsed2.he, closeTo(35.0, 0.1));

    // Test parsing from XML string
    final xmlString = "<cylinder size='10.0 l' workpressure='300.0 bar' description='10x300' o2='30.0%' end='115.2 bar' />";
    final parsedFromString = Cylinder.fromXml(XmlDocument.parse(xmlString).rootElement);
    expect(parsedFromString.o2, closeTo(30.0, 0.1));
    expect(parsedFromString.he, isNull);

    print('Cylinder with O2: ${xml1.toXmlString()}');
    print('Cylinder with O2/He: ${xml2.toXmlString()}');
  });
}
