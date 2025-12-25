import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:json_annotation/json_annotation.dart';

import 'libdivecomputer_bindings_generated.dart' as dc;

part 'dive.g.dart';

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
class Sample {
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

  const Sample({
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

  factory Sample.fromJson(Map<String, dynamic> json) => _$SampleFromJson(json);
  Map<String, dynamic> toJson() => _$SampleToJson(this);

  @override
  String toString() {
    final parts = <String>['${time}s'];
    if (depth != null) parts.add('${depth!.toStringAsFixed(1)}m');
    if (temperature != null) parts.add('${temperature!.toStringAsFixed(1)}°C');
    return parts.join(' ');
  }
}

/// Builder for constructing samples incrementally.
class SampleBuilder {
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

  Sample build() => Sample(
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
class Dive {
  // --- Basic Info ---
  final DateTime? dateTime;
  final int? diveTime;
  final int? number; // Dive number (if available)

  // --- Depth ---
  final double? maxDepth; // Meters
  final double? avgDepth; // Meters

  // --- Temperature ---
  final double? surfaceTemperature; // Celsius
  final double? minTemperature; // Celsius
  final double? maxTemperature; // Celsius

  // --- Environment ---
  final Salinity? salinity;
  final double? atmosphericPressure; // Bar

  // --- Dive Mode & Deco Model ---
  final DiveMode? diveMode;
  final DecoModel? decoModel;

  // --- Location ---
  final Location? location;

  // --- Gas Mixes ---
  final List<GasMix> gasMixes;

  // --- Tanks ---
  final List<Tank> tanks;

  // --- Profile Data ---
  final List<Sample> samples;

  // --- Raw Data ---
  final String? fingerprint; // Unique identifier for this dive

  const Dive({
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
    this.fingerprint,
  });

  factory Dive.fromJson(Map<String, dynamic> json) => _$DiveFromJson(json);
  Map<String, dynamic> toJson() => _$DiveToJson(this);

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
class DiveBuilder {
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
  final List<Sample> samples = [];
  String? fingerprint;

  Dive build() => Dive(
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
    fingerprint: fingerprint,
  );
}

// --- Parser Functions ---

/// Parses a dive from raw data using libdivecomputer.
///
/// This function must be called from an isolate where FFI is available.
/// The [parser] must be a valid dc_parser_t pointer created via dc_parser_new.
Dive parseDiveFromParser(ffi.Pointer<dc.dc_parser_t> parser, {String? fingerprint}) {
  final builder = DiveBuilder()..fingerprint = fingerprint;

  // --- DateTime ---
  final datetime = calloc<dc.dc_datetime_t>();
  if (dc.dc_parser_get_datetime(parser, datetime) == dc.dc_status_t.DC_STATUS_SUCCESS) {
    builder.dateTime = DateTime(datetime.ref.year, datetime.ref.month, datetime.ref.day, datetime.ref.hour, datetime.ref.minute, datetime.ref.second);
  }
  calloc.free(datetime);

  // --- Dive Time ---
  final diveTimePtr = calloc<ffi.UnsignedInt>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_DIVETIME, diveTimePtr.cast())) {
    builder.diveTime = diveTimePtr.value;
  }
  calloc.free(diveTimePtr);

  // --- Max Depth ---
  final maxDepthPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_MAXDEPTH, maxDepthPtr.cast())) {
    builder.maxDepth = maxDepthPtr.value;
  }
  calloc.free(maxDepthPtr);

  // --- Avg Depth ---
  final avgDepthPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_AVGDEPTH, avgDepthPtr.cast())) {
    builder.avgDepth = avgDepthPtr.value;
  }
  calloc.free(avgDepthPtr);

  // --- Surface Temperature ---
  final surfaceTempPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_TEMPERATURE_SURFACE, surfaceTempPtr.cast())) {
    builder.surfaceTemperature = surfaceTempPtr.value;
  }
  calloc.free(surfaceTempPtr);

  // --- Min Temperature ---
  final minTempPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_TEMPERATURE_MINIMUM, minTempPtr.cast())) {
    builder.minTemperature = minTempPtr.value;
  }
  calloc.free(minTempPtr);

  // --- Max Temperature ---
  final maxTempPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_TEMPERATURE_MAXIMUM, maxTempPtr.cast())) {
    builder.maxTemperature = maxTempPtr.value;
  }
  calloc.free(maxTempPtr);

  // --- Atmospheric Pressure ---
  final atmosphericPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_ATMOSPHERIC, atmosphericPtr.cast())) {
    builder.atmosphericPressure = atmosphericPtr.value;
  }
  calloc.free(atmosphericPtr);

  // --- Salinity ---
  final salinityPtr = calloc<dc.dc_salinity_t>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_SALINITY, salinityPtr.cast())) {
    final waterType = WaterType.fromDcValue(salinityPtr.ref.type);
    if (waterType != null) {
      builder.salinity = Salinity(type: waterType, density: salinityPtr.ref.density);
    }
  }
  calloc.free(salinityPtr);

  // --- Dive Mode ---
  final diveModePtr = calloc<ffi.UnsignedInt>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_DIVEMODE, diveModePtr.cast())) {
    builder.diveMode = DiveMode.fromDcValue(diveModePtr.value);
  }
  calloc.free(diveModePtr);

  // --- Deco Model ---
  final decoModelPtr = calloc<dc.dc_decomodel_t>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_DECOMODEL, decoModelPtr.cast())) {
    final type = DecoModelType.fromDcValue(decoModelPtr.ref.type);
    int? gfLow, gfHigh;
    if (type == DecoModelType.buhlmann) {
      gfLow = decoModelPtr.ref.params.gf.low;
      gfHigh = decoModelPtr.ref.params.gf.high;
    }
    builder.decoModel = DecoModel(type: type, conservatism: decoModelPtr.ref.conservatism, gfLow: gfLow, gfHigh: gfHigh);
  }
  calloc.free(decoModelPtr);

  // --- Location ---
  final locationPtr = calloc<dc.dc_location_t>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_LOCATION, locationPtr.cast())) {
    builder.location = Location(
      latitude: locationPtr.ref.latitude,
      longitude: locationPtr.ref.longitude,
      altitude: locationPtr.ref.altitude != 0 ? locationPtr.ref.altitude : null,
    );
  }
  calloc.free(locationPtr);

  // --- Gas Mixes ---
  final gasMixCountPtr = calloc<ffi.UnsignedInt>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_GASMIX_COUNT, gasMixCountPtr.cast())) {
    final count = gasMixCountPtr.value;
    final gasMixPtr = calloc<dc.dc_gasmix_t>();
    for (var i = 0; i < count; i++) {
      if (_getFieldIndexed(parser, dc.dc_field_type_t.DC_FIELD_GASMIX, i, gasMixPtr.cast())) {
        builder.gasMixes.add(
          GasMix(
            oxygen: gasMixPtr.ref.oxygen,
            helium: gasMixPtr.ref.helium,
            nitrogen: gasMixPtr.ref.nitrogen,
            usage: GasUsage.fromDcValue(gasMixPtr.ref.usage),
          ),
        );
      }
    }
    calloc.free(gasMixPtr);
  }
  calloc.free(gasMixCountPtr);

  // --- Tanks ---
  final tankCountPtr = calloc<ffi.UnsignedInt>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_TANK_COUNT, tankCountPtr.cast())) {
    final count = tankCountPtr.value;
    final tankPtr = calloc<dc.dc_tank_t>();
    for (var i = 0; i < count; i++) {
      if (_getFieldIndexed(parser, dc.dc_field_type_t.DC_FIELD_TANK, i, tankPtr.cast())) {
        // DC_GASMIX_UNKNOWN is 0xFFFFFFFF
        final gasMixIndex = tankPtr.ref.gasmix == 0xFFFFFFFF ? null : tankPtr.ref.gasmix;
        builder.tanks.add(
          Tank(
            gasMixIndex: gasMixIndex,
            volumeType: TankVolumeType.fromDcValue(tankPtr.ref.type),
            volume: tankPtr.ref.volume,
            workPressure: tankPtr.ref.workpressure > 0 ? tankPtr.ref.workpressure : null,
            beginPressure: tankPtr.ref.beginpressure > 0 ? tankPtr.ref.beginpressure : null,
            endPressure: tankPtr.ref.endpressure > 0 ? tankPtr.ref.endpressure : null,
            usage: GasUsage.fromDcValue(tankPtr.ref.usage),
          ),
        );
      }
    }
    calloc.free(tankPtr);
  }
  calloc.free(tankCountPtr);

  // --- Samples ---
  _parseSamples(parser, builder);

  return builder.build();
}

