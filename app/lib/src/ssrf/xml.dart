import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import 'formatting.dart';
import 'types.dart';

extension SsrfXml on Ssrf {
  static fromXml(XmlElement elem) {
    final settingsElem = elem.getElement('settings');
    final divesitesElem = elem.getElement('divesites');
    final divesElem = elem.getElement('dives');

    var dives = divesElem?.findElements('dive').map(DiveXml.fromXml).toList() ?? [];
    dives.addAll(divesElem?.findAllElements('trip').map((e) => e.findElements('dive').map(DiveXml.fromXml).toList()).flattened ?? []);

    return Ssrf(
      settings: settingsElem != null ? SettingsXml.fromXml(settingsElem) : null,
      dives: dives,
      diveSites: divesitesElem?.findElements('site').map(DivesiteXml.fromXml).toList() ?? [],
    );
  }

  XmlDocument toXmlDocument() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element(
      'divelog',
      nest: () {
        builder.attribute('program', 'subsurface');
        builder.attribute('version', '3');

        // Add settings section
        if (settings != null) {
          builder.xml(settings!.toXml().toXmlString());
        }

        // Add divesites section
        if (diveSites.isNotEmpty) {
          builder.element(
            'divesites',
            nest: () {
              for (final site in diveSites) {
                builder.xml(site.toXml().toXmlString());
              }
            },
          );
        }

        // Add dives section
        builder.element(
          'dives',
          nest: () {
            for (final dive in dives) {
              builder.xml(dive.toXml().toXmlString());
            }
          },
        );
      },
    );

    return builder.buildDocument();
  }
}

extension DiveXml on Dive {
  static Dive fromXml(XmlElement elem) {
    // Dive ID or null
    final diveID = elem.getAttribute('uuid');

    // Parse tags
    final tagsStr = elem.getAttribute('tags');
    final tags = tagsStr != null ? tagsStr.split(',').map((t) => t.trim()).toSet() : <String>{};

    // Parse buddies
    final buddyStr = elem.getElement('buddy')?.innerText;
    final buddies = buddyStr != null ? buddyStr.split(',').map((b) => b.trim()).toSet() : <String>{};

    // Parse cns percentage (remove '%' sign if present)
    final cnsStr = elem.getAttribute('cns');
    int? cns;
    if (cnsStr != null) {
      final cnsNumStr = cnsStr.replaceAll('%', '').trim();
      cns = int.tryParse(cnsNumStr);
    }

    final dive = Dive(
      id: diveID,
      number: int.tryParse(elem.getAttribute('number') ?? '0') ?? 0,
      start: tryParseDateTime(elem.getAttribute('date'), elem.getAttribute('time')) ?? DateTime.fromMillisecondsSinceEpoch(0),
      duration: tryParseUnitString(elem.getAttribute('duration')) ?? 0,
      rating: int.tryParse(elem.getAttribute('rating') ?? ''),
      sac: tryParseUnitString(elem.getAttribute('sac')),
      otu: int.tryParse(elem.getAttribute('otu') ?? ''),
      cns: cns,
      divesiteid: elem.getAttribute('divesiteid'),
      divemaster: elem.getElement('divemaster')?.innerText,
      notes: elem.getElement('notes')?.innerText,
    );

    dive.tags = tags;
    dive.buddies = buddies;

    // Parse cylinders
    dive.cylinders = elem.findElements('cylinder').map(CylinderXml.fromXml).toList();

    // Parse weightsystems
    dive.weightsystems = elem.findElements('weightsystem').map(WeightsystemXml.fromXml).toList();

    // Parse divecomputers
    dive.divecomputers = elem.findElements('divecomputer').map(DiveComputerXml.fromXml).toList();

    return dive;
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'dive',
      nest: () {
        builder.attribute('uuid', id);
        builder.attribute('number', number.toString());

        if (rating != null) {
          builder.attribute('rating', rating.toString());
        }

        if (sac != null) {
          builder.attribute('sac', '${sac!.toStringAsFixed(3)} l/min');
        }

        if (otu != null) {
          builder.attribute('otu', otu.toString());
        }

        if (cns != null) {
          builder.attribute('cns', '$cns%');
        }

        if (tags.isNotEmpty) {
          builder.attribute('tags', tags.join(', '));
        }

        if (divesiteid != null) {
          builder.attribute('divesiteid', divesiteid!);
        }

        builder.attribute('date', formatDate(start));
        builder.attribute('time', formatTime(start));
        builder.attribute('duration', formatDuration(duration));

        // Add child elements
        if (divemaster != null) {
          builder.element(
            'divemaster',
            nest: () {
              builder.text(divemaster!);
            },
          );
        }

        if (buddies.isNotEmpty) {
          builder.element(
            'buddy',
            nest: () {
              builder.text(buddies.join(', '));
            },
          );
        }

        if (notes != null) {
          builder.element(
            'notes',
            nest: () {
              builder.text(notes!);
            },
          );
        }

        // Add cylinders
        for (final cylinder in cylinders) {
          builder.xml(cylinder.toXml().toXmlString());
        }

        // Add weightsystems
        for (final weightsystem in weightsystems) {
          builder.xml(weightsystem.toXml().toXmlString());
        }

        // Add divecomputers
        for (final divecomputer in divecomputers) {
          builder.xml(divecomputer.toXml().toXmlString());
        }
      },
    );

