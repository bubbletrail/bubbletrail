import 'package:json_annotation/json_annotation.dart';

part 'computerdive.g.dart';

// --- Enums ---

/// Water type for salinity.
@JsonEnum()
enum WaterType {
  fresh,
  salt;

  static WaterType? fromDcValue(int value) => switch (value) {
    0 => fresh,
    1 => salt,
    _ => null,
  };
}

/// Dive mode.
@JsonEnum()
enum DiveMode {
  freedive,
  gauge,
  openCircuit,
  closedCircuitRebreather,
  semiClosedRebreather;

  static DiveMode? fromDcValue(int value) => switch (value) {
    0 => freedive,
    1 => gauge,
    2 => openCircuit,
    3 => closedCircuitRebreather,
    4 => semiClosedRebreather,
    _ => null,
  };
}

/// Gas usage type.
@JsonEnum()
enum GasUsage {
  none,
  oxygen,
  diluent,
  sidemount;

  static GasUsage fromDcValue(int value) => switch (value) {
    0 => none,
    1 => oxygen,
    2 => diluent,
    3 => sidemount,
    _ => none,
  };
}

/// Tank volume type.
@JsonEnum()
enum TankVolumeType {
  none,
  metric,
  imperial;

  static TankVolumeType fromDcValue(int value) => switch (value) {
    0 => none,
    1 => metric,
    2 => imperial,
    _ => none,
  };
}

/// Decompression model type.
@JsonEnum()
enum DecoModelType {
  none,
  buhlmann,
  vpm,
  rgbm,
  dciem;

  static DecoModelType fromDcValue(int value) => switch (value) {
    0 => none,
    1 => buhlmann,
    2 => vpm,
    3 => rgbm,
    4 => dciem,
    _ => none,
  };
}

/// Decompression stop type (in samples).
@JsonEnum()
enum DecoStopType {
  ndl,
  safetyStop,
  decoStop,
  deepStop;

  static DecoStopType fromDcValue(int value) => switch (value) {
    0 => ndl,
    1 => safetyStop,
    2 => decoStop,
    3 => deepStop,
    _ => ndl,
  };
}

/// Sample event type.
@JsonEnum()
enum SampleEventType {
  none,
  decoStop,
  rbt,
  ascent,
  ceiling,
  workload,
  transmitter,
  violation,
  bookmark,
  surface,
  safetyStop,
  gasChange,
  safetyStopVoluntary,
  safetyStopMandatory,
  deepStop,
  ceilingSafetyStop,
  floor,
  diveTime,
  maxDepth,
  olf,
  po2,
  airTime,
  rgbm,
  heading,
  tissueLevel,
  gasChange2;

  static SampleEventType fromDcValue(int value) => switch (value) {
    0 => none,
    1 => decoStop,
    2 => rbt,
    3 => ascent,
    4 => ceiling,
    5 => workload,
    6 => transmitter,
    7 => violation,
    8 => bookmark,
    9 => surface,
    10 => safetyStop,
    11 => gasChange,
    12 => safetyStopVoluntary,
    13 => safetyStopMandatory,
    14 => deepStop,
    15 => ceilingSafetyStop,
    16 => floor,
    17 => diveTime,
    18 => maxDepth,
    19 => olf,
    20 => po2,
    21 => airTime,
    22 => rgbm,
    23 => heading,
    24 => tissueLevel,
    25 => gasChange2,
    _ => none,
  };
}

/// Sample event flags.
@JsonSerializable()
class SampleEventFlags {
  static const int none = 0;
  static const int begin = 1 << 0;
  static const int end = 1 << 1;

  final int value;
  const SampleEventFlags(this.value);

  factory SampleEventFlags.fromJson(Map<String, dynamic> json) => _$SampleEventFlagsFromJson(json);
  Map<String, dynamic> toJson() => _$SampleEventFlagsToJson(this);

  bool get isBegin => (value & begin) != 0;
  bool get isEnd => (value & end) != 0;
}

// --- Supporting Classes ---

/// Water salinity information.
@JsonSerializable()
class Salinity {
  final WaterType type;
  final double density; // kg/m³

  const Salinity({required this.type, required this.density});

  factory Salinity.fromJson(Map<String, dynamic> json) => _$SalinityFromJson(json);
  Map<String, dynamic> toJson() => _$SalinityToJson(this);

  @override
  String toString() => '${type.name} (${density.toStringAsFixed(1)} kg/m³)';
}