/// Helper to get a field from the parser.
bool _getField(ffi.Pointer<dc.dc_parser_t> parser, dc.dc_field_type_t type, ffi.Pointer<ffi.Void> value) {
  return dc.dc_parser_get_field(parser, type, 0, value) == dc.dc_status_t.DC_STATUS_SUCCESS;
}

/// Helper to get an indexed field from the parser.
bool _getFieldIndexed(ffi.Pointer<dc.dc_parser_t> parser, dc.dc_field_type_t type, int index, ffi.Pointer<ffi.Void> value) {
  return dc.dc_parser_get_field(parser, type, index, value) == dc.dc_status_t.DC_STATUS_SUCCESS;
}

/// Global state for sample callback (needed because NativeCallable can't capture closures).
DiveBuilder? _currentDiveBuilder;
SampleBuilder? _currentSampleBuilder;

/// Parse samples from the parser.
void _parseSamples(ffi.Pointer<dc.dc_parser_t> parser, DiveBuilder builder) {
  _currentDiveBuilder = builder;
  _currentSampleBuilder = SampleBuilder();

  final callback = ffi.NativeCallable<dc.dc_sample_callback_tFunction>.isolateLocal(_sampleCallback);

  dc.dc_parser_samples_foreach(parser, callback.nativeFunction, ffi.nullptr);

  callback.close();

  // Add the last sample if it has data
  if (_currentSampleBuilder!.time != null) {
    builder.samples.add(_currentSampleBuilder!.build());
  }

  _currentDiveBuilder = null;
  _currentSampleBuilder = null;
}

