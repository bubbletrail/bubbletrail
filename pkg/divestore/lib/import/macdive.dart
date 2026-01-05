import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:xml/xml.dart';

import '../gen/gen.dart';
import 'container.dart';

extension MacDiveXml on Ssrf {
  /// Parse MacDive XML and return an Ssrf container with dives and sites.
  static Ssrf fromXml(XmlElement elem) {
    final dives = <Dive>[];
    final sites = <Site>[];
    final sitesByKey = <String, Site>{};

    for (final diveElem in elem.findElements('dive')) {
      final result = _MacDiveDive.fromXml(diveElem, sitesByKey);
      dives.add(result.dive);
      if (result.site != null && !sitesByKey.containsKey(_siteKey(result.site!))) {
        sitesByKey[_siteKey(result.site!)] = result.site!;
        sites.add(result.site!);
      }
    }

    return Ssrf(dives: dives, sites: sites);
  }
}

/// Generate a key for deduplicating sites based on name and coordinates.
String _siteKey(Site site) {
  if (site.hasPosition()) {
    return '${site.name}|${site.position.latitude.toStringAsFixed(5)}|${site.position.longitude.toStringAsFixed(5)}';
  }
  return site.name;
}

class _DiveResult {
  final Dive dive;
  final Site? site;

  _DiveResult({required this.dive, this.site});
}

extension _MacDiveDive on Dive {
  static _DiveResult fromXml(XmlElement elem, Map<String, Site> sitesByKey) {
    // Parse identifier as dive ID
    final diveId = _getElementText(elem, 'identifier') ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Parse datetime
    final dateStr = _getElementText(elem, 'date');
    DateTime? dateTime;
    if (dateStr != null) {
      // Format: "2024-12-28 09:59:02"
      dateTime = DateTime.tryParse(dateStr.replaceFirst(' ', 'T'));
    }

    // Parse dive number
    final diveNumber = int.tryParse(_getElementText(elem, 'diveNumber') ?? '') ?? 0;

    // Parse rating
    final rating = int.tryParse(_getElementText(elem, 'rating') ?? '');

    // Parse depth
    final maxDepth = double.tryParse(_getElementText(elem, 'maxDepth') ?? '');
    final avgDepth = double.tryParse(_getElementText(elem, 'averageDepth') ?? '');

    // Parse duration (in seconds)
    final duration = int.tryParse(_getElementText(elem, 'duration') ?? '');

    // Parse temperatures
    final tempAir = double.tryParse(_getElementText(elem, 'tempAir') ?? '');
    final tempLow = double.tryParse(_getElementText(elem, 'tempLow') ?? '');

    // Parse CNS (may be decimal like "5.00")
    final cns = double.tryParse(_getElementText(elem, 'cns') ?? '')?.toInt();

    // Parse notes
    final notes = _getElementText(elem, 'notes');

    // Parse dive computer info
    final computerModel = _getElementText(elem, 'computer') ?? 'Unknown';
    final computerSerial = _getElementText(elem, 'serial');

    // Parse site
    Site? site;
    String? siteId;
    final siteElem = elem.getElement('site');
    if (siteElem != null) {
      site = _MacDiveSite.fromXml(siteElem);
      final key = _siteKey(site);
      if (sitesByKey.containsKey(key)) {
        site = sitesByKey[key];
      }
      siteId = site?.id;
    }

    // Parse tags
    final tags = <String>[];
    final tagsElem = elem.getElement('tags');
    if (tagsElem != null) {
      for (final tagElem in tagsElem.findElements('tag')) {
        final tag = tagElem.innerText.trim();
        if (tag.isNotEmpty) {
          tags.add(tag);
        }
      }
    }

    // Parse buddies
    final buddies = <String>[];
    final buddiesElem = elem.getElement('buddies');
    if (buddiesElem != null) {
      for (final buddyElem in buddiesElem.findElements('buddy')) {
        final buddy = buddyElem.innerText.trim();
        if (buddy.isNotEmpty) {
          buddies.add(buddy);
        }
      }
    }

    // Parse gases/cylinders
    final cylinders = <DiveCylinder>[];
    final gasesElem = elem.getElement('gases');
    if (gasesElem != null) {
      for (final gasElem in gasesElem.findElements('gas')) {
        final cylinder = _parseGas(gasElem);
        cylinders.add(cylinder);
      }
    }

    // Parse weight (may be comma-separated like "4wb, 2trim, 2pkt")
    final weightsystems = <Weightsystem>[];
    final weightStr = _getElementText(elem, 'weight');
    if (weightStr != null && weightStr.isNotEmpty) {
      weightsystems.addAll(_parseWeightSystems(weightStr));
    }

    // Parse samples
    final samples = <LogSample>[];
    final samplesElem = elem.getElement('samples');
    if (samplesElem != null) {
      for (final sampleElem in samplesElem.findElements('sample')) {
        final sample = _parseSample(sampleElem);
        if (sample != null) {
          samples.add(sample);
        }
      }
    }

    // Create log from samples
    final log = Log(model: computerModel, serial: computerSerial, maxDepth: maxDepth, avgDepth: avgDepth, surfaceTemperature: tempAir, minTemperature: tempLow);
    log.samples.addAll(samples);

    // Set log time
    if (dateTime != null) {
      log.dateTime = Timestamp.fromDateTime(dateTime);
    }

    log.setUniqueID();

    // Create dive
    final dive = Dive(
      id: diveId,
      number: diveNumber,
      start: dateTime != null ? Timestamp.fromDateTime(dateTime) : null,
      duration: duration,
      maxDepth: maxDepth,
      meanDepth: avgDepth,
      rating: rating,
      siteId: siteId,
      notes: notes,
      cns: cns,
    );

    dive.tags.addAll(tags);
    dive.buddies.addAll(buddies);
    dive.cylinders.addAll(cylinders);
    dive.weightsystems.addAll(weightsystems);
    dive.logs.add(log);

    return _DiveResult(dive: dive, site: site);
  }
}