/// Gas mix composition.
@JsonSerializable()
class GasMix {
  final double oxygen; // Fraction (0.0 - 1.0)
  final double helium; // Fraction (0.0 - 1.0)
  final double nitrogen; // Fraction (0.0 - 1.0)
  final GasUsage usage;

  const GasMix({required this.oxygen, required this.helium, required this.nitrogen, this.usage = GasUsage.none});

  factory GasMix.fromJson(Map<String, dynamic> json) => _$GasMixFromJson(json);
  Map<String, dynamic> toJson() => _$GasMixToJson(this);

  /// Oxygen percentage (0-100).
  int get o2Percent => (oxygen * 100).round();

  /// Helium percentage (0-100).
  int get hePercent => (helium * 100).round();

  /// Returns true if this is air (21% O2, no helium).
  bool get isAir => o2Percent == 21 && hePercent == 0;

  /// Returns true if this is nitrox (elevated O2, no helium).
  bool get isNitrox => o2Percent > 21 && hePercent == 0;

  /// Returns true if this is trimix (contains helium).
  bool get isTrimix => hePercent > 0;

  /// Common name for the gas mix (e.g., "Air", "EAN32", "21/35").
  String get name {
    if (isAir) return 'Air';
    if (isTrimix) return '$o2Percent/$hePercent';
    if (isNitrox) return 'EAN$o2Percent';
    return 'O2 $o2Percent%';
  }

  @override
  String toString() => name;
}

/// Tank information.
@JsonSerializable(includeIfNull: false)
class Tank {
  final int? gasMixIndex; // Index into gasMixes list, null if unknown
  final TankVolumeType volumeType;
  final double volume; // Liters (water capacity)
  final double? workPressure; // Bar
  final double? beginPressure; // Bar
  final double? endPressure; // Bar
  final GasUsage usage;

  const Tank({
    this.gasMixIndex,
    this.volumeType = TankVolumeType.none,
    this.volume = 0,
    this.workPressure,
    this.beginPressure,
    this.endPressure,
    this.usage = GasUsage.none,
  });

  factory Tank.fromJson(Map<String, dynamic> json) => _$TankFromJson(json);
  Map<String, dynamic> toJson() => _$TankToJson(this);

  /// Gas consumed in bar (if begin and end pressures are available).
  double? get pressureUsed {
    if (beginPressure != null && endPressure != null) {
      return beginPressure! - endPressure!;
    }
    return null;
  }

  @override
  String toString() {
    final parts = <String>['${volume.toStringAsFixed(1)}L'];
    if (beginPressure != null) parts.add('${beginPressure!.round()}→${endPressure?.round() ?? "?"}bar');
    return parts.join(' ');
  }
}

/// Decompression model settings.
@JsonSerializable(includeIfNull: false)
class DecoModel {
  final DecoModelType type;
  final int conservatism; // Personal adjustment (-ve aggressive, +ve conservative)
  final int? gfLow; // Gradient factor low (Buhlmann only)
  final int? gfHigh; // Gradient factor high (Buhlmann only)

  const DecoModel({required this.type, this.conservatism = 0, this.gfLow, this.gfHigh});

  factory DecoModel.fromJson(Map<String, dynamic> json) => _$DecoModelFromJson(json);
  Map<String, dynamic> toJson() => _$DecoModelToJson(this);

  @override
  String toString() {
    if (type == DecoModelType.buhlmann && gfLow != null && gfHigh != null) {
      return 'Bühlmann GF $gfLow/$gfHigh';
    }
    return type.name;
  }
}

/// GPS location.
@JsonSerializable(includeIfNull: false)
class Location {
  final double latitude; // Decimal degrees
  final double longitude; // Decimal degrees
  final double? altitude; // Meters (optional)

  const Location({required this.latitude, required this.longitude, this.altitude});

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);

  @override
  String toString() {
    final lat = latitude >= 0 ? '${latitude.toStringAsFixed(6)}°N' : '${(-latitude).toStringAsFixed(6)}°S';
    final lng = longitude >= 0 ? '${longitude.toStringAsFixed(6)}°E' : '${(-longitude).toStringAsFixed(6)}°W';
    return '$lat, $lng';
  }
}

// --- Sample Types ---

/// Pressure reading from a tank sensor.
@JsonSerializable()
class TankPressure {
  final int tankIndex;
  final double pressure; // Bar