/// Sample callback for dc_parser_samples_foreach.
void _sampleCallback(int typeValue, ffi.Pointer<dc.dc_sample_value_t> value, ffi.Pointer<ffi.Void> userdata) {
  final builder = _currentSampleBuilder!;
  final diveBuilder = _currentDiveBuilder!;
  final type = dc.dc_sample_type_t.fromValue(typeValue);

  switch (type) {
    case dc.dc_sample_type_t.DC_SAMPLE_TIME:
      // New sample starts with TIME - save previous sample if exists
      if (builder.time != null) {
        diveBuilder.samples.add(builder.build());
        builder.reset();
      }
      builder.time = value.ref.time / 1000;

    case dc.dc_sample_type_t.DC_SAMPLE_DEPTH:
      builder.depth = value.ref.depth;

    case dc.dc_sample_type_t.DC_SAMPLE_PRESSURE:
      builder.pressures.add(TankPressure(tankIndex: value.ref.pressure.tank, pressure: value.ref.pressure.value));

    case dc.dc_sample_type_t.DC_SAMPLE_TEMPERATURE:
      builder.temperature = value.ref.temperature;

    case dc.dc_sample_type_t.DC_SAMPLE_EVENT:
      builder.events.add(
        SampleEvent(
          type: SampleEventType.fromDcValue(value.ref.event.type),
          time: value.ref.event.time,
          flags: SampleEventFlags(value.ref.event.flags),
          value: value.ref.event.value,
        ),
      );

    case dc.dc_sample_type_t.DC_SAMPLE_RBT:
      builder.rbt = value.ref.rbt;

    case dc.dc_sample_type_t.DC_SAMPLE_HEARTBEAT:
      builder.heartbeat = value.ref.heartbeat;

    case dc.dc_sample_type_t.DC_SAMPLE_BEARING:
      builder.bearing = value.ref.bearing;

    case dc.dc_sample_type_t.DC_SAMPLE_VENDOR:
      final vendorData = value.ref.vendor;
      if (vendorData.size > 0 && vendorData.data != ffi.nullptr) {
        final bytes = Uint8List(vendorData.size);
        final dataPtr = vendorData.data.cast<ffi.Uint8>();
        for (var i = 0; i < vendorData.size; i++) {
          bytes[i] = dataPtr[i];
        }
        builder.vendorData.add(VendorData(type: vendorData.type, data: bytes.toString()));
      }

    case dc.dc_sample_type_t.DC_SAMPLE_SETPOINT:
      builder.setpoint = value.ref.setpoint;

    case dc.dc_sample_type_t.DC_SAMPLE_PPO2:
      builder.ppo2.add(Ppo2Reading(sensorIndex: value.ref.ppo2.sensor, value: value.ref.ppo2.value));

    case dc.dc_sample_type_t.DC_SAMPLE_CNS:
      builder.cns = value.ref.cns;

    case dc.dc_sample_type_t.DC_SAMPLE_DECO:
      builder.deco = DecoStatus(
        type: DecoStopType.fromDcValue(value.ref.deco.type),
        time: value.ref.deco.time,
        depth: value.ref.deco.depth,
        tts: value.ref.deco.tts,
      );

    case dc.dc_sample_type_t.DC_SAMPLE_GASMIX:
      builder.gasMixIndex = value.ref.gasmix;
  }
}
