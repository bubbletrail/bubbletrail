// This is a generated file - do not edit.
//
// Generated from internal.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'computer.pb.dart' as $3;
import 'equipment.pb.dart' as $4;
import 'log.pb.dart' as $2;
import 'site.pb.dart' as $1;
import 'types.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class InternalCylinderList extends $pb.GeneratedMessage {
  factory InternalCylinderList({
    $core.Iterable<$0.Cylinder>? cylinders,
  }) {
    final result = InternalCylinderList._();
    if (cylinders != null) result.cylinders.addAll(cylinders);
    return result;
  }

  InternalCylinderList._();

  factory InternalCylinderList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalCylinderList()..mergeFromBuffer(data, registry);
  factory InternalCylinderList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalCylinderList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalCylinderList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'btstore'),
      createEmptyInstance: InternalCylinderList.$_createMessage)
    ..pPM<$0.Cylinder>(1, _omitFieldNames ? '' : 'cylinders',
        subBuilder: $0.Cylinder.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalCylinderList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalCylinderList copyWith(void Function(InternalCylinderList) updates) =>
      super.copyWith((message) => updates(message as InternalCylinderList))
          as InternalCylinderList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InternalCylinderList() / InternalCylinderList.new instead')
  static InternalCylinderList create() => InternalCylinderList._();
  static $pb.GeneratedMessage $_createMessage() => InternalCylinderList._();
  @$core.override
  InternalCylinderList createEmptyInstance() => InternalCylinderList._();
  @$core.pragma('dart2js:noInline')
  static InternalCylinderList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalCylinderList>(
          InternalCylinderList.$_createMessage);
  static InternalCylinderList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Cylinder> get cylinders => $_getList(0);
}

class InternalSiteList extends $pb.GeneratedMessage {
  factory InternalSiteList({
    $core.Iterable<$1.Site>? sites,
  }) {
    final result = InternalSiteList._();
    if (sites != null) result.sites.addAll(sites);
    return result;
  }

  InternalSiteList._();

  factory InternalSiteList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalSiteList()..mergeFromBuffer(data, registry);
  factory InternalSiteList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalSiteList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalSiteList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'btstore'),
      createEmptyInstance: InternalSiteList.$_createMessage)
    ..pPM<$1.Site>(1, _omitFieldNames ? '' : 'sites',
        subBuilder: $1.Site.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalSiteList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalSiteList copyWith(void Function(InternalSiteList) updates) =>
      super.copyWith((message) => updates(message as InternalSiteList))
          as InternalSiteList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InternalSiteList() / InternalSiteList.new instead')
  static InternalSiteList create() => InternalSiteList._();
  static $pb.GeneratedMessage $_createMessage() => InternalSiteList._();
  @$core.override
  InternalSiteList createEmptyInstance() => InternalSiteList._();
  @$core.pragma('dart2js:noInline')
  static InternalSiteList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InternalSiteList>(
          InternalSiteList.$_createMessage);
  static InternalSiteList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.Site> get sites => $_getList(0);
}

class InternalLogList extends $pb.GeneratedMessage {
  factory InternalLogList({
    $core.Iterable<$2.Log>? logs,
  }) {
    final result = InternalLogList._();
    if (logs != null) result.logs.addAll(logs);
    return result;
  }

  InternalLogList._();

  factory InternalLogList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalLogList()..mergeFromBuffer(data, registry);
  factory InternalLogList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalLogList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalLogList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'btstore'),
      createEmptyInstance: InternalLogList.$_createMessage)
    ..pPM<$2.Log>(1, _omitFieldNames ? '' : 'logs',
        subBuilder: $2.Log.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalLogList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalLogList copyWith(void Function(InternalLogList) updates) =>
      super.copyWith((message) => updates(message as InternalLogList))
          as InternalLogList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InternalLogList() / InternalLogList.new instead')
  static InternalLogList create() => InternalLogList._();
  static $pb.GeneratedMessage $_createMessage() => InternalLogList._();
  @$core.override
  InternalLogList createEmptyInstance() => InternalLogList._();
  @$core.pragma('dart2js:noInline')
  static InternalLogList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InternalLogList>(
          InternalLogList.$_createMessage);
  static InternalLogList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$2.Log> get logs => $_getList(0);
}

class InternalComputerList extends $pb.GeneratedMessage {
  factory InternalComputerList({
    $core.Iterable<$3.Computer>? computers,
  }) {
    final result = InternalComputerList._();
    if (computers != null) result.computers.addAll(computers);
    return result;
  }

  InternalComputerList._();

