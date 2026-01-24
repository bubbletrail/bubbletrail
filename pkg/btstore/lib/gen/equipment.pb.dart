// This is a generated file - do not edit.
//
// Generated from equipment.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $1;

import 'types.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Equipment extends $pb.GeneratedMessage {
  factory Equipment({
    $core.String? id,
    $0.Metadata? meta,
    $core.String? type,
    $core.String? manufacturer,
    $core.String? name,
    $core.String? serial,
    $1.Timestamp? purchaseDate,
    $core.double? purchasePrice,
    $core.double? weight,
    $1.Timestamp? nextService,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (meta != null) result.meta = meta;
    if (type != null) result.type = type;
    if (manufacturer != null) result.manufacturer = manufacturer;
    if (name != null) result.name = name;
    if (serial != null) result.serial = serial;
    if (purchaseDate != null) result.purchaseDate = purchaseDate;
    if (purchasePrice != null) result.purchasePrice = purchasePrice;
    if (weight != null) result.weight = weight;
    if (nextService != null) result.nextService = nextService;
    return result;
  }

  Equipment._();

  factory Equipment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Equipment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Equipment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'btstore'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$0.Metadata>(2, _omitFieldNames ? '' : 'meta',
        subBuilder: $0.Metadata.create)
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..aOS(4, _omitFieldNames ? '' : 'manufacturer')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'serial')
    ..aOM<$1.Timestamp>(7, _omitFieldNames ? '' : 'purchaseDate',
        subBuilder: $1.Timestamp.create)
    ..aD(8, _omitFieldNames ? '' : 'purchasePrice')
    ..aD(9, _omitFieldNames ? '' : 'weight')
    ..aOM<$1.Timestamp>(10, _omitFieldNames ? '' : 'nextService',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Equipment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Equipment copyWith(void Function(Equipment) updates) =>
      super.copyWith((message) => updates(message as Equipment)) as Equipment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Equipment create() => Equipment._();
  @$core.override
  Equipment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Equipment getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Equipment>(create);
  static Equipment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Metadata get meta => $_getN(1);
  @$pb.TagNumber(2)
  set meta($0.Metadata value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMeta() => $_has(1);
  @$pb.TagNumber(2)
  void clearMeta() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Metadata ensureMeta() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get manufacturer => $_getSZ(3);
  @$pb.TagNumber(4)
  set manufacturer($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasManufacturer() => $_has(3);
  @$pb.TagNumber(4)
  void clearManufacturer() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get serial => $_getSZ(5);
  @$pb.TagNumber(6)
  set serial($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSerial() => $_has(5);
  @$pb.TagNumber(6)
  void clearSerial() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.Timestamp get purchaseDate => $_getN(6);
  @$pb.TagNumber(7)
  set purchaseDate($1.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasPurchaseDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearPurchaseDate() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Timestamp ensurePurchaseDate() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.double get purchasePrice => $_getN(7);
  @$pb.TagNumber(8)
  set purchasePrice($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPurchasePrice() => $_has(7);
  @$pb.TagNumber(8)
  void clearPurchasePrice() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get weight => $_getN(8);
  @$pb.TagNumber(9)
  set weight($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWeight() => $_has(8);
  @$pb.TagNumber(9)
  void clearWeight() => $_clearField(9);

  @$pb.TagNumber(10)
  $1.Timestamp get nextService => $_getN(9);
  @$pb.TagNumber(10)
  set nextService($1.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasNextService() => $_has(9);
  @$pb.TagNumber(10)
  void clearNextService() => $_clearField(10);
  @$pb.TagNumber(10)
  $1.Timestamp ensureNextService() => $_ensure(9);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
