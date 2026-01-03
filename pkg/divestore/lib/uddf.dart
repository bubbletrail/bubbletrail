import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import 'divestore.dart';

const double _kelvinOffset = 273.15;
const double _pascalToBar = 1e-5;
const double _cubicMeterToLiter = 1000.0;

double? _kelvinToCelsius(double? k) => k != null ? k - _kelvinOffset : null;
double? _pascalToBarConvert(double? pa) => pa != null ? pa * _pascalToBar : null;

/// Convert tank volume to liters.
/// UDDF spec says m³ (SI), but some programs (e.g., Subsurface) export in liters.
/// Heuristic: if value < 1, assume m³ and convert; otherwise assume liters.
double? _tankVolumeToLiters(double? vol) {
  if (vol == null) return null;
  if (vol < 1) {
    return vol * _cubicMeterToLiter;
  }
  return vol;
}

/// Helper class for gas mix definitions
class _GasMix {
  final String id;
  final String name;
  final double oxygen;
  final double helium;

  _GasMix({required this.id, required this.name, required this.oxygen, required this.helium});
}

/// Helper class for buddy info
class _Buddy {
  final String id;
  final String firstName;
  final String lastName;

  _Buddy({required this.id, required this.firstName, required this.lastName});

  String get fullName => '$firstName $lastName'.trim();
}

extension UddfXml on Ssrf {
  /// Parse UDDF XML and return an Ssrf container with dives and sites.
  static Ssrf fromXml(XmlElement elem) {
    // Parse gas definitions (referenced by dives)
    final gasMixes = <String, _GasMix>{};
    final gasDefs = elem.getElement('gasdefinitions');
    if (gasDefs != null) {
      for (final mix in gasDefs.findElements('mix')) {
        final id = mix.getAttribute('id');
        if (id != null) {
          gasMixes[id] = _GasMix(
            id: id,
            name: _getElementText(mix, 'name') ?? '',
            oxygen: double.tryParse(_getElementText(mix, 'o2') ?? '') ?? 0.21,
            helium: double.tryParse(_getElementText(mix, 'he') ?? '') ?? 0.0,
          );
        }
      }
    }

    // Parse buddies (referenced by dives)
    final buddies = <String, _Buddy>{};
    final diverElem = elem.getElement('diver');
    if (diverElem != null) {
      for (final buddy in diverElem.findElements('buddy')) {
        final id = buddy.getAttribute('id');
        if (id != null) {
          final personal = buddy.getElement('personal');
          buddies[id] = _Buddy(id: id, firstName: _getElementText(personal, 'firstname') ?? '', lastName: _getElementText(personal, 'lastname') ?? '');
        }
      }
    }

    // Parse sites
    final sites = <Site>[];
    final sitesById = <String, Site>{};
    final divesiteElem = elem.getElement('divesite');
    if (divesiteElem != null) {
      for (final siteElem in divesiteElem.findElements('site')) {
        final site = _UddfSite.fromXml(siteElem);
        sites.add(site);
        sitesById[site.id] = site;
      }
    }

    // Parse dives
    final dives = <Dive>[];
    final profileData = elem.getElement('profiledata');
    if (profileData != null) {
      for (final repGroup in profileData.findElements('repetitiongroup')) {
        for (final diveElem in repGroup.findElements('dive')) {
          final dive = _UddfDive.fromXml(diveElem, gasMixes, buddies, sitesById);
          dives.add(dive);
        }
      }
    }

    return Ssrf(dives: dives, sites: sites);
  }
}

extension _UddfSite on Site {
  static Site fromXml(XmlElement elem) {
    final id = elem.getAttribute('id') ?? const Uuid().v4();
    final name = _getElementText(elem, 'name') ?? '';

    final geography = elem.getElement('geography');
    Position? position;
    String? country;
    String? location;

    if (geography != null) {
      final lat = double.tryParse(_getElementText(geography, 'latitude') ?? '');
      final lon = double.tryParse(_getElementText(geography, 'longitude') ?? '');
      if (lat != null && lon != null) {
        position = Position(latitude: lat, longitude: lon);
      }

      final address = geography.getElement('address');
      if (address != null) {
        country = _getElementText(address, 'country');
      }
      location = _getElementText(geography, 'location');
    }

    return Site(id: id, name: name, position: position, country: country, location: location);
  }
}

