import 'package:uuid/uuid.dart';

import 'computerdive.dart';

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
  List<ComputerDive> computerDives = [];

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
