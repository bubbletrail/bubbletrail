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
}
