import 'package:uuid/uuid.dart';

class Ssrf {
  final List<Dive> dives;
  final List<Divesite> diveSites;
  final Settings? settings;

  const Ssrf({required this.dives, required this.diveSites, this.settings});
}

class Dive {
  String id;
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
    String? id,
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
  }) : id = id ?? Uuid().v4().split('-').first;
}

class DiveComputer {
  final double maxDepth; // meters
  final double meanDepth; // meters
  final Environment? environment;
  late final List<Sample> samples;
  late final List<Event> events;
  late final Map<String, String> extradata;

  DiveComputer({required this.maxDepth, required this.meanDepth, this.environment, samples, events, extradata}) {
    this.samples = samples ?? [];
    this.events = events ?? [];
    this.extradata = extradata ?? {};
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

class Settings {
  final List<Fingerprint> fingerprints;

  const Settings({required this.fingerprints});
}

class Fingerprint {
  final String model;
  final String serial;
  final String deviceid;
  final String diveid;
  final String data;

  const Fingerprint({required this.model, required this.serial, required this.deviceid, required this.diveid, required this.data});
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
}

class Weightsystem {
  final double? weight; // kg
  final String? description;

  const Weightsystem({this.weight, this.description});
}

class Event {
  final double time; // seconds
  final int? type;
  final int? value;
  final String? name;
  final int? cylinder;

  const Event({required this.time, this.type, this.value, this.name, this.cylinder});
}