    return builder.buildFragment().firstElementChild!;
  }
}

extension DiveComputerXml on DiveComputer {
  static DiveComputer fromXml(XmlElement elem) {
    final depth = elem.getElement('depth');
    final temperature = elem.getElement('temperature');

    // Parse environment from temperature
    Environment? environment;
    if (temperature != null) {
      final airTemp = tryParseUnitString(temperature.getAttribute('air'));
      final waterTemp = tryParseUnitString(temperature.getAttribute('water'));
      if (airTemp != null || waterTemp != null) {
        environment = Environment(airTemperature: airTemp, waterTemperature: waterTemp);
      }
    }

    final divecomputer = DiveComputer(
      maxDepth: tryParseUnitString(depth?.getAttribute('max')) ?? 0,
      meanDepth: tryParseUnitString(depth?.getAttribute('mean')) ?? 0,
      environment: environment,
      samples: elem.findElements('sample').map(SampleXml.fromXml).toList(),
      events: elem.findElements('event').map(EventXml.fromXml).toList(),
    );

    // Parse extradata
    for (final extradataElem in elem.findElements('extradata')) {
      final key = extradataElem.getAttribute('key');
      final value = extradataElem.getAttribute('value');
      if (key != null && value != null) {
        divecomputer.extradata[key] = value;
      }
    }

    return divecomputer;
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'divecomputer',
      nest: () {
        builder.element(
          'depth',
          nest: () {
            builder.attribute('max', formatDepth(maxDepth));
            builder.attribute('mean', formatDepth(meanDepth));
          },
        );

        // Add temperature if environment is present
        if (environment != null) {
          builder.element(
            'temperature',
            nest: () {
              if (environment!.airTemperature != null) {
                builder.attribute('air', formatTemp(environment!.airTemperature!));
              }
              if (environment!.waterTemperature != null) {
                builder.attribute('water', formatTemp(environment!.waterTemperature!));
              }
            },
          );
        }

        // Add extradata
        for (final entry in extradata.entries) {
          builder.element(
            'extradata',
            nest: () {
              builder.attribute('key', entry.key);
              builder.attribute('value', entry.value);
            },
          );
        }

        // Add events
        for (final event in events) {
          builder.xml(event.toXml().toXmlString());
        }

        // Add samples
        for (final sample in samples) {
          builder.xml(sample.toXml().toXmlString());
        }
      },
    );

    return builder.buildFragment().firstElementChild!;
  }
}

extension SampleXml on Sample {
  static Sample fromXml(XmlElement elem) {
    return Sample(
      time: tryParseUnitString(elem.getAttribute('time')) ?? 0,
      depth: tryParseUnitString(elem.getAttribute('depth')) ?? 0,
      temp: tryParseUnitString(elem.getAttribute('temp')),
      pressure: tryParseUnitString(elem.getAttribute('pressure')),
    );
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'sample',
      nest: () {
        builder.attribute('time', formatDuration(time));
        builder.attribute('depth', formatDepth(depth));

        if (temp != null) {
          builder.attribute('temp', formatTemp(temp!));
        }

        if (pressure != null) {
          builder.attribute('pressure', '${pressure!.toStringAsFixed(1)} bar');
        }
      },
    );

    return builder.buildFragment().firstElementChild!;
  }
}

