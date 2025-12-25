import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import 'computerdive.dart';
import 'formatting.dart';
import 'types.dart';

extension SsrfXml on Ssrf {
  static Ssrf fromXml(XmlElement elem) {
    final settingsElem = elem.getElement('settings');
    final divesitesElem = elem.getElement('divesites');
    final divesElem = elem.getElement('dives');

    var dives = divesElem?.findElements('dive').map(DiveXml.fromXml).toList() ?? [];
    dives.addAll(divesElem?.findAllElements('trip').map((e) => e.findElements('dive').map(DiveXml.fromXml).toList()).flattened ?? []);

    // Parse fingerprints from settings into DiveComputers
    final diveComputers = <DiveComputer>[];
    if (settingsElem != null) {
      for (final fpElem in settingsElem.findElements('fingerprint')) {
        diveComputers.add(
          DiveComputer(
            id: 0,
            model: fpElem.getAttribute('model') ?? '',
            serial: fpElem.getAttribute('serial'),
            deviceid: fpElem.getAttribute('deviceid'),
            diveid: fpElem.getAttribute('diveid'),
            fingerprintData: fpElem.getAttribute('data'),
          ),
        );
      }
    }

    return Ssrf(dives: dives, diveSites: divesitesElem?.findElements('site').map(DivesiteXml.fromXml).toList() ?? [], diveComputers: diveComputers);
  }

  XmlDocument toXmlDocument() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element(
      'divelog',
      nest: () {
        builder.attribute('program', 'subsurface');
        builder.attribute('version', '3');

        // Add settings section with fingerprints from diveComputers
        final dcsWithFingerprint = diveComputers.where((dc) => dc.fingerprintData != null).toList();
        if (dcsWithFingerprint.isNotEmpty) {
          builder.element(
            'settings',
            nest: () {
              for (final dc in dcsWithFingerprint) {
                builder.element(
                  'fingerprint',
                  nest: () {
                    builder.attribute('model', dc.model);
                    if (dc.serial != null) builder.attribute('serial', dc.serial!);
                    if (dc.deviceid != null) builder.attribute('deviceid', dc.deviceid!);
                    if (dc.diveid != null) builder.attribute('diveid', dc.diveid!);
                    if (dc.fingerprintData != null) builder.attribute('data', dc.fingerprintData!);
                  },
                );
              }
            },
          );
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
    final diveID = ensureUUID(elem.getAttribute('uuid'));

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
      duration: (tryParseUnitString(elem.getAttribute('duration')) ?? 0).toInt(),
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
    dive.cylinders = elem.findElements('cylinder').map(DiveCylinderXml.fromXml).toList();

    // Parse weightsystems
    dive.weightsystems = elem.findElements('weightsystem').map(WeightsystemXml.fromXml).toList();

    // Parse divecomputers
    dive.computerDives = elem.findElements('divecomputer').map(ComputerDiveXml.fromXml).toList();

    // Populate depth summary from first dive computer
    if (dive.computerDives.isNotEmpty) {
      dive.maxDepth = dive.computerDives[0].maxDepth;
      dive.meanDepth = dive.computerDives[0].avgDepth;
    }

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
        for (final computerDive in computerDives) {
          builder.xml(computerDive.toSsrfXml().toXmlString());
        }
      },
    );

    return builder.buildFragment().firstElementChild!;
  }
}

extension ComputerDiveXml on ComputerDive {
  /// Parse a ComputerDive from an SSRF <divecomputer> XML element.
  static ComputerDive fromXml(XmlElement elem) {
    final depth = elem.getElement('depth');
    final temperature = elem.getElement('temperature');

    // Parse model from divecomputer element
    final model = elem.getAttribute('model') ?? 'Unknown';
    var serial = elem.getAttribute('serial');

    // Parse extradata to potentially extract serial
    for (final extradataElem in elem.findElements('extradata')) {
      final key = extradataElem.getAttribute('key');
      final value = extradataElem.getAttribute('value');
      if (key == 'Serial' && serial == null && value != null) {
        serial = value;
      }
    }

    // Parse temperatures
    final airTemp = temperature != null ? tryParseUnitString(temperature.getAttribute('air')) : null;
    final waterTemp = temperature != null ? tryParseUnitString(temperature.getAttribute('water')) : null;

    // Parse samples
    final samples = elem.findElements('sample').map((sampleElem) {
      final time = tryParseUnitString(sampleElem.getAttribute('time')) ?? 0;
      final sampleDepth = tryParseUnitString(sampleElem.getAttribute('depth'));
      final temp = tryParseUnitString(sampleElem.getAttribute('temp'));
      final pressure = tryParseUnitString(sampleElem.getAttribute('pressure'));

      return ComputerSample(
        time: time,
        depth: sampleDepth,
        temperature: temp,
        pressures: pressure != null ? [TankPressure(tankIndex: 0, pressure: pressure)] : null,
      );
    }).toList();

    // Parse events
    final events = elem.findElements('event').map((eventElem) {
      final time = (tryParseUnitString(eventElem.getAttribute('time')) ?? 0).toInt();
      final name = eventElem.getAttribute('name');
      final value = int.tryParse(eventElem.getAttribute('value') ?? '') ?? 0;

      // Map SSRF event names to SampleEventType
      final type = _parseSsrfEventType(name);

      return SampleEvent(
        type: type,
        time: time,
        flags: const SampleEventFlags(0),
        value: value,
      );
    }).toList();

    return ComputerDive(
      model: model,
      serial: serial,
      maxDepth: tryParseUnitString(depth?.getAttribute('max')),
      avgDepth: tryParseUnitString(depth?.getAttribute('mean')),
      surfaceTemperature: airTemp,
      minTemperature: waterTemp,
      samples: samples,
      events: events,
    );
  }