  factory TankPressure.fromJson(Map<String, dynamic> json) => _$TankPressureFromJson(json);
  Map<String, dynamic> toJson() => _$TankPressureToJson(this);

  const TankPressure({required this.tankIndex, required this.pressure});

  @override
  String toString() => 'Tank $tankIndex: ${pressure.toStringAsFixed(1)} bar';
}

/// PPO2 reading from a sensor.
@JsonSerializable()
class Ppo2Reading {
  final int sensorIndex;
  final double value; // Bar

  const Ppo2Reading({required this.sensorIndex, required this.value});

  factory Ppo2Reading.fromJson(Map<String, dynamic> json) => _$Ppo2ReadingFromJson(json);
  Map<String, dynamic> toJson() => _$Ppo2ReadingToJson(this);

  @override
  String toString() => 'Sensor $sensorIndex: ${value.toStringAsFixed(2)} bar';
}

/// Decompression status at a sample point.
@JsonSerializable()
class DecoStatus {
  final DecoStopType type;
  final int time; // Time at this stop / NDL remaining
  final double depth; // Stop depth in meters (0 for NDL)
  final int tts; // Time to surface

  const DecoStatus({required this.type, required this.time, required this.depth, required this.tts});

  factory DecoStatus.fromJson(Map<String, dynamic> json) => _$DecoStatusFromJson(json);
  Map<String, dynamic> toJson() => _$DecoStatusToJson(this);

  @override
  String toString() {
    if (type == DecoStopType.ndl) {
      return 'NDL: ${time / 60}min';
    }
    return '${type.name} at ${depth.toStringAsFixed(0)}m for ${time}s (TTS: ${tts / 60}min)';
  }
}

/// An event that occurred during the dive.
@JsonSerializable()
class SampleEvent {
  final SampleEventType type;
  final int time;
  final SampleEventFlags flags;
  final int value;

  const SampleEvent({required this.type, required this.time, required this.flags, required this.value});

  factory SampleEvent.fromJson(Map<String, dynamic> json) => _$SampleEventFromJson(json);
  Map<String, dynamic> toJson() => _$SampleEventToJson(this);

  @override
  String toString() => '${type.name} at ${time}s';
}

/// Vendor-specific data.
@JsonSerializable()
class VendorData {
  final int type;
  final String data;

  const VendorData({required this.type, required this.data});

  factory VendorData.fromJson(Map<String, dynamic> json) => _$VendorDataFromJson(json);
  Map<String, dynamic> toJson() => _$VendorDataToJson(this);

  @override
  String toString() => 'Vendor type $type (${data.length} bytes)';
}

/// A single sample point in the dive profile.
@JsonSerializable(includeIfNull: false)
class ComputerSample {
  final double time;
  final double? depth; // Meters
  final double? temperature; // Celsius
  final List<TankPressure>? pressures;
  final List<SampleEvent>? events;
  final int? rbt; // Remaining bottom time (minutes)
  final int? heartbeat; // Heart rate (bpm)
  final int? bearing; // Compass bearing (degrees)
  final double? setpoint; // CCR setpoint (bar)
  final List<Ppo2Reading>? ppo2;
  final double? cns; // CNS percentage (0-100+)
  final DecoStatus? deco;
  final int? gasMixIndex; // Current gas mix index
  final List<VendorData>? vendorData;

  const ComputerSample({
    required this.time,
    this.depth,
    this.temperature,
    this.pressures,
    this.events,
    this.rbt,
    this.heartbeat,
    this.bearing,
    this.setpoint,
    this.ppo2,
    this.cns,
    this.deco,
    this.gasMixIndex,
    this.vendorData,
  });

  factory ComputerSample.fromJson(Map<String, dynamic> json) => _$ComputerSampleFromJson(json);
  Map<String, dynamic> toJson() => _$ComputerSampleToJson(this);

  @override
  String toString() {
    final parts = <String>['${time}s'];
    if (depth != null) parts.add('${depth!.toStringAsFixed(1)}m');
    if (temperature != null) parts.add('${temperature!.toStringAsFixed(1)}°C');
    return parts.join(' ');
  }
}

/// Builder for constructing samples incrementally.
class ComputerSampleBuilder {
  double? time;
  double? depth;
  double? temperature;
  final List<TankPressure> pressures = [];
  final List<SampleEvent> events = [];
  int? rbt;
  int? heartbeat;
  int? bearing;
  double? setpoint;
  final List<Ppo2Reading> ppo2 = [];
  double? cns;
  DecoStatus? deco;
  int? gasMixIndex;
  final List<VendorData> vendorData = [];

