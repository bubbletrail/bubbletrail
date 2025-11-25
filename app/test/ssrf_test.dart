// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:yadl/src/ssrf/ssrf.dart';

void main() {
  test('Load sample SSRF file', () async {
    final xmlData = await File('./test/testdata/jakob@nym.se.ssrf').readAsString();
    final doc = XmlDocument.parse(xmlData);
    final ssrf = Ssrf.fromXml(doc.rootElement);
    expect(ssrf.dives.length, 317);
    expect(ssrf.dives[316].number, 307);
    expect(ssrf.dives[316].duration, 75 * 60 + 24);
    expect(ssrf.dives[316].maxDepth, 34.8);
    expect(ssrf.dives[316].meanDepth, 19.385);
  });

  test('Serialize and deserialize SSRF data', () {
    // Create test data
    final originalSsrf = Ssrf(dives: [
      Dive(
        number: 1,
        start: DateTime(2019, 10, 30, 10, 49, 15),
        duration: 43 * 60 + 30,
        maxDepth: 8.88,
        meanDepth: 4.952,
        rating: 2,
      ),
      Dive(
        number: 2,
        start: DateTime(2019, 10, 31, 10, 25, 0),
        duration: 41 * 60 + 30,
        maxDepth: 10.5,
        meanDepth: 5.2,
        rating: 3,
      ),
    ]);

    // Add a divesite
    originalSsrf.diveSites.add(
      const Divesite(
        uuid: 'test-uuid-123',
        name: 'Test Site',
        position: GPSPosition(56.179390, 15.070710),
      ),
    );

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
    expect(deserializedSsrf.dives[0].maxDepth, 8.88);
    expect(deserializedSsrf.dives[0].meanDepth, 4.952);
    expect(deserializedSsrf.dives[0].rating, 2);

    expect(deserializedSsrf.dives[1].number, 2);
    expect(deserializedSsrf.dives[1].duration, 41 * 60 + 30);
    expect(deserializedSsrf.dives[1].maxDepth, 10.5);
    expect(deserializedSsrf.dives[1].meanDepth, 5.2);
    expect(deserializedSsrf.dives[1].rating, 3);
  });

  test('Serialize dive with tags and environment', () {
    final dive = Dive(
      number: 42,
      start: DateTime(2023, 6, 15, 14, 30, 0),
      duration: 3600,
      maxDepth: 25.5,
      meanDepth: 15.2,
      rating: 5,
      environment: Environment(
        airTemperature: 22.5,
        waterTemperature: 18.3,
      ),
    );
    dive.tags.addAll(['Boat', 'Wet', 'Deep']);

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
    const sample = Sample(
      time: 125.5,
      depth: 8.88,
      temp: 10.5,
      pressure: 200.0,
    );

    final xmlElement = sample.toXml();
    final xmlString = xmlElement.toXmlString();

    print('Sample XML: $xmlString');

    expect(xmlElement.getAttribute('time'), '2:06 min');
    expect(xmlElement.getAttribute('depth'), '8.88 m');
    expect(xmlElement.getAttribute('temp'), '10.5 C');
    expect(xmlElement.getAttribute('pressure'), '200.0 bar');
  });

  test('Serialize divesite with GPS', () {
    const site = Divesite(
      uuid: 'abc123',
      name: 'Beautiful Reef',
      position: GPSPosition(56.179390, 15.070710),
    );

    final xmlElement = site.toXml();
    final xmlString = xmlElement.toXmlString();

    print('Divesite XML: $xmlString');

    expect(xmlElement.getAttribute('uuid'), 'abc123');
    expect(xmlElement.getAttribute('name'), 'Beautiful Reef');
    expect(xmlElement.getAttribute('gps'), '56.179390 15.070710');
  });
}
