// This is a generated file - do not edit.
//
// Generated from log.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'log.pbenum.dart';
import 'types.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'log.pbenum.dart';

/// Complete dive data parsed from a dive computer.
class Log extends $pb.GeneratedMessage {
  factory Log({
    $core.String? model,
    $core.String? serial,
    $0.Timestamp? dateTime,
    $core.int? diveTime,
    $core.double? maxDepth,
    $core.double? avgDepth,
    $core.double? surfaceTemperature,
    $core.double? minTemperature,
    $core.double? maxTemperature,
    Salinity? salinity,
    $core.double? atmosphericPressure,
    DiveMode? diveMode,
    DecoModel? decoModel,
    $1.Position? position,
    $core.Iterable<GasMix>? gasMixes,
    $core.Iterable<Tank>? tanks,
    $core.Iterable<LogSample>? samples,
    $core.List<$core.int>? ldcFingerprint,
    $core.String? uniqueID,
  }) {
    final result = create();
    if (model != null) result.model = model;
    if (serial != null) result.serial = serial;
    if (dateTime != null) result.dateTime = dateTime;
    if (diveTime != null) result.diveTime = diveTime;
    if (maxDepth != null) result.maxDepth = maxDepth;
    if (avgDepth != null) result.avgDepth = avgDepth;
    if (surfaceTemperature != null)
      result.surfaceTemperature = surfaceTemperature;
    if (minTemperature != null) result.minTemperature = minTemperature;
    if (maxTemperature != null) result.maxTemperature = maxTemperature;
    if (salinity != null) result.salinity = salinity;
    if (atmosphericPressure != null)
      result.atmosphericPressure = atmosphericPressure;
    if (diveMode != null) result.diveMode = diveMode;
    if (decoModel != null) result.decoModel = decoModel;
    if (position != null) result.position = position;
    if (gasMixes != null) result.gasMixes.addAll(gasMixes);
    if (tanks != null) result.tanks.addAll(tanks);
    if (samples != null) result.samples.addAll(samples);
    if (ldcFingerprint != null) result.ldcFingerprint = ldcFingerprint;
    if (uniqueID != null) result.uniqueID = uniqueID;
    return result;
  }

  Log._();

