// This is a generated file - do not edit.
//
// Generated from preferences.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'preferences.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'preferences.pbenum.dart';

class S3Config extends $pb.GeneratedMessage {
  factory S3Config({
    $core.String? endpoint,
    $core.String? bucket,
    $core.String? accessKey,
    $core.String? secretKey,
    $core.String? region,
    $core.String? vaultKey,
  }) {
    final result = create();
    if (endpoint != null) result.endpoint = endpoint;
    if (bucket != null) result.bucket = bucket;
    if (accessKey != null) result.accessKey = accessKey;
    if (secretKey != null) result.secretKey = secretKey;
    if (region != null) result.region = region;
    if (vaultKey != null) result.vaultKey = vaultKey;
    return result;
  }

  S3Config._();

  factory S3Config.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory S3Config.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'S3Config',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'btstore'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'endpoint')
    ..aOS(2, _omitFieldNames ? '' : 'bucket')
    ..aOS(3, _omitFieldNames ? '' : 'accessKey')
    ..aOS(4, _omitFieldNames ? '' : 'secretKey')
    ..aOS(5, _omitFieldNames ? '' : 'region')
    ..aOS(6, _omitFieldNames ? '' : 'vaultKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  S3Config clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  S3Config copyWith(void Function(S3Config) updates) =>
      super.copyWith((message) => updates(message as S3Config)) as S3Config;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static S3Config create() => S3Config._();
  @$core.override
  S3Config createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static S3Config getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<S3Config>(create);
  static S3Config? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get endpoint => $_getSZ(0);
  @$pb.TagNumber(1)
  set endpoint($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEndpoint() => $_has(0);
  @$pb.TagNumber(1)
  void clearEndpoint() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get bucket => $_getSZ(1);
  @$pb.TagNumber(2)
  set bucket($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBucket() => $_has(1);
  @$pb.TagNumber(2)
  void clearBucket() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get accessKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set accessKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccessKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccessKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get secretKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set secretKey($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSecretKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearSecretKey() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get region => $_getSZ(4);
  @$pb.TagNumber(5)
  set region($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRegion() => $_has(4);
  @$pb.TagNumber(5)
  void clearRegion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get vaultKey => $_getSZ(5);
  @$pb.TagNumber(6)
  set vaultKey($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVaultKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearVaultKey() => $_clearField(6);
}

class Preferences extends $pb.GeneratedMessage {
  factory Preferences({
    DepthUnit? depthUnit,
    PressureUnit? pressureUnit,
    TemperatureUnit? temperatureUnit,
    VolumeUnit? volumeUnit,
    WeightUnit? weightUnit,
    DateFormatPref? dateFormat,
    TimeFormatPref? timeFormat,
    ThemeModePref? themeMode,
    SyncProviderPref? syncProvider,
    S3Config? s3Config,
    $core.double? gfLow,
    $core.double? gfHigh,
  }) {
    final result = create();
    if (depthUnit != null) result.depthUnit = depthUnit;
    if (pressureUnit != null) result.pressureUnit = pressureUnit;
    if (temperatureUnit != null) result.temperatureUnit = temperatureUnit;
    if (volumeUnit != null) result.volumeUnit = volumeUnit;
    if (weightUnit != null) result.weightUnit = weightUnit;
    if (dateFormat != null) result.dateFormat = dateFormat;
    if (timeFormat != null) result.timeFormat = timeFormat;
    if (themeMode != null) result.themeMode = themeMode;
    if (syncProvider != null) result.syncProvider = syncProvider;
    if (s3Config != null) result.s3Config = s3Config;
    if (gfLow != null) result.gfLow = gfLow;
    if (gfHigh != null) result.gfHigh = gfHigh;
    return result;
  }

  Preferences._();

  factory Preferences.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Preferences.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Preferences',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'btstore'),
      createEmptyInstance: create)
    ..aE<DepthUnit>(1, _omitFieldNames ? '' : 'depthUnit',
        enumValues: DepthUnit.values)
    ..aE<PressureUnit>(2, _omitFieldNames ? '' : 'pressureUnit',
        enumValues: PressureUnit.values)
    ..aE<TemperatureUnit>(3, _omitFieldNames ? '' : 'temperatureUnit',
        enumValues: TemperatureUnit.values)
    ..aE<VolumeUnit>(4, _omitFieldNames ? '' : 'volumeUnit',
        enumValues: VolumeUnit.values)
    ..aE<WeightUnit>(5, _omitFieldNames ? '' : 'weightUnit',
        enumValues: WeightUnit.values)
    ..aE<DateFormatPref>(6, _omitFieldNames ? '' : 'dateFormat',
        enumValues: DateFormatPref.values)
    ..aE<TimeFormatPref>(7, _omitFieldNames ? '' : 'timeFormat',
        enumValues: TimeFormatPref.values)
    ..aE<ThemeModePref>(8, _omitFieldNames ? '' : 'themeMode',
        enumValues: ThemeModePref.values)
    ..aE<SyncProviderPref>(9, _omitFieldNames ? '' : 'syncProvider',
        enumValues: SyncProviderPref.values)
    ..aOM<S3Config>(10, _omitFieldNames ? '' : 's3Config',
        subBuilder: S3Config.create)
    ..aD(11, _omitFieldNames ? '' : 'gfLow')
    ..aD(12, _omitFieldNames ? '' : 'gfHigh')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Preferences clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Preferences copyWith(void Function(Preferences) updates) =>
      super.copyWith((message) => updates(message as Preferences))
          as Preferences;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Preferences create() => Preferences._();
  @$core.override
  Preferences createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Preferences getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Preferences>(create);
  static Preferences? _defaultInstance;

  @$pb.TagNumber(1)
  DepthUnit get depthUnit => $_getN(0);
  @$pb.TagNumber(1)
  set depthUnit(DepthUnit value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDepthUnit() => $_has(0);
  @$pb.TagNumber(1)
  void clearDepthUnit() => $_clearField(1);

  @$pb.TagNumber(2)
  PressureUnit get pressureUnit => $_getN(1);
  @$pb.TagNumber(2)
  set pressureUnit(PressureUnit value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPressureUnit() => $_has(1);
  @$pb.TagNumber(2)
  void clearPressureUnit() => $_clearField(2);

  @$pb.TagNumber(3)
  TemperatureUnit get temperatureUnit => $_getN(2);
  @$pb.TagNumber(3)
  set temperatureUnit(TemperatureUnit value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTemperatureUnit() => $_has(2);
  @$pb.TagNumber(3)
  void clearTemperatureUnit() => $_clearField(3);

  @$pb.TagNumber(4)
  VolumeUnit get volumeUnit => $_getN(3);
  @$pb.TagNumber(4)
  set volumeUnit(VolumeUnit value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasVolumeUnit() => $_has(3);
  @$pb.TagNumber(4)
  void clearVolumeUnit() => $_clearField(4);

  @$pb.TagNumber(5)
  WeightUnit get weightUnit => $_getN(4);
  @$pb.TagNumber(5)
  set weightUnit(WeightUnit value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasWeightUnit() => $_has(4);
  @$pb.TagNumber(5)
  void clearWeightUnit() => $_clearField(5);

  @$pb.TagNumber(6)
  DateFormatPref get dateFormat => $_getN(5);
  @$pb.TagNumber(6)
  set dateFormat(DateFormatPref value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasDateFormat() => $_has(5);
  @$pb.TagNumber(6)
  void clearDateFormat() => $_clearField(6);

  @$pb.TagNumber(7)
  TimeFormatPref get timeFormat => $_getN(6);
  @$pb.TagNumber(7)
  set timeFormat(TimeFormatPref value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTimeFormat() => $_has(6);
  @$pb.TagNumber(7)
  void clearTimeFormat() => $_clearField(7);

  @$pb.TagNumber(8)
  ThemeModePref get themeMode => $_getN(7);
  @$pb.TagNumber(8)
  set themeMode(ThemeModePref value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasThemeMode() => $_has(7);
  @$pb.TagNumber(8)
  void clearThemeMode() => $_clearField(8);

  @$pb.TagNumber(9)
  SyncProviderPref get syncProvider => $_getN(8);
  @$pb.TagNumber(9)
  set syncProvider(SyncProviderPref value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasSyncProvider() => $_has(8);
  @$pb.TagNumber(9)
  void clearSyncProvider() => $_clearField(9);

  @$pb.TagNumber(10)
  S3Config get s3Config => $_getN(9);
  @$pb.TagNumber(10)
  set s3Config(S3Config value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasS3Config() => $_has(9);
  @$pb.TagNumber(10)
  void clearS3Config() => $_clearField(10);
  @$pb.TagNumber(10)
  S3Config ensureS3Config() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.double get gfLow => $_getN(10);
  @$pb.TagNumber(11)
  set gfLow($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasGfLow() => $_has(10);
  @$pb.TagNumber(11)
  void clearGfLow() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get gfHigh => $_getN(11);
  @$pb.TagNumber(12)
  set gfHigh($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasGfHigh() => $_has(11);
  @$pb.TagNumber(12)
  void clearGfHigh() => $_clearField(12);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
