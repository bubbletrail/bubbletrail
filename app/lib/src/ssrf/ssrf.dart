import 'package:xml/xml.dart';

class Ssrf {
  List<Divesite> diveSites = [];
  List<Dive> dives;

  Ssrf({required this.dives});

  factory Ssrf.fromXml(XmlElement elem) {
    return Ssrf(dives: elem.findAllElements('dive').map(Dive.fromXml).toList());
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
}

class Divesite {
  final String uuid;
  final String name;
  final GPSPosition? position;

  const Divesite({required this.uuid, required this.name, this.position});
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
