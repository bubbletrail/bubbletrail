// This is a generated file - do not edit.
//
// Generated from computer.proto.

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

/// Remembered BLE computer
class Computer extends $pb.GeneratedMessage {
  factory Computer({
    $core.String? remoteId,
    $0.Metadata? meta,
    $core.String? advertisedName,
    $core.String? vendor,
    $core.String? product,
    $core.String? serial,
    $core.List<$core.int>? ldcFingerprint,
    $1.Timestamp? lastLogDate,
  }) {
    final result = create();
    if (remoteId != null) result.remoteId = remoteId;
    if (meta != null) result.meta = meta;
    if (advertisedName != null) result.advertisedName = advertisedName;
    if (vendor != null) result.vendor = vendor;
    if (product != null) result.product = product;
    if (serial != null) result.serial = serial;
    if (ldcFingerprint != null) result.ldcFingerprint = ldcFingerprint;
    if (lastLogDate != null) result.lastLogDate = lastLogDate;
    return result;
  }

  Computer._();

  factory Computer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Computer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Computer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'remoteId')
    ..aOM<$0.Metadata>(2, _omitFieldNames ? '' : 'meta',
        subBuilder: $0.Metadata.create)
    ..aOS(3, _omitFieldNames ? '' : 'advertisedName')
    ..aOS(4, _omitFieldNames ? '' : 'vendor')
    ..aOS(5, _omitFieldNames ? '' : 'product')
    ..aOS(6, _omitFieldNames ? '' : 'serial')
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'ldcFingerprint', $pb.PbFieldType.OY)
    ..aOM<$1.Timestamp>(8, _omitFieldNames ? '' : 'lastLogDate',
        subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Computer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Computer copyWith(void Function(Computer) updates) =>
      super.copyWith((message) => updates(message as Computer)) as Computer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Computer create() => Computer._();
  @$core.override
  Computer createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Computer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Computer>(create);
  static Computer? _defaultInstance;

  /// Bluetooth LE remote ID as seen in a scan
  @$pb.TagNumber(1)
  $core.String get remoteId => $_getSZ(0);
  @$pb.TagNumber(1)
  set remoteId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRemoteId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRemoteId() => $_clearField(1);

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

  /// Bluetooth LE advertised name as seen in a scan
  @$pb.TagNumber(3)
  $core.String get advertisedName => $_getSZ(2);
  @$pb.TagNumber(3)
  set advertisedName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAdvertisedName() => $_has(2);
  @$pb.TagNumber(3)
  void clearAdvertisedName() => $_clearField(3);

  /// Vendor as set on the selected libdivecomputer descriptor
  @$pb.TagNumber(4)
  $core.String get vendor => $_getSZ(3);
  @$pb.TagNumber(4)
  set vendor($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVendor() => $_has(3);
  @$pb.TagNumber(4)
  void clearVendor() => $_clearField(4);

  /// Product as set on the selected libdivecomputer descriptor
  @$pb.TagNumber(5)
  $core.String get product => $_getSZ(4);
  @$pb.TagNumber(5)
  set product($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProduct() => $_has(4);
  @$pb.TagNumber(5)
  void clearProduct() => $_clearField(5);

  /// Serial number as reported by device info
  @$pb.TagNumber(6)
  $core.String get serial => $_getSZ(5);
  @$pb.TagNumber(6)
  set serial($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSerial() => $_has(5);
  @$pb.TagNumber(6)
  void clearSerial() => $_clearField(6);

  /// libdivecomputer fingerprint from last download
  @$pb.TagNumber(7)
  $core.List<$core.int> get ldcFingerprint => $_getN(6);
  @$pb.TagNumber(7)
  set ldcFingerprint($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLdcFingerprint() => $_has(6);
  @$pb.TagNumber(7)
  void clearLdcFingerprint() => $_clearField(7);

  /// The latest log date we saw from this computer
  @$pb.TagNumber(8)
  $1.Timestamp get lastLogDate => $_getN(7);
  @$pb.TagNumber(8)
  set lastLogDate($1.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasLastLogDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastLogDate() => $_clearField(8);
  @$pb.TagNumber(8)
  $1.Timestamp ensureLastLogDate() => $_ensure(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