extension DivesiteXml on Divesite {
  static Divesite fromXml(XmlElement elem) {
    final gpsStr = elem.getAttribute('gps');
    GPSPosition? position;

    if (gpsStr != null) {
      final parts = gpsStr.split(' ');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0]);
        final lon = double.tryParse(parts[1]);
        if (lat != null && lon != null) {
          position = GPSPosition(lat, lon);
        }
      }
    }

    return Divesite(uuid: elem.getAttribute('uuid') ?? '', name: elem.getAttribute('name') ?? '', position: position);
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'site',
      nest: () {
        builder.attribute('uuid', uuid);
        builder.attribute('name', name);

        if (position != null) {
          builder.attribute('gps', '${position!.lat.toStringAsFixed(6)} ${position!.lon.toStringAsFixed(6)}');
        }
      },
    );

    return builder.buildFragment().firstElementChild!;
  }
}

extension SettingsXml on Settings {
  static Settings fromXml(XmlElement elem) {
    return Settings(fingerprints: elem.findElements('fingerprint').map(FingerprintXml.fromXml).toList());
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'settings',
      nest: () {
        for (final fingerprint in fingerprints) {
          builder.xml(fingerprint.toXml().toXmlString());
        }
      },
    );
    return builder.buildFragment().firstElementChild!;
  }
}

extension FingerprintXml on Fingerprint {
  static Fingerprint fromXml(XmlElement elem) {
    return Fingerprint(
      model: elem.getAttribute('model') ?? '',
      serial: elem.getAttribute('serial') ?? '',
      deviceid: elem.getAttribute('deviceid') ?? '',
      diveid: elem.getAttribute('diveid') ?? '',
      data: elem.getAttribute('data') ?? '',
    );
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'fingerprint',
      nest: () {
        builder.attribute('model', model);
        builder.attribute('serial', serial);
        builder.attribute('deviceid', deviceid);
        builder.attribute('diveid', diveid);
        builder.attribute('data', data);
      },
    );
    return builder.buildFragment().firstElementChild!;
  }
}

extension CylinderXml on Cylinder {
  static Cylinder fromXml(XmlElement elem) {
    return Cylinder(
      size: tryParseUnitString(elem.getAttribute('size')),
      workpressure: tryParseUnitString(elem.getAttribute('workpressure')),
      description: elem.getAttribute('description'),
      start: tryParseUnitString(elem.getAttribute('start')),
      end: tryParseUnitString(elem.getAttribute('end')),
      o2: tryParseUnitString(elem.getAttribute('o2')),
      he: tryParseUnitString(elem.getAttribute('he')),
    );
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'cylinder',
      nest: () {
        if (size != null) {
          builder.attribute('size', '${size!.toStringAsFixed(1)} l');
        }
        if (workpressure != null) {
          builder.attribute('workpressure', '${workpressure!.toStringAsFixed(1)} bar');
        }
        if (description != null) {
          builder.attribute('description', description!);
        }
        if (o2 != null) {
          builder.attribute('o2', '${o2!.toStringAsFixed(1)}%');
        }
        if (he != null) {
          builder.attribute('he', '${he!.toStringAsFixed(1)}%');
        }
        if (start != null) {
          builder.attribute('start', '${start!.toStringAsFixed(1)} bar');
        }
        if (end != null) {
          builder.attribute('end', '${end!.toStringAsFixed(1)} bar');
        }
      },
    );
    return builder.buildFragment().firstElementChild!;
  }
}

extension WeightsystemXml on Weightsystem {
  static Weightsystem fromXml(XmlElement elem) {
    return Weightsystem(weight: tryParseUnitString(elem.getAttribute('weight')), description: elem.getAttribute('description'));
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'weightsystem',
      nest: () {
        if (weight != null) {
          builder.attribute('weight', '${weight!.toStringAsFixed(1)} kg');
        }
        if (description != null) {
          builder.attribute('description', description!);
        }
      },
    );
    return builder.buildFragment().firstElementChild!;
  }
}

extension EventXml on Event {
  static Event fromXml(XmlElement elem) {
    return Event(
      time: tryParseUnitString(elem.getAttribute('time')) ?? 0,
      type: int.tryParse(elem.getAttribute('type') ?? ''),
      value: int.tryParse(elem.getAttribute('value') ?? ''),
      name: elem.getAttribute('name'),
      cylinder: int.tryParse(elem.getAttribute('cylinder') ?? ''),
    );
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'event',
      nest: () {
        builder.attribute('time', formatDuration(time));
        if (type != null) {
          builder.attribute('type', type.toString());
        }
        if (value != null) {
          builder.attribute('value', value.toString());
        }
        if (name != null) {
          builder.attribute('name', name!);
        }
        if (cylinder != null) {
          builder.attribute('cylinder', cylinder.toString());
        }
      },
    );
    return builder.buildFragment().firstElementChild!;
  }
}
