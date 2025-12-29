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

import 'log.pb.dart' as $2;
import 'site.pb.dart' as $1;
import 'types.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class InternalCylinderList extends $pb.GeneratedMessage {
  factory InternalCylinderList({
    $core.Iterable<$0.Cylinder>? cylinders,
  }) {
    final result = create();
    if (cylinders != null) result.cylinders.addAll(cylinders);
    return result;
  }

  InternalCylinderList._();

  factory InternalCylinderList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InternalCylinderList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalCylinderList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..pPM<$0.Cylinder>(1, _omitFieldNames ? '' : 'cylinders',
        subBuilder: $0.Cylinder.create)
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
  static InternalCylinderList create() => InternalCylinderList._();
  @$core.override
  InternalCylinderList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InternalCylinderList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalCylinderList>(create);
  static InternalCylinderList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Cylinder> get cylinders => $_getList(0);
}

class InternalSiteList extends $pb.GeneratedMessage {
  factory InternalSiteList({
    $core.Iterable<$1.Site>? sites,
  }) {
    final result = create();
    if (sites != null) result.sites.addAll(sites);
    return result;
  }

  InternalSiteList._();

  factory InternalSiteList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InternalSiteList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalSiteList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..pPM<$1.Site>(1, _omitFieldNames ? '' : 'sites',
        subBuilder: $1.Site.create)
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
  static InternalSiteList create() => InternalSiteList._();
  @$core.override
  InternalSiteList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InternalSiteList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalSiteList>(create);
  static InternalSiteList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.Site> get sites => $_getList(0);
}

class InternalDiveLogList extends $pb.GeneratedMessage {
  factory InternalDiveLogList({
    $core.Iterable<$2.Log>? divelogs,
  }) {
    final result = create();
    if (divelogs != null) result.divelogs.addAll(divelogs);
    return result;
  }

  InternalDiveLogList._();

  factory InternalDiveLogList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InternalDiveLogList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalDiveLogList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..pPM<$2.Log>(1, _omitFieldNames ? '' : 'divelogs',
        subBuilder: $2.Log.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalDiveLogList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalDiveLogList copyWith(void Function(InternalDiveLogList) updates) =>
      super.copyWith((message) => updates(message as InternalDiveLogList))
          as InternalDiveLogList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InternalDiveLogList create() => InternalDiveLogList._();
  @$core.override
  InternalDiveLogList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InternalDiveLogList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalDiveLogList>(create);
  static InternalDiveLogList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$2.Log> get divelogs => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