extension _MacDiveSite on Site {
  static Site fromXml(XmlElement elem) {
    final name = _getElementText(elem, 'name') ?? '';
    final country = _getElementText(elem, 'country');
    final location = _getElementText(elem, 'location');
    final bodyOfWater = _getElementText(elem, 'bodyOfWater');
    final difficulty = _getElementText(elem, 'difficulty');

    // Parse coordinates
    Position? position;
    final lat = double.tryParse(_getElementText(elem, 'lat') ?? '');
    final lon = double.tryParse(_getElementText(elem, 'lon') ?? '');
    if (lat != null && lon != null && (lat != 0 || lon != 0)) {
      position = Position(latitude: lat, longitude: lon);
    }

    // Generate a stable ID from name and coordinates
    final id = _generateSiteId(name, position);

    return Site(id: id, name: name, position: position, country: country, location: location, bodyOfWater: bodyOfWater, difficulty: difficulty);
  }
}

String _generateSiteId(String name, Position? position) {
  // Create a stable ID from the site name and coordinates
  final buffer = StringBuffer();
  buffer.write(name);
  if (position != null) {
    buffer.write('|${position.latitude.toStringAsFixed(5)}|${position.longitude.toStringAsFixed(5)}');
  }
  // Simple hash to create a UUID-like string
  final hash = buffer.toString().hashCode.toUnsigned(32).toRadixString(16).padLeft(8, '0');
  return 'macdive-$hash';
}

DiveCylinder _parseGas(XmlElement elem) {
  final oxygen = double.tryParse(_getElementText(elem, 'oxygen') ?? '');
  final helium = double.tryParse(_getElementText(elem, 'helium') ?? '');
  final tankSize = double.tryParse(_getElementText(elem, 'tankSize') ?? '');
  final workingPressure = double.tryParse(_getElementText(elem, 'workingPressure') ?? '');
  final pressureStart = double.tryParse(_getElementText(elem, 'pressureStart') ?? '');
  final pressureEnd = double.tryParse(_getElementText(elem, 'pressureEnd') ?? '');
  final tankName = _getElementText(elem, 'tankName');

  return DiveCylinder(
    cylinder: Cylinder(size: tankSize, workpressure: workingPressure, description: tankName),
    oxygen: oxygen != null ? oxygen / 100.0 : null, // Convert from percentage
    helium: helium != null ? helium / 100.0 : null, // Convert from percentage
    beginPressure: pressureStart,
    endPressure: pressureEnd,
  );
}

