import 'package:collection/collection.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../gen/gen.dart';
import 'formatting.dart';
import 'container.dart';

extension SsrfXml on Ssrf {
  static Ssrf fromXml(XmlElement elem) {
    final divesitesElem = elem.getElement('divesites');
    final divesElem = elem.getElement('dives');

    final divesList = divesElem?.findElements('dive').map(DiveXml.fromXml).toList() ?? [];
    divesList.addAll(divesElem?.findAllElements('trip').map((e) => e.findElements('dive').map(DiveXml.fromXml).toList()).flattened ?? []);

    final ssrf = Ssrf();
    ssrf.dives.addAll(divesList);
    ssrf.sites.addAll(divesitesElem?.findElements('site').map(SiteXml.fromXml).toList() ?? []);
    return ssrf;
  }

  XmlDocument toXmlDocument() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element(
      'divelog',
      nest: () {
        builder.attribute('program', 'subsurface');
        builder.attribute('version', '3');

        // Add sites section
        if (sites.isNotEmpty) {
          builder.element(
            'divesites',
            nest: () {
              for (final site in sites) {
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
    // Dive ID or generate new UUID if not present
    final diveID = ensureUUID(elem.getAttribute('uuid')) ?? const Uuid().v4();

    // Parse tags
    final tagsStr = elem.getAttribute('tags');
    final tagsList = tagsStr != null ? tagsStr.split(',').map((t) => t.trim()).toList() : <String>[];

    // Parse buddies
    final buddyStr = elem.getElement('buddy')?.innerText;
    final buddiesList = buddyStr != null ? buddyStr.split(',').map((b) => b.trim()).toList() : <String>[];

    // Parse cns percentage (remove '%' sign if present)
    final cnsStr = elem.getAttribute('cns');
    int? cns;
    if (cnsStr != null) {
      final cnsNumStr = cnsStr.replaceAll('%', '').trim();
      cns = int.tryParse(cnsNumStr);
    }

    // Parse DateTime and convert to Unix timestamp
    final dateTime = tryParseDateTime(elem.getAttribute('date'), elem.getAttribute('time'));

    final dive = Dive(
      id: diveID,
      number: int.tryParse(elem.getAttribute('number') ?? '0') ?? 0,
      start: Timestamp.fromDateTime(dateTime ?? DateTime.fromMillisecondsSinceEpoch(0)),
      duration: (tryParseUnitString(elem.getAttribute('duration')) ?? 0).toInt(),
      rating: int.tryParse(elem.getAttribute('rating') ?? ''),
      sac: tryParseUnitString(elem.getAttribute('sac')),
      otu: int.tryParse(elem.getAttribute('otu') ?? ''),
      cns: cns,
      siteId: elem.getAttribute('divesiteid'),
      divemaster: elem.getElement('divemaster')?.innerText,
      notes: elem.getElement('notes')?.innerText,
    );

    dive.tags.addAll(tagsList);
    dive.buddies.addAll(buddiesList);

    // Parse cylinders
    dive.cylinders.addAll(elem.findElements('cylinder').map(DiveCylinderXml.fromXml));

    // Parse weightsystems
    dive.weightsystems.addAll(elem.findElements('weightsystem').map(WeightsystemXml.fromXml));

    // Parse divecomputers
    dive.logs.addAll(elem.findElements('divecomputer').map(ComputerDiveXml.fromXml));

    // Set time on logs, not present in SSRF import
    for (final l in dive.logs) {
      l.dateTime = dive.start;
    }

    // Populate depth summary from first dive computer
    if (dive.logs.isNotEmpty) {
      final firstComputer = dive.logs[0];
      if (firstComputer.hasMaxDepth()) dive.maxDepth = firstComputer.maxDepth;
      if (firstComputer.hasAvgDepth()) dive.meanDepth = firstComputer.avgDepth;
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

        if (hasRating()) {
          builder.attribute('rating', rating.toString());
        }

        if (hasSac()) {
          builder.attribute('sac', '${sac.toStringAsFixed(3)} l/min');
        }

        if (hasOtu()) {
          builder.attribute('otu', otu.toString());
        }

        if (hasCns()) {
          builder.attribute('cns', '$cns%');
        }

        if (tags.isNotEmpty) {
          builder.attribute('tags', tags.join(', '));
        }

        if (hasSiteId()) {
          builder.attribute('divesiteid', siteId);
        }

        // Convert Int64 timestamp to DateTime for formatting
        final startDateTime = start.toDateTime();
        builder.attribute('date', formatDate(startDateTime));
        builder.attribute('time', formatTime(startDateTime));
        builder.attribute('duration', formatDuration(duration));

        // Add child elements
        if (hasDivemaster()) {
          builder.element(
            'divemaster',
            nest: () {
              builder.text(divemaster);
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

        if (hasNotes()) {
          builder.element(
            'notes',
            nest: () {
              builder.text(notes);
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
        for (final log in logs) {
          builder.xml(log.toSsrfXml().toXmlString());
        }
      },
    );

    return builder.buildFragment().firstElementChild!;
  }
}

extension ComputerDiveXml on Log {
  /// Parse a Log from an SSRF <divecomputer> XML element.
  static Log fromXml(XmlElement elem) {
    final depth = elem.getElement('depth');
    final temperature = elem.getElement('temperature');

    // Parse model from divecomputer element
    final model = elem.getAttribute('model') ?? 'Unknown';
    String? serial = elem.getAttribute('serial');

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

    // Parse events (these will be associated with samples by time)
    final eventsByTime = <int, List<SampleEvent>>{};
    for (final eventElem in elem.findElements('event')) {
      final time = (tryParseUnitString(eventElem.getAttribute('time')) ?? 0).toInt();
      final name = eventElem.getAttribute('name');
      final value = int.tryParse(eventElem.getAttribute('cylinder') ?? eventElem.getAttribute('value') ?? '') ?? 0;

      final type = _parseSsrfEventType(name);
      final event = SampleEvent(type: type, time: time, flags: 0, value: value);
      eventsByTime.putIfAbsent(time, () => []).add(event);
    }

    // Parse samples
    final samples = elem.findElements('sample').map((sampleElem) {
      final time = tryParseUnitString(sampleElem.getAttribute('time')) ?? 0;
      final sampleDepth = tryParseUnitString(sampleElem.getAttribute('depth'));
      final temp = tryParseUnitString(sampleElem.getAttribute('temp'));
      final pressure = tryParseUnitString(sampleElem.getAttribute('pressure'));

      final sample = LogSample(time: time, depth: sampleDepth, temperature: temp);

      // Add pressure if present
      if (pressure != null) {
        sample.pressures.add(TankPressure(tankIndex: 0, pressure: pressure));
      }

      // Add events at this time
      final eventsAtTime = eventsByTime[time.toInt()];
      if (eventsAtTime != null) {
        sample.events.addAll(eventsAtTime);
      }

      return sample;
    }).toList();

    final log = Log(
      model: model,
      serial: serial,
      maxDepth: tryParseUnitString(depth?.getAttribute('max')),
      avgDepth: tryParseUnitString(depth?.getAttribute('mean')),
      surfaceTemperature: airTemp,
      minTemperature: waterTemp,
    );
    log.samples.addAll(samples);

    log.setUniqueID();
    return log;
  }

  /// Convert a Log to an SSRF <divecomputer> XML element.
  XmlElement toSsrfXml() {
    final builder = XmlBuilder();
    builder.element(
      'divecomputer',
      nest: () {
        if (hasModel()) {
          builder.attribute('model', model);
        }
        if (hasSerial()) {
          builder.attribute('serial', serial);
        }

        if (hasMaxDepth() || hasAvgDepth()) {
          builder.element(
            'depth',
            nest: () {
              if (hasMaxDepth()) builder.attribute('max', formatDepth(maxDepth));
              if (hasAvgDepth()) builder.attribute('mean', formatDepth(avgDepth));
            },
          );
        }

        // Add temperature if present
        if (hasSurfaceTemperature() || hasMinTemperature()) {
          builder.element(
            'temperature',
            nest: () {
              if (hasSurfaceTemperature()) {
                builder.attribute('air', formatTemp(surfaceTemperature));
              }
              if (hasMinTemperature()) {
                builder.attribute('water', formatTemp(minTemperature));
              }
            },
          );
        }

        // Collect and add events from all samples
        for (final sample in samples) {
          for (final event in sample.events) {
            builder.element(
              'event',
              nest: () {
                builder.attribute('time', formatDuration(event.time));
                builder.attribute('name', _eventTypeToSsrfName(event.type));
                if (event.value != 0) {
                  builder.attribute('value', event.value.toString());
                }
              },
            );
          }
        }

        // Add samples
        double? prevTemp;
        double? prevPressure;
        for (final sample in samples) {
          builder.element(
            'sample',
            nest: () {
              builder.attribute('time', formatDuration(sample.time.toInt()));
              if (sample.hasDepth()) {
                builder.attribute('depth', formatDepth(sample.depth));
              }
              if (sample.hasTemperature() && sample.temperature != prevTemp) {
                builder.attribute('temp', formatTemp(sample.temperature));
                prevTemp = sample.temperature;
              }
              if (sample.pressures.isNotEmpty && sample.pressures.first.pressure > 0 && sample.pressures.first.pressure != prevPressure) {
                builder.attribute('pressure', '${sample.pressures.first.pressure.toStringAsFixed(1)} bar');
                prevPressure = sample.pressures.first.pressure;
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
  if (name == null) return SampleEventType.SAMPLE_EVENT_TYPE_NONE;
  return switch (name.toLowerCase()) {
    'gaschange' => SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE,
    'bookmark' => SampleEventType.SAMPLE_EVENT_TYPE_BOOKMARK,
    'heading' => SampleEventType.SAMPLE_EVENT_TYPE_HEADING,
    'surface' => SampleEventType.SAMPLE_EVENT_TYPE_SURFACE,
    'violation' => SampleEventType.SAMPLE_EVENT_TYPE_VIOLATION,
    'ascent' => SampleEventType.SAMPLE_EVENT_TYPE_ASCENT,
    'ceiling' => SampleEventType.SAMPLE_EVENT_TYPE_CEILING,
    'deco' => SampleEventType.SAMPLE_EVENT_TYPE_DECO_STOP,
    'safetystop' => SampleEventType.SAMPLE_EVENT_TYPE_SAFETY_STOP,
    _ => SampleEventType.SAMPLE_EVENT_TYPE_NONE,
  };
}

String _eventTypeToSsrfName(SampleEventType type) {
  return switch (type) {
    SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE => 'gaschange',
    SampleEventType.SAMPLE_EVENT_TYPE_BOOKMARK => 'bookmark',
    SampleEventType.SAMPLE_EVENT_TYPE_HEADING => 'heading',
    SampleEventType.SAMPLE_EVENT_TYPE_SURFACE => 'surface',
    SampleEventType.SAMPLE_EVENT_TYPE_VIOLATION => 'violation',
    SampleEventType.SAMPLE_EVENT_TYPE_ASCENT => 'ascent',
    SampleEventType.SAMPLE_EVENT_TYPE_CEILING => 'ceiling',
    SampleEventType.SAMPLE_EVENT_TYPE_DECO_STOP => 'deco',
    SampleEventType.SAMPLE_EVENT_TYPE_SAFETY_STOP => 'safetystop',
    SampleEventType.SAMPLE_EVENT_TYPE_RBT => 'rbt',
    SampleEventType.SAMPLE_EVENT_TYPE_WORKLOAD => 'workload',
    SampleEventType.SAMPLE_EVENT_TYPE_TRANSMITTER => 'transmitter',
    SampleEventType.SAMPLE_EVENT_TYPE_DEEP_STOP => 'deepstop',
    _ => type.name,
  };
}

extension SiteXml on Site {
  static Site fromXml(XmlElement elem) {
    final gpsStr = elem.getAttribute('gps');
    Position? position;

    if (gpsStr != null) {
      final parts = gpsStr.split(' ');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0]);
        final lon = double.tryParse(parts[1]);
        if (lat != null && lon != null) {
          position = Position(latitude: lat, longitude: lon);
        }
      }
    }

    String? country;
    String? location;

    var name = elem.getAttribute('name') ?? '';
    final nlcExp = RegExp(r'(.+) / (.+) / (.+)');
    final m = nlcExp.firstMatch(name);
    if (m != null) {
      country = m.group(1);
      location = m.group(2);
      name = m.group(3)!;
    }

    String? bodyOfWater;
    String? difficulty;

    // Parse extradata elements for additional fields
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

    // Parse notes
    final notes = elem.getElement('notes')?.innerText;

    return Site(
      id: ensureUUID(elem.getAttribute('uuid')) ?? '',
      name: name,
      position: position,
      country: country,
      location: location,
      bodyOfWater: bodyOfWater,
      difficulty: difficulty,
      notes: notes,
    );
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'site',
      nest: () {
        builder.attribute('uuid', id);
        builder.attribute('name', name);

        if (hasPosition()) {
          builder.attribute('gps', '${position.latitude.toStringAsFixed(6)} ${position.longitude.toStringAsFixed(6)}');
        }

        // Add extradata elements for additional fields
        if (hasCountry()) {
          builder.element(
            'extradata',
            nest: () {
              builder.attribute('key', 'country');
              builder.attribute('value', country);
            },
          );
        }
        if (hasLocation()) {
          builder.element(
            'extradata',
            nest: () {
              builder.attribute('key', 'location');
              builder.attribute('value', location);
            },
          );
        }
        if (hasBodyOfWater()) {
          builder.element(
            'extradata',
            nest: () {
              builder.attribute('key', 'body_of_water');
              builder.attribute('value', bodyOfWater);
            },
          );
        }
        if (hasDifficulty()) {
          builder.element(
            'extradata',
            nest: () {
              builder.attribute('key', 'difficulty');
              builder.attribute('value', difficulty);
            },
          );
        }

        if (hasNotes()) {
          builder.element(
            'notes',
            nest: () {
              builder.text(notes);
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
      cylinder: Cylinder(
        volumeL: tryParseUnitString(elem.getAttribute('size')),
        workingPressureBar: tryParseUnitString(elem.getAttribute('workpressure')),
        description: elem.getAttribute('description'),
      ),
      beginPressure: tryParseUnitString(elem.getAttribute('start')),
      endPressure: tryParseUnitString(elem.getAttribute('end')),
      oxygen: tryParseUnitString(elem.getAttribute('o2')),
      helium: tryParseUnitString(elem.getAttribute('he')),
    );
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'cylinder',
      nest: () {
        if (hasCylinder() && cylinder.hasVolumeL()) {
          builder.attribute('size', '${cylinder.volumeL.toStringAsFixed(1)} l');
        }
        if (hasCylinder() && cylinder.hasWorkingPressureBar()) {
          builder.attribute('workpressure', '${cylinder.workingPressureBar.toStringAsFixed(1)} bar');
        }
        if (hasCylinder() && cylinder.hasDescription()) {
          builder.attribute('description', cylinder.description);
        }
        if (hasOxygen()) {
          builder.attribute('o2', '${(oxygen * 100).toStringAsFixed(1)}%');
        }
        if (hasHelium()) {
          builder.attribute('he', '${(helium * 100).toStringAsFixed(1)}%');
        }
        if (hasBeginPressure()) {
          builder.attribute('start', '${beginPressure.toStringAsFixed(1)} bar');
        }
        if (hasEndPressure()) {
          builder.attribute('end', '${endPressure.toStringAsFixed(1)} bar');
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
        if (hasWeight()) {
          builder.attribute('weight', '${weight.toStringAsFixed(1)} kg');
        }
        if (hasDescription()) {
          builder.attribute('description', description);
        }
      },
    );
    return builder.buildFragment().firstElementChild!;
  }
}

String? ensureUUID(String? u) => u?.replaceAll(' ', '0');