  factory InternalComputerList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalComputerList()..mergeFromBuffer(data, registry);
  factory InternalComputerList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalComputerList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalComputerList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'btstore'),
      createEmptyInstance: InternalComputerList.$_createMessage)
    ..pPM<$3.Computer>(1, _omitFieldNames ? '' : 'computers',
        subBuilder: $3.Computer.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalComputerList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalComputerList copyWith(void Function(InternalComputerList) updates) =>
      super.copyWith((message) => updates(message as InternalComputerList))
          as InternalComputerList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InternalComputerList() / InternalComputerList.new instead')
  static InternalComputerList create() => InternalComputerList._();
  static $pb.GeneratedMessage $_createMessage() => InternalComputerList._();
  @$core.override
  InternalComputerList createEmptyInstance() => InternalComputerList._();
  @$core.pragma('dart2js:noInline')
  static InternalComputerList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalComputerList>(
          InternalComputerList.$_createMessage);
  static InternalComputerList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$3.Computer> get computers => $_getList(0);
}

class InternalEquipmentList extends $pb.GeneratedMessage {
  factory InternalEquipmentList({
    $core.Iterable<$4.Equipment>? equipments,
  }) {
    final result = InternalEquipmentList._();
    if (equipments != null) result.equipments.addAll(equipments);
    return result;
  }

  InternalEquipmentList._();

  factory InternalEquipmentList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalEquipmentList()..mergeFromBuffer(data, registry);
  factory InternalEquipmentList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalEquipmentList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalEquipmentList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'btstore'),
      createEmptyInstance: InternalEquipmentList.$_createMessage)
    ..pPM<$4.Equipment>(1, _omitFieldNames ? '' : 'equipments',
        subBuilder: $4.Equipment.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalEquipmentList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalEquipmentList copyWith(
          void Function(InternalEquipmentList) updates) =>
      super.copyWith((message) => updates(message as InternalEquipmentList))
          as InternalEquipmentList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InternalEquipmentList() / InternalEquipmentList.new instead')
  static InternalEquipmentList create() => InternalEquipmentList._();
  static $pb.GeneratedMessage $_createMessage() => InternalEquipmentList._();
  @$core.override
  InternalEquipmentList createEmptyInstance() => InternalEquipmentList._();
  @$core.pragma('dart2js:noInline')
  static InternalEquipmentList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalEquipmentList>(
          InternalEquipmentList.$_createMessage);
  static InternalEquipmentList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$4.Equipment> get equipments => $_getList(0);
}

class InternalCertificationList extends $pb.GeneratedMessage {
  factory InternalCertificationList({
    $core.Iterable<$0.Certification>? certifications,
  }) {
    final result = InternalCertificationList._();
    if (certifications != null) result.certifications.addAll(certifications);
    return result;
  }

  InternalCertificationList._();

  factory InternalCertificationList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalCertificationList()..mergeFromBuffer(data, registry);
  factory InternalCertificationList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalCertificationList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalCertificationList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'btstore'),
      createEmptyInstance: InternalCertificationList.$_createMessage)
    ..pPM<$0.Certification>(1, _omitFieldNames ? '' : 'certifications',
        subBuilder: $0.Certification.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalCertificationList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalCertificationList copyWith(
          void Function(InternalCertificationList) updates) =>
      super.copyWith((message) => updates(message as InternalCertificationList))
          as InternalCertificationList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use InternalCertificationList() / InternalCertificationList.new instead')
  static InternalCertificationList create() => InternalCertificationList._();
  static $pb.GeneratedMessage $_createMessage() =>
      InternalCertificationList._();
  @$core.override
  InternalCertificationList createEmptyInstance() =>
      InternalCertificationList._();
  @$core.pragma('dart2js:noInline')
  static InternalCertificationList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalCertificationList>(
          InternalCertificationList.$_createMessage);
  static InternalCertificationList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Certification> get certifications => $_getList(0);
}

class InternalPhotoList extends $pb.GeneratedMessage {
  factory InternalPhotoList({
    $core.Iterable<$0.Photo>? photos,
  }) {
    final result = InternalPhotoList._();
    if (photos != null) result.photos.addAll(photos);
    return result;
  }

  InternalPhotoList._();

  factory InternalPhotoList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalPhotoList()..mergeFromBuffer(data, registry);
  factory InternalPhotoList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InternalPhotoList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalPhotoList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'btstore'),
      createEmptyInstance: InternalPhotoList.$_createMessage)
    ..pPM<$0.Photo>(1, _omitFieldNames ? '' : 'photos',
        subBuilder: $0.Photo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalPhotoList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalPhotoList copyWith(void Function(InternalPhotoList) updates) =>
      super.copyWith((message) => updates(message as InternalPhotoList))
          as InternalPhotoList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InternalPhotoList() / InternalPhotoList.new instead')
  static InternalPhotoList create() => InternalPhotoList._();
  static $pb.GeneratedMessage $_createMessage() => InternalPhotoList._();
  @$core.override
  InternalPhotoList createEmptyInstance() => InternalPhotoList._();
  @$core.pragma('dart2js:noInline')
  static InternalPhotoList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InternalPhotoList>(
          InternalPhotoList.$_createMessage);
  static InternalPhotoList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Photo> get photos => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
