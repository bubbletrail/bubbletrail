// This is a generated file - do not edit.
//
// Generated from dive.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $0;

import 'log.pb.dart' as $1;
import 'types.pb.dart' as $2;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// A single dive log entry.
class Dive extends $pb.GeneratedMessage {
  factory Dive({
    $core.String? id,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $0.Timestamp? deletedAt,
    $core.int? number,
    $core.int? rating,
    $core.Iterable<$core.String>? tags,
    $0.Timestamp? start,
    $core.int? duration,
    $core.double? maxDepth,
    $core.double? meanDepth,
    $core.double? sac,
    $core.int? otu,
    $core.int? cns,
    $core.String? siteId,
    $core.String? instructor,
    $core.String? divemaster,
    $core.Iterable<$core.String>? buddies,
    $core.String? notes,
    $core.Iterable<DiveCylinder>? cylinders,
    $core.Iterable<Weightsystem>? weightsystems,
    $core.Iterable<$1.Log>? logs,
    $core.Iterable<$1.SampleEvent>? events,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    if (number != null) result.number = number;
    if (rating != null) result.rating = rating;
    if (tags != null) result.tags.addAll(tags);
    if (start != null) result.start = start;
    if (duration != null) result.duration = duration;
    if (maxDepth != null) result.maxDepth = maxDepth;
    if (meanDepth != null) result.meanDepth = meanDepth;
    if (sac != null) result.sac = sac;
    if (otu != null) result.otu = otu;
    if (cns != null) result.cns = cns;
    if (siteId != null) result.siteId = siteId;
    if (instructor != null) result.instructor = instructor;
    if (divemaster != null) result.divemaster = divemaster;
    if (buddies != null) result.buddies.addAll(buddies);
    if (notes != null) result.notes = notes;
    if (cylinders != null) result.cylinders.addAll(cylinders);
    if (weightsystems != null) result.weightsystems.addAll(weightsystems);
    if (logs != null) result.logs.addAll(logs);
    if (events != null) result.events.addAll(events);
    return result;
  }

  Dive._();

  factory Dive.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Dive.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo(_omitMessageNames ? '' : 'Dive', package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'), createEmptyInstance: create)
        ..aOS(1, _omitFieldNames ? '' : 'id')
        ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.create)
        ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'updatedAt', subBuilder: $0.Timestamp.create)
        ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'deletedAt', subBuilder: $0.Timestamp.create)
        ..aI(8, _omitFieldNames ? '' : 'number')
        ..aI(9, _omitFieldNames ? '' : 'rating')
        ..pPS(10, _omitFieldNames ? '' : 'tags')
        ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'start', subBuilder: $0.Timestamp.create)
        ..aI(12, _omitFieldNames ? '' : 'duration')
        ..aD(13, _omitFieldNames ? '' : 'maxDepth')
        ..aD(14, _omitFieldNames ? '' : 'meanDepth')
        ..aD(15, _omitFieldNames ? '' : 'sac')
        ..aI(16, _omitFieldNames ? '' : 'otu')
        ..aI(17, _omitFieldNames ? '' : 'cns')
        ..aOS(18, _omitFieldNames ? '' : 'siteId')
        ..aOS(19, _omitFieldNames ? '' : 'instructor')
        ..aOS(20, _omitFieldNames ? '' : 'divemaster')
        ..pPS(21, _omitFieldNames ? '' : 'buddies')
        ..aOS(22, _omitFieldNames ? '' : 'notes')
        ..pPM<DiveCylinder>(23, _omitFieldNames ? '' : 'cylinders', subBuilder: DiveCylinder.create)
        ..pPM<Weightsystem>(24, _omitFieldNames ? '' : 'weightsystems', subBuilder: Weightsystem.create)
        ..pPM<$1.Log>(25, _omitFieldNames ? '' : 'logs', subBuilder: $1.Log.create)
        ..pPM<$1.SampleEvent>(26, _omitFieldNames ? '' : 'events', subBuilder: $1.SampleEvent.create)
        ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Dive clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Dive copyWith(void Function(Dive) updates) => super.copyWith((message) => updates(message as Dive)) as Dive;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Dive create() => Dive._();
  @$core.override
  Dive createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Dive getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Dive>(create);
  static Dive? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

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

  @$pb.TagNumber(8)
  $core.int get number => $_getIZ(4);
  @$pb.TagNumber(8)
  set number($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(8)
  $core.bool hasNumber() => $_has(4);
  @$pb.TagNumber(8)
  void clearNumber() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get rating => $_getIZ(5);
  @$pb.TagNumber(9)
  set rating($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(9)
  $core.bool hasRating() => $_has(5);
  @$pb.TagNumber(9)
  void clearRating() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get tags => $_getList(6);

  @$pb.TagNumber(11)
  $0.Timestamp get start => $_getN(7);
  @$pb.TagNumber(11)
  set start($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasStart() => $_has(7);
  @$pb.TagNumber(11)
  void clearStart() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureStart() => $_ensure(7);

  /// Summary data (populated from dive computer data, but editable by the user)
  @$pb.TagNumber(12)
  $core.int get duration => $_getIZ(8);
  @$pb.TagNumber(12)
  set duration($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(12)
  $core.bool hasDuration() => $_has(8);
  @$pb.TagNumber(12)
  void clearDuration() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get maxDepth => $_getN(9);
  @$pb.TagNumber(13)
  set maxDepth($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(13)
  $core.bool hasMaxDepth() => $_has(9);
  @$pb.TagNumber(13)
  void clearMaxDepth() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get meanDepth => $_getN(10);
  @$pb.TagNumber(14)
  set meanDepth($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(14)
  $core.bool hasMeanDepth() => $_has(10);
  @$pb.TagNumber(14)
  void clearMeanDepth() => $_clearField(14);

  /// Additional attributes
  @$pb.TagNumber(15)
  $core.double get sac => $_getN(11);
  @$pb.TagNumber(15)
  set sac($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(15)
  $core.bool hasSac() => $_has(11);
  @$pb.TagNumber(15)
  void clearSac() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get otu => $_getIZ(12);
  @$pb.TagNumber(16)
  set otu($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(16)
  $core.bool hasOtu() => $_has(12);
  @$pb.TagNumber(16)
  void clearOtu() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get cns => $_getIZ(13);
  @$pb.TagNumber(17)
  set cns($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(17)
  $core.bool hasCns() => $_has(13);
  @$pb.TagNumber(17)
  void clearCns() => $_clearField(17);

  /// Link to dive site
  @$pb.TagNumber(18)
  $core.String get siteId => $_getSZ(14);
  @$pb.TagNumber(18)
  set siteId($core.String value) => $_setString(14, value);
  @$pb.TagNumber(18)
  $core.bool hasSiteId() => $_has(14);
  @$pb.TagNumber(18)
  void clearSiteId() => $_clearField(18);

  /// Child elements
  @$pb.TagNumber(19)
  $core.String get instructor => $_getSZ(15);
  @$pb.TagNumber(19)
  set instructor($core.String value) => $_setString(15, value);
  @$pb.TagNumber(19)
  $core.bool hasInstructor() => $_has(15);
  @$pb.TagNumber(19)
  void clearInstructor() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get divemaster => $_getSZ(16);
  @$pb.TagNumber(20)
  set divemaster($core.String value) => $_setString(16, value);
  @$pb.TagNumber(20)
  $core.bool hasDivemaster() => $_has(16);
  @$pb.TagNumber(20)
  void clearDivemaster() => $_clearField(20);

  @$pb.TagNumber(21)
  $pb.PbList<$core.String> get buddies => $_getList(17);

  @$pb.TagNumber(22)
  $core.String get notes => $_getSZ(18);
  @$pb.TagNumber(22)
  set notes($core.String value) => $_setString(18, value);
  @$pb.TagNumber(22)
  $core.bool hasNotes() => $_has(18);
  @$pb.TagNumber(22)
  void clearNotes() => $_clearField(22);

  @$pb.TagNumber(23)
  $pb.PbList<DiveCylinder> get cylinders => $_getList(19);

  @$pb.TagNumber(24)
  $pb.PbList<Weightsystem> get weightsystems => $_getList(20);

  /// Raw dive computer data
  @$pb.TagNumber(25)
  $pb.PbList<$1.Log> get logs => $_getList(21);

  /// Events like gas changed, initially extracted from dive computer data
  /// but editable.
  @$pb.TagNumber(26)
  $pb.PbList<$1.SampleEvent> get events => $_getList(22);
}

/// Per-dive cylinder usage information.
class DiveCylinder extends $pb.GeneratedMessage {
  factory DiveCylinder({
    $core.String? cylinderId,
    $core.double? beginPressure,
    $core.double? endPressure,
    $core.double? oxygen,
    $core.double? helium,
    $2.Cylinder? cylinder,
  }) {
    final result = create();
    if (cylinderId != null) result.cylinderId = cylinderId;
    if (beginPressure != null) result.beginPressure = beginPressure;
    if (endPressure != null) result.endPressure = endPressure;
    if (oxygen != null) result.oxygen = oxygen;
    if (helium != null) result.helium = helium;
    if (cylinder != null) result.cylinder = cylinder;
    return result;
  }

  DiveCylinder._();

  factory DiveCylinder.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiveCylinder.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DiveCylinder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cylinderId')
    ..aD(2, _omitFieldNames ? '' : 'beginPressure')
    ..aD(3, _omitFieldNames ? '' : 'endPressure')
    ..aD(4, _omitFieldNames ? '' : 'oxygen')
    ..aD(5, _omitFieldNames ? '' : 'helium')
    ..aOM<$2.Cylinder>(32, _omitFieldNames ? '' : 'cylinder', subBuilder: $2.Cylinder.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiveCylinder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiveCylinder copyWith(void Function(DiveCylinder) updates) => super.copyWith((message) => updates(message as DiveCylinder)) as DiveCylinder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiveCylinder create() => DiveCylinder._();
  @$core.override
  DiveCylinder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiveCylinder getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DiveCylinder>(create);
  static DiveCylinder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cylinderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cylinderId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCylinderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCylinderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get beginPressure => $_getN(1);
  @$pb.TagNumber(2)
  set beginPressure($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBeginPressure() => $_has(1);
  @$pb.TagNumber(2)
  void clearBeginPressure() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get endPressure => $_getN(2);
  @$pb.TagNumber(3)
  set endPressure($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEndPressure() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndPressure() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get oxygen => $_getN(3);
  @$pb.TagNumber(4)
  set oxygen($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOxygen() => $_has(3);
  @$pb.TagNumber(4)
  void clearOxygen() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get helium => $_getN(4);
  @$pb.TagNumber(5)
  set helium($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHelium() => $_has(4);
  @$pb.TagNumber(5)
  void clearHelium() => $_clearField(5);

  /// Set temporarily when importing SSRF only
  @$pb.TagNumber(32)
  $2.Cylinder get cylinder => $_getN(5);
  @$pb.TagNumber(32)
  set cylinder($2.Cylinder value) => $_setField(32, value);
  @$pb.TagNumber(32)
  $core.bool hasCylinder() => $_has(5);
  @$pb.TagNumber(32)
  void clearCylinder() => $_clearField(32);
  @$pb.TagNumber(32)
  $2.Cylinder ensureCylinder() => $_ensure(5);
}

/// Weight system information.
class Weightsystem extends $pb.GeneratedMessage {
  factory Weightsystem({
    $core.double? weight,
    $core.String? description,
  }) {
    final result = create();
    if (weight != null) result.weight = weight;
    if (description != null) result.description = description;
    return result;
  }

  Weightsystem._();

  factory Weightsystem.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Weightsystem.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Weightsystem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'), createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'weight')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Weightsystem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Weightsystem copyWith(void Function(Weightsystem) updates) => super.copyWith((message) => updates(message as Weightsystem)) as Weightsystem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Weightsystem create() => Weightsystem._();
  @$core.override
  Weightsystem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Weightsystem getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Weightsystem>(create);
  static Weightsystem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get weight => $_getN(0);
  @$pb.TagNumber(1)
  set weight($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearWeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
