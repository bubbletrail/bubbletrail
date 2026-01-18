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
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $1;

import 'log.pb.dart' as $2;
import 'types.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// A single dive log entry.
class Dive extends $pb.GeneratedMessage {
  factory Dive({
    $core.String? id,
    $0.Metadata? meta,
    $core.String? syncedEtag,
    $core.int? number,
    $core.int? rating,
    $core.Iterable<$core.String>? tags,
    $1.Timestamp? start,
    $core.int? duration,
    $core.double? maxDepth,
    $core.double? meanDepth,
    $core.double? minTemp,
    $core.double? maxTemp,
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
    $core.Iterable<$2.Log>? deprecatedLogs,
    $core.Iterable<$2.SampleEvent>? events,
    $0.Tissues? startTissues,
    $0.Tissues? endTissues,
    $core.double? endSurfGf,
    $core.Iterable<$2.Log>? logs,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (meta != null) result.meta = meta;
    if (syncedEtag != null) result.syncedEtag = syncedEtag;
    if (number != null) result.number = number;
    if (rating != null) result.rating = rating;
    if (tags != null) result.tags.addAll(tags);
    if (start != null) result.start = start;
    if (duration != null) result.duration = duration;
    if (maxDepth != null) result.maxDepth = maxDepth;
    if (meanDepth != null) result.meanDepth = meanDepth;
    if (minTemp != null) result.minTemp = minTemp;
    if (maxTemp != null) result.maxTemp = maxTemp;
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
    if (deprecatedLogs != null) result.deprecatedLogs.addAll(deprecatedLogs);
    if (events != null) result.events.addAll(events);
    if (startTissues != null) result.startTissues = startTissues;
    if (endTissues != null) result.endTissues = endTissues;
    if (endSurfGf != null) result.endSurfGf = endSurfGf;
    if (logs != null) result.logs.addAll(logs);
    return result;
  }

  Dive._();

  factory Dive.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Dive.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Dive',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$0.Metadata>(2, _omitFieldNames ? '' : 'meta',
        subBuilder: $0.Metadata.create)
    ..aOS(3, _omitFieldNames ? '' : 'syncedEtag')
    ..aI(4, _omitFieldNames ? '' : 'number')
    ..aI(5, _omitFieldNames ? '' : 'rating')
    ..pPS(6, _omitFieldNames ? '' : 'tags')
    ..aOM<$1.Timestamp>(7, _omitFieldNames ? '' : 'start',
        subBuilder: $1.Timestamp.create)
    ..aI(8, _omitFieldNames ? '' : 'duration')
    ..aD(9, _omitFieldNames ? '' : 'maxDepth')
    ..aD(10, _omitFieldNames ? '' : 'meanDepth')
    ..aD(11, _omitFieldNames ? '' : 'minTemp')
    ..aD(12, _omitFieldNames ? '' : 'maxTemp')
    ..aD(13, _omitFieldNames ? '' : 'sac')
    ..aI(14, _omitFieldNames ? '' : 'otu')
    ..aI(15, _omitFieldNames ? '' : 'cns')
    ..aOS(16, _omitFieldNames ? '' : 'siteId')
    ..aOS(17, _omitFieldNames ? '' : 'instructor')
    ..aOS(18, _omitFieldNames ? '' : 'divemaster')
    ..pPS(19, _omitFieldNames ? '' : 'buddies')
    ..aOS(20, _omitFieldNames ? '' : 'notes')
    ..pPM<DiveCylinder>(21, _omitFieldNames ? '' : 'cylinders',
        subBuilder: DiveCylinder.create)
    ..pPM<Weightsystem>(22, _omitFieldNames ? '' : 'weightsystems',
        subBuilder: Weightsystem.create)
    ..pPM<$2.Log>(23, _omitFieldNames ? '' : 'deprecatedLogs',
        subBuilder: $2.Log.create)
    ..pPM<$2.SampleEvent>(24, _omitFieldNames ? '' : 'events',
        subBuilder: $2.SampleEvent.create)
    ..aOM<$0.Tissues>(25, _omitFieldNames ? '' : 'startTissues',
        subBuilder: $0.Tissues.create)
    ..aOM<$0.Tissues>(26, _omitFieldNames ? '' : 'endTissues',
        subBuilder: $0.Tissues.create)
    ..aD(28, _omitFieldNames ? '' : 'endSurfGf')
    ..pPM<$2.Log>(64, _omitFieldNames ? '' : 'logs', subBuilder: $2.Log.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Dive clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Dive copyWith(void Function(Dive) updates) =>
      super.copyWith((message) => updates(message as Dive)) as Dive;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Dive create() => Dive._();
  @$core.override
  Dive createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Dive getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Dive>(create);
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
  $core.String get syncedEtag => $_getSZ(2);
  @$pb.TagNumber(3)
  set syncedEtag($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSyncedEtag() => $_has(2);
  @$pb.TagNumber(3)
  void clearSyncedEtag() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get number => $_getIZ(3);
  @$pb.TagNumber(4)
  set number($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearNumber() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get rating => $_getIZ(4);
  @$pb.TagNumber(5)
  set rating($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRating() => $_has(4);
  @$pb.TagNumber(5)
  void clearRating() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get tags => $_getList(5);

  @$pb.TagNumber(7)
  $1.Timestamp get start => $_getN(6);
  @$pb.TagNumber(7)
  set start($1.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStart() => $_has(6);
  @$pb.TagNumber(7)
  void clearStart() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Timestamp ensureStart() => $_ensure(6);

  /// Summary data (populated from dive computer data, but editable by the user)
  @$pb.TagNumber(8)
  $core.int get duration => $_getIZ(7);
  @$pb.TagNumber(8)
  set duration($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDuration() => $_has(7);
  @$pb.TagNumber(8)
  void clearDuration() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get maxDepth => $_getN(8);
  @$pb.TagNumber(9)
  set maxDepth($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMaxDepth() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaxDepth() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get meanDepth => $_getN(9);
  @$pb.TagNumber(10)
  set meanDepth($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMeanDepth() => $_has(9);
  @$pb.TagNumber(10)
  void clearMeanDepth() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get minTemp => $_getN(10);
  @$pb.TagNumber(11)
  set minTemp($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasMinTemp() => $_has(10);
  @$pb.TagNumber(11)
  void clearMinTemp() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get maxTemp => $_getN(11);
  @$pb.TagNumber(12)
  set maxTemp($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMaxTemp() => $_has(11);
  @$pb.TagNumber(12)
  void clearMaxTemp() => $_clearField(12);

  /// Additional attributes
  @$pb.TagNumber(13)
  $core.double get sac => $_getN(12);
  @$pb.TagNumber(13)
  set sac($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSac() => $_has(12);
  @$pb.TagNumber(13)
  void clearSac() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get otu => $_getIZ(13);
  @$pb.TagNumber(14)
  set otu($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasOtu() => $_has(13);
  @$pb.TagNumber(14)
  void clearOtu() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get cns => $_getIZ(14);
  @$pb.TagNumber(15)
  set cns($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasCns() => $_has(14);
  @$pb.TagNumber(15)
  void clearCns() => $_clearField(15);

  /// Link to dive site
  @$pb.TagNumber(16)
  $core.String get siteId => $_getSZ(15);
  @$pb.TagNumber(16)
  set siteId($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasSiteId() => $_has(15);
  @$pb.TagNumber(16)
  void clearSiteId() => $_clearField(16);

  /// Child elements
  @$pb.TagNumber(17)
  $core.String get instructor => $_getSZ(16);
  @$pb.TagNumber(17)
  set instructor($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasInstructor() => $_has(16);
  @$pb.TagNumber(17)
  void clearInstructor() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get divemaster => $_getSZ(17);
  @$pb.TagNumber(18)
  set divemaster($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasDivemaster() => $_has(17);
  @$pb.TagNumber(18)
  void clearDivemaster() => $_clearField(18);

  @$pb.TagNumber(19)
  $pb.PbList<$core.String> get buddies => $_getList(18);

  @$pb.TagNumber(20)
  $core.String get notes => $_getSZ(19);
  @$pb.TagNumber(20)
  set notes($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasNotes() => $_has(19);
  @$pb.TagNumber(20)
  void clearNotes() => $_clearField(20);

  @$pb.TagNumber(21)
  $pb.PbList<DiveCylinder> get cylinders => $_getList(20);

  @$pb.TagNumber(22)
  $pb.PbList<Weightsystem> get weightsystems => $_getList(21);

  /// Raw dive computer data
  @$pb.TagNumber(23)
  $pb.PbList<$2.Log> get deprecatedLogs => $_getList(22);

  /// Events like gas changed, initially extracted from dive computer data
  /// but editable.
  @$pb.TagNumber(24)
  $pb.PbList<$2.SampleEvent> get events => $_getList(23);

  /// Start and end tissues for this dive, calculated
  @$pb.TagNumber(25)
  $0.Tissues get startTissues => $_getN(24);
  @$pb.TagNumber(25)
  set startTissues($0.Tissues value) => $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasStartTissues() => $_has(24);
  @$pb.TagNumber(25)
  void clearStartTissues() => $_clearField(25);
  @$pb.TagNumber(25)
  $0.Tissues ensureStartTissues() => $_ensure(24);

  @$pb.TagNumber(26)
  $0.Tissues get endTissues => $_getN(25);
  @$pb.TagNumber(26)
  set endTissues($0.Tissues value) => $_setField(26, value);
  @$pb.TagNumber(26)
  $core.bool hasEndTissues() => $_has(25);
  @$pb.TagNumber(26)
  void clearEndTissues() => $_clearField(26);
  @$pb.TagNumber(26)
  $0.Tissues ensureEndTissues() => $_ensure(25);

  @$pb.TagNumber(28)
  $core.double get endSurfGf => $_getN(26);
  @$pb.TagNumber(28)
  set endSurfGf($core.double value) => $_setDouble(26, value);
  @$pb.TagNumber(28)
  $core.bool hasEndSurfGf() => $_has(26);
  @$pb.TagNumber(28)
  void clearEndSurfGf() => $_clearField(28);

  @$pb.TagNumber(64)
  $pb.PbList<$2.Log> get logs => $_getList(27);
}

/// Per-dive cylinder usage information.
class DiveCylinder extends $pb.GeneratedMessage {
  factory DiveCylinder({
    $core.String? cylinderId,
    $core.double? beginPressure,
    $core.double? endPressure,
    $core.double? oxygen,
    $core.double? helium,
    $core.double? usedVolume,
    $core.double? sac,
    $0.Cylinder? cylinder,
  }) {
    final result = create();
    if (cylinderId != null) result.cylinderId = cylinderId;
    if (beginPressure != null) result.beginPressure = beginPressure;
    if (endPressure != null) result.endPressure = endPressure;
    if (oxygen != null) result.oxygen = oxygen;
    if (helium != null) result.helium = helium;
    if (usedVolume != null) result.usedVolume = usedVolume;
    if (sac != null) result.sac = sac;
    if (cylinder != null) result.cylinder = cylinder;
    return result;
  }

  DiveCylinder._();

  factory DiveCylinder.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiveCylinder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiveCylinder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cylinderId')
    ..aD(2, _omitFieldNames ? '' : 'beginPressure')
    ..aD(3, _omitFieldNames ? '' : 'endPressure')
    ..aD(4, _omitFieldNames ? '' : 'oxygen')
    ..aD(5, _omitFieldNames ? '' : 'helium')
    ..aD(6, _omitFieldNames ? '' : 'usedVolume')
    ..aD(7, _omitFieldNames ? '' : 'sac')
    ..aOM<$0.Cylinder>(8, _omitFieldNames ? '' : 'cylinder',
        subBuilder: $0.Cylinder.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiveCylinder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiveCylinder copyWith(void Function(DiveCylinder) updates) =>
      super.copyWith((message) => updates(message as DiveCylinder))
          as DiveCylinder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiveCylinder create() => DiveCylinder._();
  @$core.override
  DiveCylinder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiveCylinder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiveCylinder>(create);
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

  @$pb.TagNumber(6)
  $core.double get usedVolume => $_getN(5);
  @$pb.TagNumber(6)
  set usedVolume($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUsedVolume() => $_has(5);
  @$pb.TagNumber(6)
  void clearUsedVolume() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get sac => $_getN(6);
  @$pb.TagNumber(7)
  set sac($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSac() => $_has(6);
  @$pb.TagNumber(7)
  void clearSac() => $_clearField(7);

  /// Set when loaded, to full out volume etc.
  @$pb.TagNumber(8)
  $0.Cylinder get cylinder => $_getN(7);
  @$pb.TagNumber(8)
  set cylinder($0.Cylinder value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCylinder() => $_has(7);
  @$pb.TagNumber(8)
  void clearCylinder() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Cylinder ensureCylinder() => $_ensure(7);
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

  factory Weightsystem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Weightsystem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Weightsystem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'divestore'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'weight')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Weightsystem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Weightsystem copyWith(void Function(Weightsystem) updates) =>
      super.copyWith((message) => updates(message as Weightsystem))
          as Weightsystem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Weightsystem create() => Weightsystem._();
  @$core.override
  Weightsystem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Weightsystem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Weightsystem>(create);
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

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
