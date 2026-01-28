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
    $core.double? weight,
    $1.Timestamp? lastService,
    $1.Timestamp? purchaseDate,
    $core.double? purchasePrice,
    $core.String? shop,
    $1.Timestamp? warrantyUntil,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (meta != null) result.meta = meta;
    if (type != null) result.type = type;
    if (manufacturer != null) result.manufacturer = manufacturer;
    if (name != null) result.name = name;
    if (serial != null) result.serial = serial;
    if (weight != null) result.weight = weight;
    if (lastService != null) result.lastService = lastService;
    if (purchaseDate != null) result.purchaseDate = purchaseDate;
    if (purchasePrice != null) result.purchasePrice = purchasePrice;
    if (shop != null) result.shop = shop;
    if (warrantyUntil != null) result.warrantyUntil = warrantyUntil;
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
    ..aD(7, _omitFieldNames ? '' : 'weight')
    ..aOM<$1.Timestamp>(8, _omitFieldNames ? '' : 'lastService',
        subBuilder: $1.Timestamp.create)
    ..aOM<$1.Timestamp>(9, _omitFieldNames ? '' : 'purchaseDate',
        subBuilder: $1.Timestamp.create)
    ..aD(10, _omitFieldNames ? '' : 'purchasePrice')
    ..aOS(11, _omitFieldNames ? '' : 'shop')
    ..aOM<$1.Timestamp>(12, _omitFieldNames ? '' : 'warrantyUntil',
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
  $core.double get weight => $_getN(6);
  @$pb.TagNumber(7)
  set weight($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasWeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearWeight() => $_clearField(7);

  @$pb.TagNumber(8)
  $1.Timestamp get lastService => $_getN(7);
  @$pb.TagNumber(8)
  set lastService($1.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasLastService() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastService() => $_clearField(8);
  @$pb.TagNumber(8)
  $1.Timestamp ensureLastService() => $_ensure(7);

  @$pb.TagNumber(9)
  $1.Timestamp get purchaseDate => $_getN(8);
  @$pb.TagNumber(9)
  set purchaseDate($1.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPurchaseDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearPurchaseDate() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.Timestamp ensurePurchaseDate() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.double get purchasePrice => $_getN(9);
  @$pb.TagNumber(10)
  set purchasePrice($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPurchasePrice() => $_has(9);
  @$pb.TagNumber(10)
  void clearPurchasePrice() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get shop => $_getSZ(10);
  @$pb.TagNumber(11)
  set shop($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasShop() => $_has(10);
  @$pb.TagNumber(11)
  void clearShop() => $_clearField(11);

  @$pb.TagNumber(12)
  $1.Timestamp get warrantyUntil => $_getN(11);
  @$pb.TagNumber(12)
  set warrantyUntil($1.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasWarrantyUntil() => $_has(11);
  @$pb.TagNumber(12)
  void clearWarrantyUntil() => $_clearField(12);
  @$pb.TagNumber(12)
  $1.Timestamp ensureWarrantyUntil() => $_ensure(11);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
