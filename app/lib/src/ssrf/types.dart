import 'package:uuid/uuid.dart';

class Ssrf {
  final List<Dive> dives;
  final List<Divesite> diveSites;
  final List<DiveComputer> diveComputers;

  const Ssrf({required this.dives, required this.diveSites, this.diveComputers = const []});
}

class Dive {
  String id;
  int number;
  int? rating;
  Set<String> tags = {};
  DateTime start;
  int duration; // seconds

  // Depth summary (populated from dive computer data)
  double? maxDepth; // meters
  double? meanDepth; // meters

  // Additional attributes
  double? sac; // l/min
  int? otu;
  int? cns; // percentage
  String? divesiteid;

  // Child elements
  String? divemaster;
  Set<String> buddies = {};
  String? notes;
  List<DiveCylinder> cylinders = [];
  List<Weightsystem> weightsystems = [];
  List<DiveComputerLog> divecomputers = [];

  Dive({
    String? id,
    required this.number,
    required this.start,
    required this.duration,
    this.rating,
    this.maxDepth,
    this.meanDepth,
    this.sac,
    this.otu,
    this.cns,
    this.divesiteid,
    this.divemaster,
    this.notes,
  }) : id = id ?? Uuid().v4().split('-').first;
}

class DiveComputer {
  final int id;
  final String model;
  final String? serial;
  final String? deviceid;
  final String? diveid;
  final String? fingerprintData;

  const DiveComputer({required this.id, required this.model, this.serial, this.deviceid, this.diveid, this.fingerprintData});
}

class DiveComputerLog {
  final int diveComputerId;
  final DiveComputer? diveComputer; // populated when loaded from storage
  final double maxDepth; // meters
  final double meanDepth; // meters
  final Environment? environment;
  late final List<Sample> samples;
  late final List<Event> events;
  late final Map<String, String> extradata;

  DiveComputerLog({
    required this.diveComputerId,
    this.diveComputer,
    required this.maxDepth,
    required this.meanDepth,
    this.environment,
    samples,
    events,
    extradata,
  }) {
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
  final int time; // seconds
  final double depth; // meters
  final double? temp; // degrees celsius
  final double? pressure; // bars

  const Sample({required this.time, required this.depth, this.temp, this.pressure});
}

class Divesite {
  final String uuid;
  final String name;
  final GPSPosition? position;
  final String? country;
  final String? location;
  final String? bodyOfWater;
  final String? difficulty;

  const Divesite({required this.uuid, required this.name, this.position, this.country, this.location, this.bodyOfWater, this.difficulty});
}

class GPSPosition {
  final double lat;
  final double lon;

  const GPSPosition(this.lat, this.lon);
}

class Cylinder {
  final int id;
  final double? size; // liters
  final double? workpressure; // bar
  final String? description;

  const Cylinder({required this.id, this.size, this.workpressure, this.description});
}

class DiveCylinder {
  final int cylinderId;
  final Cylinder? cylinder; // populated when loaded from storage
  final double? start; // bar
  final double? end; // bar
  final double? o2; // percentage (0-100)
  final double? he; // percentage (0-100)

  const DiveCylinder({required this.cylinderId, this.cylinder, this.start, this.end, this.o2, this.he});
}

class Weightsystem {
  final double? weight; // kg
  final String? description;

  const Weightsystem({this.weight, this.description});
}

class Event {
  final int time; // seconds
  final int? type;
  final int? value;
  final String? name;
  final int? cylinder;

  const Event({required this.time, this.type, this.value, this.name, this.cylinder});
}
