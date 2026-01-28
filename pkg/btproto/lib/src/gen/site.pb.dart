// This is a generated file - do not edit.
//
// Generated from site.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'types.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Dive site information.
class Site extends $pb.GeneratedMessage {
  factory Site({
    $core.String? id,
    $0.Metadata? meta,
    $core.String? name,
    $0.Position? position,
    $core.String? country,
    $core.String? location,
    $core.String? bodyOfWater,
    $core.String? difficulty,
    $core.Iterable<$core.String>? tags,
    $core.String? notes,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (meta != null) result.meta = meta;
    if (name != null) result.name = name;
    if (position != null) result.position = position;
    if (country != null) result.country = country;
    if (location != null) result.location = location;
    if (bodyOfWater != null) result.bodyOfWater = bodyOfWater;
    if (difficulty != null) result.difficulty = difficulty;
    if (tags != null) result.tags.addAll(tags);
    if (notes != null) result.notes = notes;
    return result;
  }

  Site._();

  factory Site.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Site.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Site',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'btstore'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$0.Metadata>(2, _omitFieldNames ? '' : 'meta',
        subBuilder: $0.Metadata.create)
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOM<$0.Position>(4, _omitFieldNames ? '' : 'position',
        subBuilder: $0.Position.create)
    ..aOS(5, _omitFieldNames ? '' : 'country')
    ..aOS(6, _omitFieldNames ? '' : 'location')
    ..aOS(7, _omitFieldNames ? '' : 'bodyOfWater')
    ..aOS(8, _omitFieldNames ? '' : 'difficulty')
    ..pPS(9, _omitFieldNames ? '' : 'tags')
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Site clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Site copyWith(void Function(Site) updates) =>
      super.copyWith((message) => updates(message as Site)) as Site;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Site create() => Site._();
  @$core.override
  Site createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Site getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Site>(create);
  static Site? _defaultInstance;

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
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Position get position => $_getN(3);
  @$pb.TagNumber(4)
  set position($0.Position value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPosition() => $_has(3);
  @$pb.TagNumber(4)
  void clearPosition() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Position ensurePosition() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get country => $_getSZ(4);
  @$pb.TagNumber(5)
  set country($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCountry() => $_has(4);
  @$pb.TagNumber(5)
  void clearCountry() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get location => $_getSZ(5);
  @$pb.TagNumber(6)
  set location($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLocation() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocation() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get bodyOfWater => $_getSZ(6);
  @$pb.TagNumber(7)
  set bodyOfWater($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBodyOfWater() => $_has(6);
  @$pb.TagNumber(7)
  void clearBodyOfWater() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get difficulty => $_getSZ(7);
  @$pb.TagNumber(8)
  set difficulty($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDifficulty() => $_has(7);
  @$pb.TagNumber(8)
  void clearDifficulty() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get tags => $_getList(8);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => $_clearField(10);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
