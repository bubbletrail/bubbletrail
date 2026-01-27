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

class DepthUnit extends $pb.ProtobufEnum {
  static const DepthUnit DEPTH_UNIT_METERS =
      DepthUnit._(0, _omitEnumNames ? '' : 'DEPTH_UNIT_METERS');
  static const DepthUnit DEPTH_UNIT_FEET =
      DepthUnit._(1, _omitEnumNames ? '' : 'DEPTH_UNIT_FEET');

  static const $core.List<DepthUnit> values = <DepthUnit>[
    DEPTH_UNIT_METERS,
    DEPTH_UNIT_FEET,
  ];

  static final $core.List<DepthUnit?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static DepthUnit? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DepthUnit._(super.value, super.name);
}

class PressureUnit extends $pb.ProtobufEnum {
  static const PressureUnit PRESSURE_UNIT_BAR =
      PressureUnit._(0, _omitEnumNames ? '' : 'PRESSURE_UNIT_BAR');
  static const PressureUnit PRESSURE_UNIT_PSI =
      PressureUnit._(1, _omitEnumNames ? '' : 'PRESSURE_UNIT_PSI');

  static const $core.List<PressureUnit> values = <PressureUnit>[
    PRESSURE_UNIT_BAR,
    PRESSURE_UNIT_PSI,
  ];

  static final $core.List<PressureUnit?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static PressureUnit? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PressureUnit._(super.value, super.name);
}

class TemperatureUnit extends $pb.ProtobufEnum {
  static const TemperatureUnit TEMPERATURE_UNIT_CELSIUS =
      TemperatureUnit._(0, _omitEnumNames ? '' : 'TEMPERATURE_UNIT_CELSIUS');
  static const TemperatureUnit TEMPERATURE_UNIT_FAHRENHEIT =
      TemperatureUnit._(1, _omitEnumNames ? '' : 'TEMPERATURE_UNIT_FAHRENHEIT');

  static const $core.List<TemperatureUnit> values = <TemperatureUnit>[
    TEMPERATURE_UNIT_CELSIUS,
    TEMPERATURE_UNIT_FAHRENHEIT,
  ];

  static final $core.List<TemperatureUnit?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static TemperatureUnit? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TemperatureUnit._(super.value, super.name);
}

class VolumeUnit extends $pb.ProtobufEnum {
  static const VolumeUnit VOLUME_UNIT_LITERS =
      VolumeUnit._(0, _omitEnumNames ? '' : 'VOLUME_UNIT_LITERS');
  static const VolumeUnit VOLUME_UNIT_CUFT =
      VolumeUnit._(1, _omitEnumNames ? '' : 'VOLUME_UNIT_CUFT');

  static const $core.List<VolumeUnit> values = <VolumeUnit>[
    VOLUME_UNIT_LITERS,
    VOLUME_UNIT_CUFT,
  ];

  static final $core.List<VolumeUnit?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static VolumeUnit? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const VolumeUnit._(super.value, super.name);
}

class WeightUnit extends $pb.ProtobufEnum {
  static const WeightUnit WEIGHT_UNIT_KG =
      WeightUnit._(0, _omitEnumNames ? '' : 'WEIGHT_UNIT_KG');
  static const WeightUnit WEIGHT_UNIT_LB =
      WeightUnit._(1, _omitEnumNames ? '' : 'WEIGHT_UNIT_LB');

  static const $core.List<WeightUnit> values = <WeightUnit>[
    WEIGHT_UNIT_KG,
    WEIGHT_UNIT_LB,
  ];

  static final $core.List<WeightUnit?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static WeightUnit? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const WeightUnit._(super.value, super.name);
}

class DateFormatPref extends $pb.ProtobufEnum {
  static const DateFormatPref DATE_FORMAT_ISO =
      DateFormatPref._(0, _omitEnumNames ? '' : 'DATE_FORMAT_ISO');
  static const DateFormatPref DATE_FORMAT_US =
      DateFormatPref._(1, _omitEnumNames ? '' : 'DATE_FORMAT_US');
  static const DateFormatPref DATE_FORMAT_EU =
      DateFormatPref._(2, _omitEnumNames ? '' : 'DATE_FORMAT_EU');

  static const $core.List<DateFormatPref> values = <DateFormatPref>[
    DATE_FORMAT_ISO,
    DATE_FORMAT_US,
    DATE_FORMAT_EU,
  ];

  static final $core.List<DateFormatPref?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static DateFormatPref? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DateFormatPref._(super.value, super.name);
}

class TimeFormatPref extends $pb.ProtobufEnum {
  static const TimeFormatPref TIME_FORMAT_H24 =
      TimeFormatPref._(0, _omitEnumNames ? '' : 'TIME_FORMAT_H24');
  static const TimeFormatPref TIME_FORMAT_H12 =
      TimeFormatPref._(1, _omitEnumNames ? '' : 'TIME_FORMAT_H12');

  static const $core.List<TimeFormatPref> values = <TimeFormatPref>[
    TIME_FORMAT_H24,
    TIME_FORMAT_H12,
  ];

  static final $core.List<TimeFormatPref?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static TimeFormatPref? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TimeFormatPref._(super.value, super.name);
}

class ThemeModePref extends $pb.ProtobufEnum {
  static const ThemeModePref THEME_MODE_SYSTEM =
      ThemeModePref._(0, _omitEnumNames ? '' : 'THEME_MODE_SYSTEM');
  static const ThemeModePref THEME_MODE_LIGHT =
      ThemeModePref._(1, _omitEnumNames ? '' : 'THEME_MODE_LIGHT');
  static const ThemeModePref THEME_MODE_DARK =
      ThemeModePref._(2, _omitEnumNames ? '' : 'THEME_MODE_DARK');

  static const $core.List<ThemeModePref> values = <ThemeModePref>[
    THEME_MODE_SYSTEM,
    THEME_MODE_LIGHT,
    THEME_MODE_DARK,
  ];

  static final $core.List<ThemeModePref?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ThemeModePref? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ThemeModePref._(super.value, super.name);
}

class SyncProviderPref extends $pb.ProtobufEnum {
  static const SyncProviderPref SYNC_PROVIDER_NONE =
      SyncProviderPref._(0, _omitEnumNames ? '' : 'SYNC_PROVIDER_NONE');
  static const SyncProviderPref SYNC_PROVIDER_BUBBLETRAIL =
      SyncProviderPref._(1, _omitEnumNames ? '' : 'SYNC_PROVIDER_BUBBLETRAIL');
  static const SyncProviderPref SYNC_PROVIDER_S3 =
      SyncProviderPref._(2, _omitEnumNames ? '' : 'SYNC_PROVIDER_S3');

  static const $core.List<SyncProviderPref> values = <SyncProviderPref>[
    SYNC_PROVIDER_NONE,
    SYNC_PROVIDER_BUBBLETRAIL,
    SYNC_PROVIDER_S3,
  ];

  static final $core.List<SyncProviderPref?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SyncProviderPref? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SyncProviderPref._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
