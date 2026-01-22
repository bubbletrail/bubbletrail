import 'dart:io';

import 'package:btstore/btstore.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as proto;
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  test('Load sample SSRF file', () async {
    final xmlData = await File('./test/testdata/subsurface-sample.xml').readAsString();
    final doc = XmlDocument.parse(xmlData);
    final ssrf = SsrfXml.fromXml(doc.rootElement);

    // Test basic counts
    expect(ssrf.dives.length, 54);
    expect(ssrf.sites.length, 32);

    // Test sites - find a specific site with known GPS coordinates
    final testSite = ssrf.sites.firstWhere(
      (s) => s.hasPosition() && (s.position.latitude - 10.110830).abs() < 0.001 && (s.position.longitude - 99.813260).abs() < 0.001,
    );
    expect(testSite.id, isNotEmpty);
    expect(testSite.name, isNotEmpty);
    expect(testSite.hasPosition(), isTrue);

    // Test first dive with all attributes
    final firstDive = ssrf.dives[0];
    expect(firstDive.id, isNotEmpty);
    expect(firstDive.number, 257);
    expect(firstDive.rating, 5);
    expect(firstDive.sac, closeTo(13.507, 0.001));
    expect(firstDive.tags, containsAll(['Boat', 'Wet']));
    expect(firstDive.siteId, '4500464d');
    expect(firstDive.duration, 44 * 60 + 48);

    // Test date and time were parsed correctly (convert to local time for comparison)
    final startDateTime = firstDive.start.toDateTime().toLocal();
    expect(startDateTime.year, 2025);
    expect(startDateTime.month, 4);
    expect(startDateTime.day, 16);
    expect(startDateTime.hour, 8);
    expect(startDateTime.minute, 37);
    expect(startDateTime.second, 58);

    // Test dive child elements
    expect(firstDive.divemaster, 'Xxxx');
    expect(firstDive.buddies, containsAll(['Xxxxxx']));
    expect(firstDive.notes, isNotEmpty);

    // Test cylinder
    expect(firstDive.cylinders.length, 1);
    expect(firstDive.cylinders[0].cylinder.volumeL, 11.0);
    expect(firstDive.cylinders[0].cylinder.workingPressureBar, 230.0);
    expect(firstDive.cylinders[0].cylinder.description, 'AL80');
    expect(firstDive.cylinders[0].hasBeginPressure(), isFalse);
    expect(firstDive.cylinders[0].hasEndPressure(), isFalse);

    // Test weightsystem
    expect(firstDive.weightsystems.length, 1);
    expect(firstDive.weightsystems[0].weight, 2.4);

    // Test log
    expect(firstDive.logs.length, 1);
    final firstCd = firstDive.logs[0];
    expect(firstCd.maxDepth, closeTo(23.5, 0.01));
    expect(firstCd.avgDepth, closeTo(15.881, 0.001));

    // Test temperature
    expect(firstCd.surfaceTemperature, 0.0);
    expect(firstCd.minTemperature, 29.0);

    // Test events (in samples)
    final allEvents = firstCd.samples.expand((s) => s.events).toList();
    expect(allEvents.length, greaterThan(0));
    expect(allEvents[0].type, SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE);
    expect(allEvents[0].value, 0); // cylinder idx

    // Test samples
    expect(firstCd.samples.length, greaterThan(0));
    expect(firstCd.samples[0].depth, closeTo(1.1, 0.01));
    expect(firstCd.samples[0].temperature, closeTo(30.0, 0.01));

    // Test last dive
    final lastDive = ssrf.dives[53];
    expect(lastDive.number, 310);
    expect(lastDive.duration, 87 * 60 + 54);
    expect(lastDive.logs.length, greaterThan(0));
    expect(lastDive.logs[0].maxDepth, 22.6);
    expect(lastDive.logs[0].avgDepth, closeTo(12.489, 0.001));
  });

  test('Serialize and deserialize SSRF data', () {
    // Create test data
    final originalSsrf = Container(
      dives: [
        Dive(number: 1, start: proto.Timestamp.fromDateTime(DateTime(2019, 10, 30, 10, 49, 15)), duration: 43 * 60 + 30, rating: 2)
          ..logs.add(Log(maxDepth: 8.88, avgDepth: 4.952)),
        Dive(number: 2, start: proto.Timestamp.fromDateTime(DateTime(2019, 10, 31, 10, 25, 0)), duration: 41 * 60 + 30, rating: 3)
          ..logs.add(Log(maxDepth: 10.5, avgDepth: 5.2)),
      ],
      sites: [Site(id: 'abcd1234', name: 'Test Site', position: Position(latitude: 37.7749, longitude: -122.4194))],
    );

    // Serialize to XML
    final xmlDoc = originalSsrf.toXmlDocument();
    final xmlString = xmlDoc.toXmlString(pretty: true);

    // Parse back
    final parsedDoc = XmlDocument.parse(xmlString);
    final parsedSsrf = SsrfXml.fromXml(parsedDoc.rootElement);

    // Verify basic structure preserved
    expect(parsedSsrf.dives.length, 2);
    expect(parsedSsrf.sites.length, 1);

    // Verify dive data preserved
    expect(parsedSsrf.dives[0].number, 1);
    expect(parsedSsrf.dives[0].rating, 2);
    expect(parsedSsrf.dives[0].logs.length, 1);
    expect(parsedSsrf.dives[0].logs[0].maxDepth, closeTo(8.88, 0.01));

    // Verify dive site preserved
    expect(parsedSsrf.sites[0].id, 'abcd1234');
    expect(parsedSsrf.sites[0].name, 'Test Site');
  });

  test('XML with Log samples and events', () {
    final dive = Dive(number: 1, start: proto.Timestamp.fromDateTime(DateTime(2024, 6, 15, 10, 30, 0)), duration: 30 * 60)
      ..logs.add(
        Log(
          model: 'Suunto EON Core',
          serial: '12345',
          maxDepth: 20.0,
          avgDepth: 12.0,
          surfaceTemperature: 28.0,
          minTemperature: 22.0,
          samples: [
            LogSample(time: 0, depth: 0.0, events: [SampleEvent(type: SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE, time: 0, flags: 0, value: 0)]),
            LogSample(time: 60, depth: 10.0, temperature: 25.0),
            LogSample(time: 120, depth: 20.0, temperature: 22.0),
          ],
        ),
      );

    final ssrf = Container(dives: [dive], sites: []);
    final xmlDoc = ssrf.toXmlDocument();
    final xmlString = xmlDoc.toXmlString(pretty: true);

    // Parse back
    final parsedDoc = XmlDocument.parse(xmlString);
    final parsedSsrf = SsrfXml.fromXml(parsedDoc.rootElement);

    expect(parsedSsrf.dives.length, 1);
    final parsedDive = parsedSsrf.dives[0];
    expect(parsedDive.logs.length, 1);

    final cd = parsedDive.logs[0];
    expect(cd.model, 'Suunto EON Core');
    expect(cd.serial, '12345');
    expect(cd.samples.length, 3);
    final allEvents = cd.samples.expand((s) => s.events).toList();
    expect(allEvents.length, 1);
    expect(allEvents[0].type, SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE);
  });

  test('DiveCylinderXml parsing', () {
    const xml = '<cylinder size="11.0 l" workpressure="230.0 bar" description="AL80" start="200.0 bar" end="50.0 bar" o2="32.0%" />';
    final elem = XmlDocument.parse(xml).rootElement;
    final cyl = DiveCylinderXml.fromXml(elem);

    expect(cyl.cylinder.volumeL, 11.0);
    expect(cyl.cylinder.workingPressureBar, 230.0);
    expect(cyl.cylinder.description, 'AL80');
    expect(cyl.beginPressure, 200.0);
    expect(cyl.endPressure, 50.0);
    expect(cyl.oxygen, 0.32);
  });

  test('DiveCylinderXml serialization', () {
    final cyl = DiveCylinder(
      cylinder: Cylinder(volumeL: 12.0, workingPressureBar: 200.0, description: 'Steel'),
      beginPressure: 200.0,
      endPressure: 50.0,
      oxygen: 0.32,
      helium: 0.10,
    );

    final elem = cyl.toXml();
    expect(elem.getAttribute('description'), 'Steel');
    expect(elem.getAttribute('size'), '12.0 l');
    expect(elem.getAttribute('o2'), '32.0%');
    expect(elem.getAttribute('he'), '10.0%');
  });
}