  factory Log.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Log.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Log',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'model')
    ..aOS(2, _omitFieldNames ? '' : 'serial')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'dateTime',
        subBuilder: $0.Timestamp.create)
    ..aI(4, _omitFieldNames ? '' : 'diveTime')
    ..aD(6, _omitFieldNames ? '' : 'maxDepth')
    ..aD(7, _omitFieldNames ? '' : 'avgDepth')
    ..aD(8, _omitFieldNames ? '' : 'surfaceTemperature')
    ..aD(9, _omitFieldNames ? '' : 'minTemperature')
    ..aD(10, _omitFieldNames ? '' : 'maxTemperature')
    ..aOM<Salinity>(11, _omitFieldNames ? '' : 'salinity',
        subBuilder: Salinity.create)
    ..aD(12, _omitFieldNames ? '' : 'atmosphericPressure')
    ..aE<DiveMode>(13, _omitFieldNames ? '' : 'diveMode',
        enumValues: DiveMode.values)
    ..aOM<DecoModel>(14, _omitFieldNames ? '' : 'decoModel',
        subBuilder: DecoModel.create)
    ..aOM<$1.Position>(15, _omitFieldNames ? '' : 'position',
        subBuilder: $1.Position.create)
    ..pPM<GasMix>(16, _omitFieldNames ? '' : 'gasMixes',
        subBuilder: GasMix.create)
    ..pPM<Tank>(17, _omitFieldNames ? '' : 'tanks', subBuilder: Tank.create)
    ..pPM<LogSample>(18, _omitFieldNames ? '' : 'samples',
        subBuilder: LogSample.create)
    ..a<$core.List<$core.int>>(
        19, _omitFieldNames ? '' : 'ldcFingerprint', $pb.PbFieldType.OY)
    ..aOS(20, _omitFieldNames ? '' : 'uniqueID', protoName: 'uniqueID')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Log clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Log copyWith(void Function(Log) updates) =>
      super.copyWith((message) => updates(message as Log)) as Log;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Log create() => Log._();
  @$core.override
  Log createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Log getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Log>(create);
  static Log? _defaultInstance;

  /// Dive computer identity
  @$pb.TagNumber(1)
  $core.String get model => $_getSZ(0);
  @$pb.TagNumber(1)
  set model($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasModel() => $_has(0);
  @$pb.TagNumber(1)
  void clearModel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get serial => $_getSZ(1);
  @$pb.TagNumber(2)
  set serial($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSerial() => $_has(1);
  @$pb.TagNumber(2)
  void clearSerial() => $_clearField(2);

  /// Dive metadata
  @$pb.TagNumber(3)
  $0.Timestamp get dateTime => $_getN(2);
  @$pb.TagNumber(3)
  set dateTime($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDateTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearDateTime() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureDateTime() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.int get diveTime => $_getIZ(3);
  @$pb.TagNumber(4)
  set diveTime($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDiveTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearDiveTime() => $_clearField(4);

  @$pb.TagNumber(6)
  $core.double get maxDepth => $_getN(4);
  @$pb.TagNumber(6)
  set maxDepth($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxDepth() => $_has(4);
  @$pb.TagNumber(6)
  void clearMaxDepth() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get avgDepth => $_getN(5);
  @$pb.TagNumber(7)
  set avgDepth($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(7)
  $core.bool hasAvgDepth() => $_has(5);
  @$pb.TagNumber(7)
  void clearAvgDepth() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get surfaceTemperature => $_getN(6);
  @$pb.TagNumber(8)
  set surfaceTemperature($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(8)
  $core.bool hasSurfaceTemperature() => $_has(6);
  @$pb.TagNumber(8)
  void clearSurfaceTemperature() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get minTemperature => $_getN(7);
  @$pb.TagNumber(9)
  set minTemperature($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(9)
  $core.bool hasMinTemperature() => $_has(7);
  @$pb.TagNumber(9)
  void clearMinTemperature() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get maxTemperature => $_getN(8);
  @$pb.TagNumber(10)
  set maxTemperature($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(10)
  $core.bool hasMaxTemperature() => $_has(8);
  @$pb.TagNumber(10)
  void clearMaxTemperature() => $_clearField(10);

  @$pb.TagNumber(11)
  Salinity get salinity => $_getN(9);
  @$pb.TagNumber(11)
  set salinity(Salinity value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasSalinity() => $_has(9);
  @$pb.TagNumber(11)
  void clearSalinity() => $_clearField(11);
  @$pb.TagNumber(11)
  Salinity ensureSalinity() => $_ensure(9);

  @$pb.TagNumber(12)
  $core.double get atmosphericPressure => $_getN(10);
  @$pb.TagNumber(12)
  set atmosphericPressure($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(12)
  $core.bool hasAtmosphericPressure() => $_has(10);
  @$pb.TagNumber(12)
  void clearAtmosphericPressure() => $_clearField(12);

  @$pb.TagNumber(13)
  DiveMode get diveMode => $_getN(11);
  @$pb.TagNumber(13)
  set diveMode(DiveMode value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasDiveMode() => $_has(11);
  @$pb.TagNumber(13)
  void clearDiveMode() => $_clearField(13);

  @$pb.TagNumber(14)
  DecoModel get decoModel => $_getN(12);
  @$pb.TagNumber(14)
  set decoModel(DecoModel value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasDecoModel() => $_has(12);
  @$pb.TagNumber(14)
  void clearDecoModel() => $_clearField(14);
  @$pb.TagNumber(14)
  DecoModel ensureDecoModel() => $_ensure(12);

  @$pb.TagNumber(15)
  $1.Position get position => $_getN(13);
  @$pb.TagNumber(15)
  set position($1.Position value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasPosition() => $_has(13);
  @$pb.TagNumber(15)
  void clearPosition() => $_clearField(15);
  @$pb.TagNumber(15)
  $1.Position ensurePosition() => $_ensure(13);

  /// Gas and tank data
  @$pb.TagNumber(16)
  $pb.PbList<GasMix> get gasMixes => $_getList(14);

  @$pb.TagNumber(17)
  $pb.PbList<Tank> get tanks => $_getList(15);

  /// Profile data
  @$pb.TagNumber(18)
  $pb.PbList<LogSample> get samples => $_getList(16);

  /// Fingerprint reported by libdivecomputer
  @$pb.TagNumber(19)
  $core.List<$core.int> get ldcFingerprint => $_getN(17);
  @$pb.TagNumber(19)
  set ldcFingerprint($core.List<$core.int> value) => $_setBytes(17, value);
  @$pb.TagNumber(19)
  $core.bool hasLdcFingerprint() => $_has(17);
  @$pb.TagNumber(19)
  void clearLdcFingerprint() => $_clearField(19);

  /// Unique ID calculated by Bubbletrail
  @$pb.TagNumber(20)
  $core.String get uniqueID => $_getSZ(18);
  @$pb.TagNumber(20)
  set uniqueID($core.String value) => $_setString(18, value);
  @$pb.TagNumber(20)
  $core.bool hasUniqueID() => $_has(18);
  @$pb.TagNumber(20)
  void clearUniqueID() => $_clearField(20);
}

/// A single sample point in the dive profile.
class LogSample extends $pb.GeneratedMessage {
  factory LogSample({
    $core.double? time,
    $core.double? depth,
    $core.double? temperature,
    $core.Iterable<TankPressure>? pressures,
    $core.Iterable<SampleEvent>? events,
    $core.int? rbt,
    $core.int? heartbeat,
    $core.int? bearing,
    $core.double? setpoint,
    $core.Iterable<Ppo2Reading>? ppo2,
    $core.double? cns,
    DecoStatus? deco,
    $core.int? gasMixIndex,
    $core.Iterable<VendorData>? vendorData,
  }) {
    final result = create();
    if (time != null) result.time = time;
    if (depth != null) result.depth = depth;
    if (temperature != null) result.temperature = temperature;
    if (pressures != null) result.pressures.addAll(pressures);
    if (events != null) result.events.addAll(events);
    if (rbt != null) result.rbt = rbt;
    if (heartbeat != null) result.heartbeat = heartbeat;
    if (bearing != null) result.bearing = bearing;
    if (setpoint != null) result.setpoint = setpoint;
    if (ppo2 != null) result.ppo2.addAll(ppo2);
    if (cns != null) result.cns = cns;
    if (deco != null) result.deco = deco;
    if (gasMixIndex != null) result.gasMixIndex = gasMixIndex;
    if (vendorData != null) result.vendorData.addAll(vendorData);
    return result;
  }

  LogSample._();

  factory LogSample.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogSample.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogSample',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'time')
    ..aD(2, _omitFieldNames ? '' : 'depth')
    ..aD(3, _omitFieldNames ? '' : 'temperature')
    ..pPM<TankPressure>(4, _omitFieldNames ? '' : 'pressures',
        subBuilder: TankPressure.create)
    ..pPM<SampleEvent>(5, _omitFieldNames ? '' : 'events',
        subBuilder: SampleEvent.create)
    ..aI(6, _omitFieldNames ? '' : 'rbt')
    ..aI(7, _omitFieldNames ? '' : 'heartbeat')
    ..aI(8, _omitFieldNames ? '' : 'bearing')
    ..aD(9, _omitFieldNames ? '' : 'setpoint')
    ..pPM<Ppo2Reading>(10, _omitFieldNames ? '' : 'ppo2',
        subBuilder: Ppo2Reading.create)
    ..aD(11, _omitFieldNames ? '' : 'cns')
    ..aOM<DecoStatus>(12, _omitFieldNames ? '' : 'deco',
        subBuilder: DecoStatus.create)
    ..aI(13, _omitFieldNames ? '' : 'gasMixIndex')
    ..pPM<VendorData>(14, _omitFieldNames ? '' : 'vendorData',
        subBuilder: VendorData.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogSample clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogSample copyWith(void Function(LogSample) updates) =>
      super.copyWith((message) => updates(message as LogSample)) as LogSample;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogSample create() => LogSample._();
  @$core.override
  LogSample createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogSample getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogSample>(create);
  static LogSample? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get time => $_getN(0);
  @$pb.TagNumber(1)
  set time($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearTime() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get depth => $_getN(1);
  @$pb.TagNumber(2)
  set depth($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDepth() => $_has(1);
  @$pb.TagNumber(2)
  void clearDepth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get temperature => $_getN(2);
  @$pb.TagNumber(3)
  set temperature($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTemperature() => $_has(2);
  @$pb.TagNumber(3)
  void clearTemperature() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<TankPressure> get pressures => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<SampleEvent> get events => $_getList(4);

  @$pb.TagNumber(6)
  $core.int get rbt => $_getIZ(5);
  @$pb.TagNumber(6)
  set rbt($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRbt() => $_has(5);
  @$pb.TagNumber(6)
  void clearRbt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get heartbeat => $_getIZ(6);
  @$pb.TagNumber(7)
  set heartbeat($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHeartbeat() => $_has(6);
  @$pb.TagNumber(7)
  void clearHeartbeat() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get bearing => $_getIZ(7);
  @$pb.TagNumber(8)
  set bearing($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBearing() => $_has(7);
  @$pb.TagNumber(8)
  void clearBearing() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get setpoint => $_getN(8);
  @$pb.TagNumber(9)
  set setpoint($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSetpoint() => $_has(8);
  @$pb.TagNumber(9)
  void clearSetpoint() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<Ppo2Reading> get ppo2 => $_getList(9);

  @$pb.TagNumber(11)
  $core.double get cns => $_getN(10);
  @$pb.TagNumber(11)
  set cns($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCns() => $_has(10);
  @$pb.TagNumber(11)
  void clearCns() => $_clearField(11);

  @$pb.TagNumber(12)
  DecoStatus get deco => $_getN(11);
  @$pb.TagNumber(12)
  set deco(DecoStatus value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasDeco() => $_has(11);
  @$pb.TagNumber(12)
  void clearDeco() => $_clearField(12);
  @$pb.TagNumber(12)
  DecoStatus ensureDeco() => $_ensure(11);

  @$pb.TagNumber(13)
  $core.int get gasMixIndex => $_getIZ(12);
  @$pb.TagNumber(13)
  set gasMixIndex($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasGasMixIndex() => $_has(12);
  @$pb.TagNumber(13)
  void clearGasMixIndex() => $_clearField(13);

  @$pb.TagNumber(14)
  $pb.PbList<VendorData> get vendorData => $_getList(13);
}

/// Water salinity information.
class Salinity extends $pb.GeneratedMessage {
  factory Salinity({
    WaterType? type,
    $core.double? density,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (density != null) result.density = density;
    return result;
  }

  Salinity._();

  factory Salinity.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Salinity.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Salinity',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aE<WaterType>(1, _omitFieldNames ? '' : 'type',
        enumValues: WaterType.values)
    ..aD(2, _omitFieldNames ? '' : 'density')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Salinity clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Salinity copyWith(void Function(Salinity) updates) =>
      super.copyWith((message) => updates(message as Salinity)) as Salinity;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Salinity create() => Salinity._();
  @$core.override
  Salinity createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Salinity getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Salinity>(create);
  static Salinity? _defaultInstance;

  @$pb.TagNumber(1)
  WaterType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(WaterType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get density => $_getN(1);
  @$pb.TagNumber(2)
  set density($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDensity() => $_has(1);
  @$pb.TagNumber(2)
  void clearDensity() => $_clearField(2);
}

/// Gas mix composition.
class GasMix extends $pb.GeneratedMessage {
  factory GasMix({
    $core.double? oxygen,
    $core.double? helium,
    $core.double? nitrogen,
    GasUsage? usage,
  }) {
    final result = create();
    if (oxygen != null) result.oxygen = oxygen;
    if (helium != null) result.helium = helium;
    if (nitrogen != null) result.nitrogen = nitrogen;
    if (usage != null) result.usage = usage;
    return result;
  }

  GasMix._();

  factory GasMix.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GasMix.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GasMix',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'oxygen')
    ..aD(2, _omitFieldNames ? '' : 'helium')
    ..aD(3, _omitFieldNames ? '' : 'nitrogen')
    ..aE<GasUsage>(4, _omitFieldNames ? '' : 'usage',
        enumValues: GasUsage.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GasMix clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GasMix copyWith(void Function(GasMix) updates) =>
      super.copyWith((message) => updates(message as GasMix)) as GasMix;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GasMix create() => GasMix._();
  @$core.override
  GasMix createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GasMix getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GasMix>(create);
  static GasMix? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get oxygen => $_getN(0);
  @$pb.TagNumber(1)
  set oxygen($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOxygen() => $_has(0);
  @$pb.TagNumber(1)
  void clearOxygen() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get helium => $_getN(1);
  @$pb.TagNumber(2)
  set helium($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHelium() => $_has(1);
  @$pb.TagNumber(2)
  void clearHelium() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get nitrogen => $_getN(2);
  @$pb.TagNumber(3)
  set nitrogen($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNitrogen() => $_has(2);
  @$pb.TagNumber(3)
  void clearNitrogen() => $_clearField(3);

  @$pb.TagNumber(4)
  GasUsage get usage => $_getN(3);
  @$pb.TagNumber(4)
  set usage(GasUsage value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUsage() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsage() => $_clearField(4);
}

/// Tank information.
class Tank extends $pb.GeneratedMessage {
  factory Tank({
    $core.int? gasMixIndex,
    TankVolumeType? volumeType,
    $core.double? volume,
    $core.double? workPressure,
    $core.double? beginPressure,
    $core.double? endPressure,
    GasUsage? usage,
  }) {
    final result = create();
    if (gasMixIndex != null) result.gasMixIndex = gasMixIndex;
    if (volumeType != null) result.volumeType = volumeType;
    if (volume != null) result.volume = volume;
    if (workPressure != null) result.workPressure = workPressure;
    if (beginPressure != null) result.beginPressure = beginPressure;
    if (endPressure != null) result.endPressure = endPressure;
    if (usage != null) result.usage = usage;
    return result;
  }

  Tank._();

  factory Tank.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Tank.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tank',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'gasMixIndex')
    ..aE<TankVolumeType>(2, _omitFieldNames ? '' : 'volumeType',
        enumValues: TankVolumeType.values)
    ..aD(3, _omitFieldNames ? '' : 'volume')
    ..aD(4, _omitFieldNames ? '' : 'workPressure')
    ..aD(5, _omitFieldNames ? '' : 'beginPressure')
    ..aD(6, _omitFieldNames ? '' : 'endPressure')
    ..aE<GasUsage>(7, _omitFieldNames ? '' : 'usage',
        enumValues: GasUsage.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tank clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tank copyWith(void Function(Tank) updates) =>
      super.copyWith((message) => updates(message as Tank)) as Tank;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tank create() => Tank._();
  @$core.override
  Tank createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Tank getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tank>(create);
  static Tank? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get gasMixIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set gasMixIndex($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGasMixIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearGasMixIndex() => $_clearField(1);

  @$pb.TagNumber(2)
  TankVolumeType get volumeType => $_getN(1);
  @$pb.TagNumber(2)
  set volumeType(TankVolumeType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasVolumeType() => $_has(1);
  @$pb.TagNumber(2)
  void clearVolumeType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get volume => $_getN(2);
  @$pb.TagNumber(3)
  set volume($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVolume() => $_has(2);
  @$pb.TagNumber(3)
  void clearVolume() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get workPressure => $_getN(3);
  @$pb.TagNumber(4)
  set workPressure($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWorkPressure() => $_has(3);
  @$pb.TagNumber(4)
  void clearWorkPressure() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get beginPressure => $_getN(4);
  @$pb.TagNumber(5)
  set beginPressure($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBeginPressure() => $_has(4);
  @$pb.TagNumber(5)
  void clearBeginPressure() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get endPressure => $_getN(5);
  @$pb.TagNumber(6)
  set endPressure($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEndPressure() => $_has(5);
  @$pb.TagNumber(6)
  void clearEndPressure() => $_clearField(6);

  @$pb.TagNumber(7)
  GasUsage get usage => $_getN(6);
  @$pb.TagNumber(7)
  set usage(GasUsage value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasUsage() => $_has(6);
  @$pb.TagNumber(7)
  void clearUsage() => $_clearField(7);
}

/// Decompression model settings.
class DecoModel extends $pb.GeneratedMessage {
  factory DecoModel({
    DecoModelType? type,
    $core.int? conservatism,
    $core.int? gfLow,
    $core.int? gfHigh,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (conservatism != null) result.conservatism = conservatism;
    if (gfLow != null) result.gfLow = gfLow;
    if (gfHigh != null) result.gfHigh = gfHigh;
    return result;
  }

  DecoModel._();

  factory DecoModel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DecoModel.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DecoModel',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aE<DecoModelType>(1, _omitFieldNames ? '' : 'type',
        enumValues: DecoModelType.values)
    ..aI(2, _omitFieldNames ? '' : 'conservatism')
    ..aI(3, _omitFieldNames ? '' : 'gfLow')
    ..aI(4, _omitFieldNames ? '' : 'gfHigh')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecoModel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecoModel copyWith(void Function(DecoModel) updates) =>
      super.copyWith((message) => updates(message as DecoModel)) as DecoModel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecoModel create() => DecoModel._();
  @$core.override
  DecoModel createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DecoModel getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecoModel>(create);
  static DecoModel? _defaultInstance;

  @$pb.TagNumber(1)
  DecoModelType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(DecoModelType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get conservatism => $_getIZ(1);
  @$pb.TagNumber(2)
  set conservatism($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConservatism() => $_has(1);
  @$pb.TagNumber(2)
  void clearConservatism() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get gfLow => $_getIZ(2);
  @$pb.TagNumber(3)
  set gfLow($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGfLow() => $_has(2);
  @$pb.TagNumber(3)
  void clearGfLow() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get gfHigh => $_getIZ(3);
  @$pb.TagNumber(4)
  set gfHigh($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGfHigh() => $_has(3);
  @$pb.TagNumber(4)
  void clearGfHigh() => $_clearField(4);
}

/// Pressure reading from a tank sensor.
class TankPressure extends $pb.GeneratedMessage {
  factory TankPressure({
    $core.int? tankIndex,
    $core.double? pressure,
  }) {
    final result = create();
    if (tankIndex != null) result.tankIndex = tankIndex;
    if (pressure != null) result.pressure = pressure;
    return result;
  }

  TankPressure._();

  factory TankPressure.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TankPressure.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TankPressure',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'tankIndex')
    ..aD(2, _omitFieldNames ? '' : 'pressure')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TankPressure clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TankPressure copyWith(void Function(TankPressure) updates) =>
      super.copyWith((message) => updates(message as TankPressure))
          as TankPressure;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TankPressure create() => TankPressure._();
  @$core.override
  TankPressure createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TankPressure getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TankPressure>(create);
  static TankPressure? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get tankIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set tankIndex($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTankIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearTankIndex() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get pressure => $_getN(1);
  @$pb.TagNumber(2)
  set pressure($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPressure() => $_has(1);
  @$pb.TagNumber(2)
  void clearPressure() => $_clearField(2);
}

/// PPO2 reading from a sensor.
class Ppo2Reading extends $pb.GeneratedMessage {
  factory Ppo2Reading({
    $core.int? sensorIndex,
    $core.double? value,
  }) {
    final result = create();
    if (sensorIndex != null) result.sensorIndex = sensorIndex;
    if (value != null) result.value = value;
    return result;
  }

  Ppo2Reading._();

  factory Ppo2Reading.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Ppo2Reading.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Ppo2Reading',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'sensorIndex')
    ..aD(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ppo2Reading clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Ppo2Reading copyWith(void Function(Ppo2Reading) updates) =>
      super.copyWith((message) => updates(message as Ppo2Reading))
          as Ppo2Reading;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Ppo2Reading create() => Ppo2Reading._();
  @$core.override
  Ppo2Reading createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Ppo2Reading getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Ppo2Reading>(create);
  static Ppo2Reading? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sensorIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set sensorIndex($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSensorIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensorIndex() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
}

/// Decompression status at a sample point.
class DecoStatus extends $pb.GeneratedMessage {
  factory DecoStatus({
    DecoStopType? type,
    $core.int? time,
    $core.double? depth,
    $core.int? tts,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (time != null) result.time = time;
    if (depth != null) result.depth = depth;
    if (tts != null) result.tts = tts;
    return result;
  }

  DecoStatus._();

  factory DecoStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DecoStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DecoStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aE<DecoStopType>(1, _omitFieldNames ? '' : 'type',
        enumValues: DecoStopType.values)
    ..aI(2, _omitFieldNames ? '' : 'time')
    ..aD(3, _omitFieldNames ? '' : 'depth')
    ..aI(4, _omitFieldNames ? '' : 'tts')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecoStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecoStatus copyWith(void Function(DecoStatus) updates) =>
      super.copyWith((message) => updates(message as DecoStatus)) as DecoStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecoStatus create() => DecoStatus._();
  @$core.override
  DecoStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DecoStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecoStatus>(create);
  static DecoStatus? _defaultInstance;

  @$pb.TagNumber(1)
  DecoStopType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(DecoStopType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get time => $_getIZ(1);
  @$pb.TagNumber(2)
  set time($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get depth => $_getN(2);
  @$pb.TagNumber(3)
  set depth($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDepth() => $_has(2);
  @$pb.TagNumber(3)
  void clearDepth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get tts => $_getIZ(3);
  @$pb.TagNumber(4)
  set tts($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTts() => $_has(3);
  @$pb.TagNumber(4)
  void clearTts() => $_clearField(4);
}

/// An event that occurred during the dive.
class SampleEvent extends $pb.GeneratedMessage {
  factory SampleEvent({
    SampleEventType? type,
    $core.int? time,
    $core.int? flags,
    $core.int? value,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (time != null) result.time = time;
    if (flags != null) result.flags = flags;
    if (value != null) result.value = value;
    return result;
  }

  SampleEvent._();

  factory SampleEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SampleEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SampleEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aE<SampleEventType>(1, _omitFieldNames ? '' : 'type',
        enumValues: SampleEventType.values)
    ..aI(2, _omitFieldNames ? '' : 'time')
    ..aI(3, _omitFieldNames ? '' : 'flags', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SampleEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SampleEvent copyWith(void Function(SampleEvent) updates) =>
      super.copyWith((message) => updates(message as SampleEvent))
          as SampleEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SampleEvent create() => SampleEvent._();
  @$core.override
  SampleEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SampleEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SampleEvent>(create);
  static SampleEvent? _defaultInstance;

  @$pb.TagNumber(1)
  SampleEventType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SampleEventType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get time => $_getIZ(1);
  @$pb.TagNumber(2)
  set time($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get flags => $_getIZ(2);
  @$pb.TagNumber(3)
  set flags($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFlags() => $_has(2);
  @$pb.TagNumber(3)
  void clearFlags() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get value => $_getIZ(3);
  @$pb.TagNumber(4)
  set value($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearValue() => $_clearField(4);
}

/// Vendor-specific data.
class VendorData extends $pb.GeneratedMessage {
  factory VendorData({
    $core.int? type,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (data != null) result.data = data;
    return result;
  }

  VendorData._();

  factory VendorData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VendorData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VendorData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VendorData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VendorData copyWith(void Function(VendorData) updates) =>
      super.copyWith((message) => updates(message as VendorData)) as VendorData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VendorData create() => VendorData._();
  @$core.override
  VendorData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VendorData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VendorData>(create);
  static VendorData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