  /// Convert a ComputerDive to an SSRF <divecomputer> XML element.
  XmlElement toSsrfXml() {
    final builder = XmlBuilder();
    builder.element(
      'divecomputer',
      nest: () {
        if (model != null) {
          builder.attribute('model', model!);
        }
        if (serial != null) {
          builder.attribute('serial', serial!);
        }

        if (maxDepth != null || avgDepth != null) {
          builder.element(
            'depth',
            nest: () {
              if (maxDepth != null) builder.attribute('max', formatDepth(maxDepth!));
              if (avgDepth != null) builder.attribute('mean', formatDepth(avgDepth!));
            },
          );
        }

        // Add temperature if present
        if (surfaceTemperature != null || minTemperature != null) {
          builder.element(
            'temperature',
            nest: () {
              if (surfaceTemperature != null) {
                builder.attribute('air', formatTemp(surfaceTemperature!));
              }
              if (minTemperature != null) {
                builder.attribute('water', formatTemp(minTemperature!));
              }
            },
          );
        }

        // Add events
        for (final event in events) {
          builder.element(
            'event',
            nest: () {
              builder.attribute('time', formatDuration(event.time));
              builder.attribute('name', event.type.name);
              if (event.value != 0) {
                builder.attribute('value', event.value.toString());
              }
            },
          );
        }

        // Add samples
        for (final sample in samples) {
          builder.element(
            'sample',
            nest: () {
              builder.attribute('time', formatDuration(sample.time.toInt()));
              if (sample.depth != null) {
                builder.attribute('depth', formatDepth(sample.depth!));
              }
              if (sample.temperature != null) {
                builder.attribute('temp', formatTemp(sample.temperature!));
              }
              if (sample.pressures?.isNotEmpty == true) {
                builder.attribute('pressure', '${sample.pressures!.first.pressure.toStringAsFixed(1)} bar');
              }
            },
          );
        }
      },
    );

    return builder.buildFragment().firstElementChild!;
  }
}

SampleEventType _parseSsrfEventType(String? name) {
  if (name == null) return SampleEventType.none;
  return switch (name.toLowerCase()) {
    'gaschange' => SampleEventType.gasChange,
    'bookmark' => SampleEventType.bookmark,
    'heading' => SampleEventType.heading,
    'surface' => SampleEventType.surface,
    'violation' => SampleEventType.violation,
    'ascent' => SampleEventType.ascent,
    'ceiling' => SampleEventType.ceiling,
    'deco' => SampleEventType.decoStop,
    'safetystop' => SampleEventType.safetyStop,
    _ => SampleEventType.none,
  };
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

    // Parse extradata elements for additional fields
    String? country;
    String? location;
    String? bodyOfWater;
    String? difficulty;
    for (final extradataElem in elem.findElements('extradata')) {
      final key = extradataElem.getAttribute('key');
      final value = extradataElem.getAttribute('value');
      if (key != null && value != null) {
        switch (key) {
          case 'country':
            country = value;
          case 'location':
            location = value;
          case 'body_of_water':
            bodyOfWater = value;
          case 'difficulty':
            difficulty = value;
        }
      }
    }

    return Divesite(
      uuid: ensureUUID(elem.getAttribute('uuid')) ?? '',
      name: elem.getAttribute('name') ?? '',
      position: position,
      country: country,
      location: location,
      bodyOfWater: bodyOfWater,
      difficulty: difficulty,
    );
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

        // Add extradata elements for additional fields
        if (country != null) {
          builder.element(
            'extradata',
            nest: () {
              builder.attribute('key', 'country');
              builder.attribute('value', country!);
            },
          );
        }
        if (location != null) {
          builder.element(
            'extradata',
            nest: () {
              builder.attribute('key', 'location');
              builder.attribute('value', location!);
            },
          );
        }
        if (bodyOfWater != null) {
          builder.element(
            'extradata',
            nest: () {
              builder.attribute('key', 'body_of_water');
              builder.attribute('value', bodyOfWater!);
            },
          );
        }
        if (difficulty != null) {
          builder.element(
            'extradata',
            nest: () {
              builder.attribute('key', 'difficulty');
              builder.attribute('value', difficulty!);
            },
          );
        }
      },
    );

    return builder.buildFragment().firstElementChild!;
  }
}

extension DiveCylinderXml on DiveCylinder {
  static DiveCylinder fromXml(XmlElement elem) {
    return DiveCylinder(
      cylinderId: 0, // Will be resolved when saving to database
      cylinder: Cylinder(
        id: 0,
        size: tryParseUnitString(elem.getAttribute('size')),
        workpressure: tryParseUnitString(elem.getAttribute('workpressure')),
        description: elem.getAttribute('description'),
      ),
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
        if (cylinder?.size != null) {
          builder.attribute('size', '${cylinder!.size!.toStringAsFixed(1)} l');
        }
        if (cylinder?.workpressure != null) {
          builder.attribute('workpressure', '${cylinder!.workpressure!.toStringAsFixed(1)} bar');
        }
        if (cylinder?.description != null) {
          builder.attribute('description', cylinder!.description!);
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

String? ensureUUID(String? u) => u?.replaceAll(' ', '0');
