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
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Remembered BLE computer
class Computer extends $pb.GeneratedMessage {
  factory Computer({
    $core.String? remoteId,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $0.Timestamp? deletedAt,
    $core.String? advertisedName,
    $core.String? vendor,
    $core.String? product,
    $core.String? ldcFingerprint,
  }) {
    final result = create();
    if (remoteId != null) result.remoteId = remoteId;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    if (advertisedName != null) result.advertisedName = advertisedName;
    if (vendor != null) result.vendor = vendor;
    if (product != null) result.product = product;
    if (ldcFingerprint != null) result.ldcFingerprint = ldcFingerprint;
    return result;
  }

  Computer._();

  factory Computer.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Computer.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(_omitMessageNames ? '' : 'Computer', package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'), createEmptyInstance: create)
        ..aOS(1, _omitFieldNames ? '' : 'remoteId')
        ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.create)
        ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'updatedAt', subBuilder: $0.Timestamp.create)
        ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'deletedAt', subBuilder: $0.Timestamp.create)
        ..aOS(5, _omitFieldNames ? '' : 'advertisedName')
        ..aOS(6, _omitFieldNames ? '' : 'vendor')
        ..aOS(7, _omitFieldNames ? '' : 'product')
        ..aOS(8, _omitFieldNames ? '' : 'ldcFingerprint')
        ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Computer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Computer copyWith(void Function(Computer) updates) => super.copyWith((message) => updates(message as Computer)) as Computer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Computer create() => Computer._();
  @$core.override
  Computer createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Computer getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Computer>(create);
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
  $0.Timestamp get createdAt => $_getN(1);
  @$pb.TagNumber(2)
  set createdAt($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCreatedAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreatedAt() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureCreatedAt() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Timestamp get updatedAt => $_getN(2);
  @$pb.TagNumber(3)
  set updatedAt($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasUpdatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearUpdatedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureUpdatedAt() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Timestamp get deletedAt => $_getN(3);
  @$pb.TagNumber(4)
  set deletedAt($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDeletedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeletedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureDeletedAt() => $_ensure(3);

  /// Bluetooth LE advertised name as seen in a scan
  @$pb.TagNumber(5)
  $core.String get advertisedName => $_getSZ(4);
  @$pb.TagNumber(5)
  set advertisedName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAdvertisedName() => $_has(4);
  @$pb.TagNumber(5)
  void clearAdvertisedName() => $_clearField(5);

  /// Vendor as set on the selected libdivecomputer descriptor
  @$pb.TagNumber(6)
  $core.String get vendor => $_getSZ(5);
  @$pb.TagNumber(6)
  set vendor($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVendor() => $_has(5);
  @$pb.TagNumber(6)
  void clearVendor() => $_clearField(6);

  /// Product as set on the selected libdivecomputer descriptor
  @$pb.TagNumber(7)
  $core.String get product => $_getSZ(6);
  @$pb.TagNumber(7)
  set product($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasProduct() => $_has(6);
  @$pb.TagNumber(7)
  void clearProduct() => $_clearField(7);

  /// libdivecomputer fingerprint from last download
  @$pb.TagNumber(8)
  $core.String get ldcFingerprint => $_getSZ(7);
  @$pb.TagNumber(8)
  set ldcFingerprint($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLdcFingerprint() => $_has(7);
  @$pb.TagNumber(8)
  void clearLdcFingerprint() => $_clearField(8);
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