LogSample? _parseSample(XmlElement elem) {
  final time = double.tryParse(_getElementText(elem, 'time') ?? '');
  if (time == null) return null;

  final depth = double.tryParse(_getElementText(elem, 'depth') ?? '');
  final temp = double.tryParse(_getElementText(elem, 'temperature') ?? '');
  final pressure = double.tryParse(_getElementText(elem, 'pressure') ?? '');
  final ndtStr = _getElementText(elem, 'ndt');
  final ndt = int.tryParse(ndtStr ?? '');

  final sample = LogSample(time: time, depth: depth, temperature: temp);

  // Add pressure if present
  if (pressure != null) {
    sample.pressures.add(TankPressure(tankIndex: 0, pressure: pressure));
  }

  // Add NDL info if present
  if (ndt != null && ndt > 0) {
    sample.deco = DecoStatus(
      type: DecoStopType.DECO_STOP_TYPE_NDL,
      time: ndt * 60, // Convert minutes to seconds
      depth: 0,
    );
  }

  return sample;
}

/// Weight type abbreviation mappings to human-readable descriptions.
const _weightTypeDescriptions = <String, String>{
  'wb': 'Weight belt',
  'trim': 'Trim pockets',
  'pkt': 'Pockets',
  'pocket': 'Pockets',
  'pockets': 'Pockets',
  'pw': 'Plate weight',
  'vw': 'V-weight',
  'bp': 'Backplate',
  'backplate': 'Backplate',
  'ankle': 'Ankle weights',
  'int': 'Integrated',
  'integrated': 'Integrated',
  'ditchable': 'Ditchable',
  'kg': 'Weight',
};

/// Parse weight string which may be comma-separated like "4wb, 2trim, 2pkt".
/// Returns a list of Weightsystem entries, one for each component.
List<Weightsystem> _parseWeightSystems(String weightStr) {
  final result = <Weightsystem>[];

  // Split by comma and process each part
  final parts = weightStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);

  for (final part in parts) {
    final parsed = _parseWeightPart(part);
    if (parsed != null) {
      result.add(parsed);
    }
  }

  // If no parts were parsed but the string has a number, try parsing as a single weight
  if (result.isEmpty) {
    final numMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(weightStr);
    if (numMatch != null) {
      final weight = double.tryParse(numMatch.group(1)!);
      if (weight != null) {
        result.add(Weightsystem(weight: weight, description: weightStr));
      }
    }
  }

  return result;
}

/// Parse a single weight part like "4wb" or "2.5 trim" or "3kg".
Weightsystem? _parseWeightPart(String part) {
  // Pattern: optional whitespace, number, optional whitespace, type abbreviation
  // Examples: "4wb", "2.5trim", "3 pkt", "2.0 kg"
  final pattern = RegExp(r'^(\d+(?:\.\d+)?)\s*([a-zA-Z]+)?$');
  final match = pattern.firstMatch(part);

  if (match == null) {
    // Try reverse pattern: type then number (less common but possible)
    final reversePattern = RegExp(r'^([a-zA-Z]+)\s*(\d+(?:\.\d+)?)$');
    final reverseMatch = reversePattern.firstMatch(part);
    if (reverseMatch != null) {
      final weight = double.tryParse(reverseMatch.group(2)!);
      final typeAbbrev = reverseMatch.group(1)!.toLowerCase();
      if (weight != null) {
        final description = _weightTypeDescriptions[typeAbbrev] ?? typeAbbrev;
        return Weightsystem(weight: weight, description: description);
      }
    }
    return null;
  }

  final weight = double.tryParse(match.group(1)!);
  if (weight == null) return null;

  final typeAbbrev = match.group(2)?.toLowerCase();
  if (typeAbbrev == null || typeAbbrev.isEmpty) {
    // Just a number, no type
    return Weightsystem(weight: weight, description: 'Weight');
  }

  final description = _weightTypeDescriptions[typeAbbrev] ?? typeAbbrev;
  return Weightsystem(weight: weight, description: description);
}

/// Get text content of a child element.
String? _getElementText(XmlElement? parent, String name) {
  if (parent == null) return null;
  final elem = parent.getElement(name);
  if (elem == null) return null;
  final text = elem.innerText.trim();
  return text.isEmpty ? null : text;
}
