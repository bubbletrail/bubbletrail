import 'package:xml/xml.dart';

class Ssrf {
  List<Divesite> diveSites = [];
  List<Dive> dives;

  Ssrf({required this.dives});

  factory Ssrf.fromXml(XmlElement elem) {
    return Ssrf(dives: elem.findAllElements('dive').map(Dive.fromXml).toList());
  }

  XmlDocument toXmlDocument() {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('divelog', nest: () {
      builder.attribute('program', 'subsurface');
      builder.attribute('version', '3');

      // Add divesites section
      if (diveSites.isNotEmpty) {
        builder.element('divesites', nest: () {
          for (final site in diveSites) {
            builder.xml(site.toXml().toXmlString());
          }
        });
      }

      // Add dives section
      builder.element('dives', nest: () {
        for (final dive in dives) {
          builder.xml(dive.toXml().toXmlString());
        }
      });
    });

    return builder.buildDocument();
  }
}

class Dive {
  int number;
  int? rating;
  Set<String> tags = {};
  DateTime start;
  Environment? environment;

  double duration; // seconds
  double maxDepth; // meters
  double meanDepth; // meters

  Dive({required this.number, required this.start, required this.duration, required this.maxDepth, required this.meanDepth, this.rating, this.environment});

  factory Dive.fromXml(XmlElement elem) {
    final depth = elem.getElement('divecomputer')?.getElement('depth');
    return Dive(
      number: int.tryParse(elem.getAttribute('number') ?? '0') ?? 0,
      start: tryParseDateTime(elem.getAttribute('date'), elem.getAttribute('time')) ?? DateTime.fromMillisecondsSinceEpoch(0),
      maxDepth: tryParseUnitString(depth?.getAttribute('max')) ?? 0,
      meanDepth: tryParseUnitString(depth?.getAttribute('mean')) ?? 0,
      duration: tryParseUnitString(elem.getAttribute('duration')) ?? 0,
      rating: int.tryParse(elem.getAttribute('rating') ?? ''),
    );
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element('dive', nest: () {
      builder.attribute('number', number.toString());
      builder.attribute('date', formatDate(start));
      builder.attribute('time', formatTime(start));
      builder.attribute('duration', formatDuration(duration));

      if (rating != null) {
        builder.attribute('rating', rating.toString());
      }

      if (tags.isNotEmpty) {
        builder.attribute('tags', tags.join(', '));
      }

      // Add divecomputer section with depth info
      builder.element('divecomputer', nest: () {
        builder.element('depth', nest: () {
          builder.attribute('max', formatDepth(maxDepth));
          builder.attribute('mean', formatDepth(meanDepth));
        });

        // Add temperature if environment is present
        if (environment != null) {
          builder.element('temperature', nest: () {
            if (environment!.airTemperature != null) {
              builder.attribute('air', formatTemp(environment!.airTemperature!));
            }
            if (environment!.waterTemperature != null) {
              builder.attribute('water', formatTemp(environment!.waterTemperature!));
            }
          });
        }
      });
    });

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
    return Sample(time: tryParseUnitString(elem.getAttribute('time')) ?? 0, depth: tryParseUnitString(elem.getAttribute('depth')) ?? 0);
  }

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element('sample', nest: () {
      builder.attribute('time', formatDuration(time));
      builder.attribute('depth', formatDepth(depth));

      if (temp != null) {
        builder.attribute('temp', formatTemp(temp!));
      }

      if (pressure != null) {
        builder.attribute('pressure', '${pressure!.toStringAsFixed(1)} bar');
      }
    });

    return builder.buildFragment().firstElementChild!;
  }
}

class Divesite {
  final String uuid;
  final String name;
  final GPSPosition? position;

  const Divesite({required this.uuid, required this.name, this.position});

  XmlElement toXml() {
    final builder = XmlBuilder();
    builder.element('site', nest: () {
      builder.attribute('uuid', uuid);
      builder.attribute('name', name);

      if (position != null) {
        builder.attribute('gps', '${position!.lat.toStringAsFixed(6)} ${position!.lon.toStringAsFixed(6)}');
      }
    });

    return builder.buildFragment().firstElementChild!;
  }
}

class GPSPosition {
  final double lat;
  final double lon;

  const GPSPosition(this.lat, this.lon);
}

double? tryParseUnitString(String? s) {
  if (s == null) return null;

  final asIs = double.tryParse(s);
  if (asIs != null) return asIs;

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
  return null;
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