extension _UddfDive on Dive {
  static Dive fromXml(XmlElement elem, Map<String, _GasMix> gasMixes, Map<String, _Buddy> buddies, Map<String, Site> sitesById) {
    final diveId = elem.getAttribute('id') ?? const Uuid().v4();

    final infoBefore = elem.getElement('informationbeforedive');
    final infoAfter = elem.getElement('informationafterdive');

    // Parse datetime
    DateTime? dateTime;
    final dateTimeStr = _getElementText(infoBefore, 'datetime');
    if (dateTimeStr != null) {
      dateTime = DateTime.tryParse(dateTimeStr);
    }

    // Parse dive number
    final diveNumber = int.tryParse(_getElementText(infoBefore, 'divenumber') ?? '') ?? 0;

    // Parse links to sites and buddies
    String? siteId;
    final buddyNames = <String>[];

    if (infoBefore != null) {
      for (final link in infoBefore.findElements('link')) {
        final ref = link.getAttribute('ref');
        if (ref != null) {
          if (sitesById.containsKey(ref)) {
            siteId = ref;
          } else if (buddies.containsKey(ref)) {
            buddyNames.add(buddies[ref]!.fullName);
          }
        }
      }
    }

    // Parse air temperature from informationbeforedive (Subsurface style)
    final airTemp = _kelvinToCelsius(double.tryParse(_getElementText(infoBefore, 'airtemperature') ?? ''));

    // Parse lead weight from equipmentused (Subsurface style)
    final weightsystems = <Weightsystem>[];
    final equipUsed = infoBefore?.getElement('equipmentused');
    if (equipUsed != null) {
      final leadQty = double.tryParse(_getElementText(equipUsed, 'leadquantity') ?? '');
      if (leadQty != null && leadQty > 0) {
        weightsystems.add(Weightsystem(weight: leadQty, description: 'Lead'));
      }
    }

    // Parse after-dive info
    final greatestDepth = double.tryParse(_getElementText(infoAfter, 'greatestdepth') ?? '');
    final diveDuration = double.tryParse(_getElementText(infoAfter, 'diveduration') ?? '');
    final lowestTemp = _kelvinToCelsius(double.tryParse(_getElementText(infoAfter, 'lowesttemperature') ?? ''));

    // Parse rating
    final ratingElem = infoAfter?.getElement('rating');
    final rating = int.tryParse(_getElementText(ratingElem, 'ratingvalue') ?? '');

    // Parse notes - may have <para> wrapper or plain text
    final notesElem = infoAfter?.getElement('notes');
    String? notes;
    if (notesElem != null) {
      final para = notesElem.getElement('para');
      if (para != null) {
        notes = para.innerText.trim();
      } else {
        notes = notesElem.innerText.trim();
      }
      if (notes.isEmpty) notes = null;
    }

    // Parse tank data
    final cylinders = <DiveCylinder>[];
    for (final tankData in elem.findElements('tankdata')) {
      final cylinder = _parseTankData(tankData, gasMixes);
      if (cylinder != null) {
        cylinders.add(cylinder);
      }
    }

    // Parse samples
    final samples = <LogSample>[];
    final samplesElem = elem.getElement('samples');
    if (samplesElem != null) {
      for (final waypoint in samplesElem.findElements('waypoint')) {
        final sample = _parseWaypoint(waypoint, gasMixes);
        if (sample != null) {
          samples.add(sample);
        }
      }
    }

    // Create log from samples
    final log = Log(maxDepth: greatestDepth, minTemperature: lowestTemp, surfaceTemperature: airTemp);
    log.samples.addAll(samples);

    // Set log time
    if (dateTime != null) {
      log.dateTime = Timestamp.fromDateTime(dateTime);
    }

    // Create dive
    final dive = Dive(
      id: diveId,
      number: diveNumber,
      start: dateTime != null ? Timestamp.fromDateTime(dateTime) : null,
      duration: diveDuration?.toInt(),
      maxDepth: greatestDepth,
      rating: rating,
      siteId: siteId,
      notes: notes,
    );

    dive.buddies.addAll(buddyNames);
    dive.cylinders.addAll(cylinders);
    dive.weightsystems.addAll(weightsystems);
    dive.logs.add(log);

    return dive;
  }
}

DiveCylinder? _parseTankData(XmlElement tankData, Map<String, _GasMix> gasMixes) {
  // Get gas mix from link
  double oxygen = 0.21;
  double helium = 0.0;

  for (final link in tankData.findElements('link')) {
    final ref = link.getAttribute('ref');
    if (ref != null && gasMixes.containsKey(ref)) {
      final mix = gasMixes[ref]!;
      oxygen = mix.oxygen;
      helium = mix.helium;
      break;
    }
  }

  // Parse tank volume (may be m³ or liters depending on exporter)
  final tankVolume = _tankVolumeToLiters(double.tryParse(_getElementText(tankData, 'tankvolume') ?? ''));

  // Parse pressures (Pa -> bar)
  final beginPressure = _pascalToBarConvert(double.tryParse(_getElementText(tankData, 'tankpressurebegin') ?? ''));
  final endPressure = _pascalToBarConvert(double.tryParse(_getElementText(tankData, 'tankpressureend') ?? ''));

  return DiveCylinder(
    cylinder: Cylinder(size: tankVolume),
    oxygen: oxygen,
    helium: helium,
    beginPressure: beginPressure,
    endPressure: endPressure,
  );
}

LogSample? _parseWaypoint(XmlElement waypoint, Map<String, _GasMix> gasMixes) {
  final depth = double.tryParse(_getElementText(waypoint, 'depth') ?? '');
  final diveTime = double.tryParse(_getElementText(waypoint, 'divetime') ?? '');

  if (diveTime == null) return null;

  // Temperature (K -> °C)
  final temp = _kelvinToCelsius(double.tryParse(_getElementText(waypoint, 'temperature') ?? ''));

  // Tank pressure (Pa -> bar)
  final tankPressure = _pascalToBarConvert(double.tryParse(_getElementText(waypoint, 'tankpressure') ?? ''));

  final sample = LogSample(time: diveTime, depth: depth, temperature: temp);

  if (tankPressure != null) {
    sample.pressures.add(TankPressure(tankIndex: 0, pressure: tankPressure));
  }

  // Check for gas switch
  final switchMix = waypoint.getElement('switchmix');
  if (switchMix != null) {
    final ref = switchMix.getAttribute('ref');
    if (ref != null && gasMixes.containsKey(ref)) {
      sample.events.add(SampleEvent(type: SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE, time: diveTime.toInt()));
    }
  }

  return sample;
}

/// Get text content of a child element.
String? _getElementText(XmlElement? parent, String name) {
  if (parent == null) return null;
  final elem = parent.getElement(name);
  if (elem == null) return null;
  final text = elem.innerText.trim();
  return text.isEmpty ? null : text;
}
