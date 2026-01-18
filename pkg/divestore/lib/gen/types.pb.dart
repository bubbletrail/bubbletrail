// This is a generated file - do not edit.
//
// Generated from types.proto.

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

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// GPS position (latitude/longitude).
class Position extends $pb.GeneratedMessage {
  factory Position({
    $core.double? latitude,
    $core.double? longitude,
    $core.double? altitude,
  }) {
    final result = create();
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (altitude != null) result.altitude = altitude;
    return result;
  }

  Position._();

  factory Position.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Position.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Position',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'latitude')
    ..aD(2, _omitFieldNames ? '' : 'longitude')
    ..aD(3, _omitFieldNames ? '' : 'altitude')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Position clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Position copyWith(void Function(Position) updates) =>
      super.copyWith((message) => updates(message as Position)) as Position;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Position create() => Position._();
  @$core.override
  Position createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Position getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Position>(create);
  static Position? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get altitude => $_getN(2);
  @$pb.TagNumber(3)
  set altitude($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAltitude() => $_has(2);
  @$pb.TagNumber(3)
  void clearAltitude() => $_clearField(3);
}

class Metadata extends $pb.GeneratedMessage {
  factory Metadata({
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $0.Timestamp? deletedAt,
  }) {
    final result = create();
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  Metadata._();

  factory Metadata.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Metadata.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Metadata',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'deletedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Metadata clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Metadata copyWith(void Function(Metadata) updates) =>
      super.copyWith((message) => updates(message as Metadata)) as Metadata;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Metadata create() => Metadata._();
  @$core.override
  Metadata createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Metadata getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Metadata>(create);
  static Metadata? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get createdAt => $_getN(0);
  @$pb.TagNumber(1)
  set createdAt($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCreatedAt() => $_has(0);
  @$pb.TagNumber(1)
  void clearCreatedAt() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureCreatedAt() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Timestamp get updatedAt => $_getN(1);
  @$pb.TagNumber(2)
  set updatedAt($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUpdatedAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdatedAt() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureUpdatedAt() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Timestamp get deletedAt => $_getN(2);
  @$pb.TagNumber(3)
  set deletedAt($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDeletedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeletedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureDeletedAt() => $_ensure(2);
}

/// Buhlmann ZHL-16c tissue compartment state.
/// Stores the inert gas partial pressures in each of the 16 tissue compartments.
class Tissues extends $pb.GeneratedMessage {
  factory Tissues({
    $core.Iterable<$core.double>? n2Pressures,
    $core.Iterable<$core.double>? hePressures,
    $0.Timestamp? timestamp,
    $core.String? chainId,
  }) {
    final result = create();
    if (n2Pressures != null) result.n2Pressures.addAll(n2Pressures);
    if (hePressures != null) result.hePressures.addAll(hePressures);
    if (timestamp != null) result.timestamp = timestamp;
    if (chainId != null) result.chainId = chainId;
    return result;
  }

  Tissues._();

  factory Tissues.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Tissues.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tissues',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..p<$core.double>(
        1, _omitFieldNames ? '' : 'n2Pressures', $pb.PbFieldType.KD)
    ..p<$core.double>(
        2, _omitFieldNames ? '' : 'hePressures', $pb.PbFieldType.KD)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(4, _omitFieldNames ? '' : 'chainId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tissues clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tissues copyWith(void Function(Tissues) updates) =>
      super.copyWith((message) => updates(message as Tissues)) as Tissues;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tissues create() => Tissues._();
  @$core.override
  Tissues createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Tissues getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tissues>(create);
  static Tissues? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.double> get n2Pressures => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.double> get hePressures => $_getList(1);

  @$pb.TagNumber(3)
  $0.Timestamp get timestamp => $_getN(2);
  @$pb.TagNumber(3)
  set timestamp($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureTimestamp() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get chainId => $_getSZ(3);
  @$pb.TagNumber(4)
  set chainId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChainId() => $_has(3);
  @$pb.TagNumber(4)
  void clearChainId() => $_clearField(4);
}

/// Cylinder/tank definition.
/// Metric fields (size, workpressure) are always populated for calculations.
/// Imperial fields (size_cuft, workpressure_psi) are optionally stored when
/// the user enters values in imperial units, to avoid rounding errors on display.
class Cylinder extends $pb.GeneratedMessage {
  factory Cylinder({
    $core.String? id,
    Metadata? meta,
    $core.double? volumeL,
    $core.double? workingPressureBar,
    $core.String? description,
    $core.double? volumeCuft,
    $core.double? workingPressurePsi,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (meta != null) result.meta = meta;
    if (volumeL != null) result.volumeL = volumeL;
    if (workingPressureBar != null)
      result.workingPressureBar = workingPressureBar;
    if (description != null) result.description = description;
    if (volumeCuft != null) result.volumeCuft = volumeCuft;
    if (workingPressurePsi != null)
      result.workingPressurePsi = workingPressurePsi;
    return result;
  }

  Cylinder._();

  factory Cylinder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Cylinder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Cylinder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Metadata>(2, _omitFieldNames ? '' : 'meta',
        subBuilder: Metadata.create)
    ..aD(3, _omitFieldNames ? '' : 'volumeL')
    ..aD(4, _omitFieldNames ? '' : 'workingPressureBar')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aD(6, _omitFieldNames ? '' : 'volumeCuft')
    ..aD(7, _omitFieldNames ? '' : 'workingPressurePsi')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cylinder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cylinder copyWith(void Function(Cylinder) updates) =>
      super.copyWith((message) => updates(message as Cylinder)) as Cylinder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Cylinder create() => Cylinder._();
  @$core.override
  Cylinder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Cylinder getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Cylinder>(create);
  static Cylinder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  Metadata get meta => $_getN(1);
  @$pb.TagNumber(2)
  set meta(Metadata value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMeta() => $_has(1);
  @$pb.TagNumber(2)
  void clearMeta() => $_clearField(2);
  @$pb.TagNumber(2)
  Metadata ensureMeta() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.double get volumeL => $_getN(2);
  @$pb.TagNumber(3)
  set volumeL($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVolumeL() => $_has(2);
  @$pb.TagNumber(3)
  void clearVolumeL() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get workingPressureBar => $_getN(3);
  @$pb.TagNumber(4)
  set workingPressureBar($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWorkingPressureBar() => $_has(3);
  @$pb.TagNumber(4)
  void clearWorkingPressureBar() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  /// Imperial values (set when entered in imperial units for exact round-trip)
  @$pb.TagNumber(6)
  $core.double get volumeCuft => $_getN(5);
  @$pb.TagNumber(6)
  set volumeCuft($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVolumeCuft() => $_has(5);
  @$pb.TagNumber(6)
  void clearVolumeCuft() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get workingPressurePsi => $_getN(6);
  @$pb.TagNumber(7)
  set workingPressurePsi($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasWorkingPressurePsi() => $_has(6);
  @$pb.TagNumber(7)
  void clearWorkingPressurePsi() => $_clearField(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
