import 'package:xml/xml.dart';

class Ssrf {
  Settings? settings;
  List<Divesite> diveSites = [];
  List<Dive> dives;

  Ssrf({required this.dives, this.settings});

  factory Ssrf.fromXml(XmlElement elem) {
    final settingsElem = elem.getElement('settings');
    final divesitesElem = elem.getElement('divesites');
    final divesElem = elem.getElement('dives');

    return Ssrf(settings: settingsElem != null ? Settings.fromXml(settingsElem) : null, dives: divesElem?.findElements('dive').map(Dive.fromXml).toList() ?? [])
      ..diveSites = divesitesElem?.findElements('site').map(Divesite.fromXml).toList() ?? [];
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

class Dive {
  int number;
  int? rating;
  Set<String> tags = {};
  DateTime start;
  double duration; // seconds

  // Additional attributes
  double? sac; // l/min
  int? otu;
  int? cns; // percentage
  String? divesiteid;

  // Child elements
  String? divemaster;
  Set<String> buddies = {};
  String? notes;
  List<Cylinder> cylinders = [];
  List<Weightsystem> weightsystems = [];
  List<DiveComputer> divecomputers = [];

  Dive({
    required this.number,
    required this.start,
    required this.duration,
    this.rating,
    this.sac,
    this.otu,
    this.cns,
    this.divesiteid,
    this.divemaster,
    this.notes,
  });

  factory Dive.fromXml(XmlElement elem) {
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
    dive.cylinders = elem.findElements('cylinder').map(Cylinder.fromXml).toList();

    // Parse weightsystems
    dive.weightsystems = elem.findElements('weightsystem').map(Weightsystem.fromXml).toList();

    // Parse divecomputers
    dive.divecomputers = elem.findElements('divecomputer').map(DiveComputer.fromXml).toList();

    return dive;
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element(
      'dive',
      nest: () {
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

class DiveComputer {
  double maxDepth; // meters
  double meanDepth; // meters
  Environment? environment;
  List<Sample> samples = [];
  List<Event> events = [];
  Map<String, String> extradata = {};

  DiveComputer({required this.maxDepth, required this.meanDepth, this.environment});

  factory DiveComputer.fromXml(XmlElement elem) {
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
    );

    // Parse samples
    divecomputer.samples = elem.findElements('sample').map(Sample.fromXml).toList();

    // Parse events
    divecomputer.events = elem.findElements('event').map(Event.fromXml).toList();

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

class Environment {
  final double? airTemperature; // degrees celsius
  final double? waterTemperature; // degrees celsius

  Environment({this.airTemperature, this.waterTemperature});
}

class Sample {
  final double time; // seconds
  final double depth; // meters
  final double? temp; // degrees celsius
  final double? pressure; // bars

  const Sample({required this.time, required this.depth, this.temp, this.pressure});

  factory Sample.fromXml(XmlElement elem) {
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

class Divesite {
  final String uuid;
  final String name;
  final GPSPosition? position;

  const Divesite({required this.uuid, required this.name, this.position});

  factory Divesite.fromXml(XmlElement elem) {
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

class GPSPosition {
  final double lat;
  final double lon;

  const GPSPosition(this.lat, this.lon);
}

class Settings {
  List<Fingerprint> fingerprints;

  Settings({required this.fingerprints});

  factory Settings.fromXml(XmlElement elem) {
    return Settings(fingerprints: elem.findElements('fingerprint').map(Fingerprint.fromXml).toList());
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

class Fingerprint {
  final String model;
  final String serial;
  final String deviceid;
  final String diveid;
  final String data;

  const Fingerprint({required this.model, required this.serial, required this.deviceid, required this.diveid, required this.data});

  factory Fingerprint.fromXml(XmlElement elem) {
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

class Cylinder {
  final double? size; // liters
  final double? workpressure; // bar
  final String? description;
  final double? start; // bar
  final double? end; // bar
  final double? o2; // percentage (0-100)
  final double? he; // percentage (0-100)

  const Cylinder({this.size, this.workpressure, this.description, this.start, this.end, this.o2, this.he});

  factory Cylinder.fromXml(XmlElement elem) {
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

class Weightsystem {
  final double? weight; // kg
  final String? description;

  const Weightsystem({this.weight, this.description});

  factory Weightsystem.fromXml(XmlElement elem) {
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

class Event {
  final double time; // seconds
  final int? type;
  final int? value;
  final String? name;
  final int? cylinder;

  const Event({required this.time, this.type, this.value, this.name, this.cylinder});

  factory Event.fromXml(XmlElement elem) {
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

double? tryParseUnitString(String? s) {
  if (s == null) return null;

  final asIs = double.tryParse(s);
  if (asIs != null) return asIs;

  // Handle percentage (e.g., "32.0%")
  if (s.endsWith('%')) {
    return double.tryParse(s.substring(0, s.length - 1));
  }

  final parts = s.split(' ');
  if (parts.length < 2) return null;

  switch (parts[1]) {
    case "min": // "1:23 min"
      final minSec = parts[0].split(':');
      if (minSec.length != 2) return null;
      final min = double.tryParse(minSec[0]);
      final sec = double.tryParse(minSec[1]);
      if (min == null || sec == null) return null;
      return min * 60 + sec;
    default:
      return double.tryParse(parts[0]);
  }
}

DateTime? tryParseDateTime(String? date, String? time) {
  if (date == null) return null;

  try {
    // Parse date in format 'YYYY-MM-DD'
    final dateParts = date.split('-');
    if (dateParts.length != 3) return null;

    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);

    if (year == null || month == null || day == null) return null;

    // Parse time in format 'HH:MM:SS' if provided
    int hour = 0;
    int minute = 0;
    int second = 0;

    if (time != null) {
      final timeParts = time.split(':');
      if (timeParts.length >= 2) {
        hour = int.tryParse(timeParts[0]) ?? 0;
        minute = int.tryParse(timeParts[1]) ?? 0;
        if (timeParts.length >= 3) {
          second = int.tryParse(timeParts[2]) ?? 0;
        }
      }
    }

    return DateTime(year, month, day, hour, minute, second);
  } catch (e) {
    return null;
  }
}

// Serialization helpers
String formatDuration(double seconds) {
  final minutes = seconds ~/ 60;
  final secs = (seconds % 60).round();
  return '$minutes:${secs.toString().padLeft(2, '0')} min';
}

String formatDepth(double meters) {
  // Use up to 3 decimal places, but remove trailing zeros
  final formatted = meters.toStringAsFixed(3);
  final trimmed = formatted.replaceAll(RegExp(r'\.?0+$'), '');
  return '$trimmed m';
}

String formatTemp(double celsius) {
  return '${celsius.toStringAsFixed(1)} C';
}

String formatDate(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

String formatTime(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}
