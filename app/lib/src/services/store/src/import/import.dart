import 'dart:convert';

import 'package:xml/xml.dart';

import 'container.dart';
import 'macdive.dart';
import 'ssrf.dart';
import 'suunto_json.dart';
import 'uddf.dart';

export 'container.dart';
export 'macdive.dart';
export 'ssrf.dart';
export 'suunto_json.dart';
export 'uddf.dart';

/// Supported dive log formats (XML and JSON based).
enum DiveLogFormat { uddf, subsurface, macdive, suuntoJson, unknown }

/// Detects the format of a dive log XML document.
DiveLogFormat detectXmlFormat(XmlDocument doc) {
  final root = doc.rootElement;
  final rootName = root.name.local.toLowerCase();

  // UDDF: root element is <uddf>
  if (rootName == 'uddf') {
    return DiveLogFormat.uddf;
  }

  // Subsurface: root element is <divelog> with program="subsurface"
  if (rootName == 'divelog') {
    final program = root.getAttribute('program')?.toLowerCase();
    if (program == 'subsurface') {
      return DiveLogFormat.subsurface;
    }
  }

  // MacDive: root element is <dives> with <schema> child or <units> child
  if (rootName == 'dives') {
    if (root.getElement('schema') != null || root.getElement('units') != null) {
      return DiveLogFormat.macdive;
    }
  }

  return DiveLogFormat.unknown;
}

/// Import dive log data from an XML document, auto-detecting the format.
///
/// Throws [FormatException] if the format cannot be detected.
Container importXml(XmlDocument doc) {
  final format = detectXmlFormat(doc);

  switch (format) {
    case DiveLogFormat.uddf:
      return UddfXml.fromXml(doc.rootElement);
    case DiveLogFormat.subsurface:
      return SsrfXml.fromXml(doc.rootElement);
    case DiveLogFormat.macdive:
      return MacDiveXml.fromXml(doc.rootElement);
    case DiveLogFormat.suuntoJson:
    case DiveLogFormat.unknown:
      throw FormatException('Unknown dive log XML format: root element is <${doc.rootElement.name.local}>');
  }
}

/// Import dive log data from an XML string, auto-detecting the format.
///
/// Throws [FormatException] if the format cannot be detected.
/// Throws [XmlParserException] if the XML is malformed.
Container importXmlString(String xmlString) {
  final doc = XmlDocument.parse(xmlString);
  return importXml(doc);
}

/// Import dive log data from raw file content, auto-detecting XML versus JSON.
///
/// Throws [FormatException] if the format cannot be detected.
Container importString(String content) {
  final trimmed = content.trimLeft();
  if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
    return importJsonString(content);
  }
  return importXmlString(content);
}

/// Import dive log data from a JSON string, auto-detecting the format.
///
/// Throws [FormatException] if the format cannot be detected.
Container importJsonString(String jsonString) {
  final decoded = jsonDecode(jsonString);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Unsupported JSON dive log structure');
  }
  return importJson(decoded);
}

/// Import dive log data from a decoded JSON map, auto-detecting the format.
///
/// Throws [FormatException] if the format cannot be detected.
Container importJson(Map<String, dynamic> json) {
  // Suunto JSON: top-level "DeviceLog" object.
  if (json.containsKey('DeviceLog')) {
    return SuuntoJson.fromJson(json);
  }
  throw const FormatException('Unknown JSON dive log format');
}