  ComputerSample build() => ComputerSample(
    time: time ?? 0,
    depth: depth,
    temperature: temperature,
    pressures: orNull(pressures),
    events: orNull(events),
    rbt: rbt,
    heartbeat: heartbeat,
    bearing: bearing,
    setpoint: setpoint,
    ppo2: orNull(ppo2),
    cns: cns,
    deco: deco,
    gasMixIndex: gasMixIndex,
    vendorData: orNull(vendorData),
  );

  void reset() {
    time = null;
    depth = null;
    temperature = null;
    pressures.clear();
    events.clear();
    rbt = null;
    heartbeat = null;
    bearing = null;
    setpoint = null;
    ppo2.clear();
    cns = null;
    deco = null;
    gasMixIndex = null;
    vendorData.clear();
  }
}

List<T>? orNull<T>(List<T> l) {
  if (l.isEmpty) return null;
  return List.unmodifiable(l);
}

// --- Main Dive Class ---

/// Complete dive data parsed from a dive computer.
@JsonSerializable(includeIfNull: false)
class ComputerDive {
  // Dive computer identity
  final String? model;
  final String? serial;

  // Dive metadata
  final DateTime? dateTime;
  final int? diveTime;
  final int? number; // Dive number (if available)
  final double? maxDepth; // Meters
  final double? avgDepth; // Meters
  final double? surfaceTemperature; // Celsius
  final double? minTemperature; // Celsius
  final double? maxTemperature; // Celsius
  final Salinity? salinity;
  final double? atmosphericPressure; // Bar
  final DiveMode? diveMode;
  final DecoModel? decoModel;
  final Location? location;
  final List<GasMix> gasMixes;
  final List<Tank> tanks;
  final List<ComputerSample> samples;
  final List<SampleEvent> events; // Top-level events list
  final String? fingerprint;

  const ComputerDive({
    this.model,
    this.serial,
    this.dateTime,
    this.diveTime,
    this.number,
    this.maxDepth,
    this.avgDepth,
    this.surfaceTemperature,
    this.minTemperature,
    this.maxTemperature,
    this.salinity,
    this.atmosphericPressure,
    this.diveMode,
    this.decoModel,
    this.location,
    this.gasMixes = const [],
    this.tanks = const [],
    this.samples = const [],
    this.events = const [],
    this.fingerprint,
  });

  factory ComputerDive.fromJson(Map<String, dynamic> json) => _$ComputerDiveFromJson(json);
  Map<String, dynamic> toJson() => _$ComputerDiveToJson(this);

  @override
  String toString() {
    final parts = <String>[];
    if (number != null) parts.add('Dive #$number');
    if (dateTime != null) parts.add(dateTime!.toIso8601String());
    if (diveTime != null) parts.add('${diveTime! / 60}min');
    if (maxDepth != null) parts.add('${maxDepth!.toStringAsFixed(1)}m');
    return parts.join(' | ');
  }
}

/// Builder for constructing Dive objects incrementally during parsing.
class ComputerDiveBuilder {
  String? model;
  String? serial;
  DateTime? dateTime;
  int? diveTime;
  double? maxDepth;
  double? avgDepth;
  double? surfaceTemperature;
  double? minTemperature;
  double? maxTemperature;
  Salinity? salinity;
  double? atmosphericPressure;
  DiveMode? diveMode;
  DecoModel? decoModel;
  Location? location;
  final List<GasMix> gasMixes = [];
  final List<Tank> tanks = [];
  final List<ComputerSample> samples = [];
  final List<SampleEvent> events = [];
  String? fingerprint;

  ComputerDive build() => ComputerDive(
    model: model,
    serial: serial,
    dateTime: dateTime,
    diveTime: diveTime,
    maxDepth: maxDepth,
    avgDepth: avgDepth,
    surfaceTemperature: surfaceTemperature,
    minTemperature: minTemperature,
    maxTemperature: maxTemperature,
    salinity: salinity,
    atmosphericPressure: atmosphericPressure,
    diveMode: diveMode,
    decoModel: decoModel,
    location: location,
    gasMixes: List.unmodifiable(gasMixes),
    tanks: List.unmodifiable(tanks),
    samples: List.unmodifiable(samples),
    events: List.unmodifiable(events),
    fingerprint: fingerprint,
  );
}
