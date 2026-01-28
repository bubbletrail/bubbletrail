// This is a generated file - do not edit.
//
// Generated from log.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Water type for salinity.
class WaterType extends $pb.ProtobufEnum {
  static const WaterType WATER_TYPE_UNSPECIFIED =
      WaterType._(0, _omitEnumNames ? '' : 'WATER_TYPE_UNSPECIFIED');
  static const WaterType WATER_TYPE_EN13319 =
      WaterType._(1, _omitEnumNames ? '' : 'WATER_TYPE_EN13319');
  static const WaterType WATER_TYPE_FRESH =
      WaterType._(2, _omitEnumNames ? '' : 'WATER_TYPE_FRESH');
  static const WaterType WATER_TYPE_SALT =
      WaterType._(3, _omitEnumNames ? '' : 'WATER_TYPE_SALT');

  static const $core.List<WaterType> values = <WaterType>[
    WATER_TYPE_UNSPECIFIED,
    WATER_TYPE_EN13319,
    WATER_TYPE_FRESH,
    WATER_TYPE_SALT,
  ];

  static final $core.List<WaterType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static WaterType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const WaterType._(super.value, super.name);
}

/// Dive mode.
class DiveMode extends $pb.ProtobufEnum {
  static const DiveMode DIVE_MODE_UNSPECIFIED =
      DiveMode._(0, _omitEnumNames ? '' : 'DIVE_MODE_UNSPECIFIED');
  static const DiveMode DIVE_MODE_FREEDIVE =
      DiveMode._(1, _omitEnumNames ? '' : 'DIVE_MODE_FREEDIVE');
  static const DiveMode DIVE_MODE_GAUGE =
      DiveMode._(2, _omitEnumNames ? '' : 'DIVE_MODE_GAUGE');
  static const DiveMode DIVE_MODE_OPENCIRCUIT =
      DiveMode._(3, _omitEnumNames ? '' : 'DIVE_MODE_OPENCIRCUIT');
  static const DiveMode DIVE_MODE_CLOSED_CIRCUIT_REBREATHER = DiveMode._(
      4, _omitEnumNames ? '' : 'DIVE_MODE_CLOSED_CIRCUIT_REBREATHER');
  static const DiveMode DIVE_MODE_SEMI_CLOSED_REBREATHER =
      DiveMode._(5, _omitEnumNames ? '' : 'DIVE_MODE_SEMI_CLOSED_REBREATHER');

  static const $core.List<DiveMode> values = <DiveMode>[
    DIVE_MODE_UNSPECIFIED,
    DIVE_MODE_FREEDIVE,
    DIVE_MODE_GAUGE,
    DIVE_MODE_OPENCIRCUIT,
    DIVE_MODE_CLOSED_CIRCUIT_REBREATHER,
    DIVE_MODE_SEMI_CLOSED_REBREATHER,
  ];

  static final $core.List<DiveMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static DiveMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DiveMode._(super.value, super.name);
}

/// Gas usage type.
class GasUsage extends $pb.ProtobufEnum {
  static const GasUsage GAS_USAGE_UNSPECIFIED =
      GasUsage._(0, _omitEnumNames ? '' : 'GAS_USAGE_UNSPECIFIED');
  static const GasUsage GAS_USAGE_NONE =
      GasUsage._(1, _omitEnumNames ? '' : 'GAS_USAGE_NONE');
  static const GasUsage GAS_USAGE_OXYGEN =
      GasUsage._(2, _omitEnumNames ? '' : 'GAS_USAGE_OXYGEN');
  static const GasUsage GAS_USAGE_DILUENT =
      GasUsage._(3, _omitEnumNames ? '' : 'GAS_USAGE_DILUENT');
  static const GasUsage GAS_USAGE_SIDEMOUNT =
      GasUsage._(4, _omitEnumNames ? '' : 'GAS_USAGE_SIDEMOUNT');

  static const $core.List<GasUsage> values = <GasUsage>[
    GAS_USAGE_UNSPECIFIED,
    GAS_USAGE_NONE,
    GAS_USAGE_OXYGEN,
    GAS_USAGE_DILUENT,
    GAS_USAGE_SIDEMOUNT,
  ];

  static final $core.List<GasUsage?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static GasUsage? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GasUsage._(super.value, super.name);
}

/// Tank volume type.
class TankVolumeType extends $pb.ProtobufEnum {
  static const TankVolumeType TANK_VOLUME_TYPE_UNSPECIFIED =
      TankVolumeType._(0, _omitEnumNames ? '' : 'TANK_VOLUME_TYPE_UNSPECIFIED');
  static const TankVolumeType TANK_VOLUME_TYPE_NONE =
      TankVolumeType._(1, _omitEnumNames ? '' : 'TANK_VOLUME_TYPE_NONE');
  static const TankVolumeType TANK_VOLUME_TYPE_METRIC =
      TankVolumeType._(2, _omitEnumNames ? '' : 'TANK_VOLUME_TYPE_METRIC');
  static const TankVolumeType TANK_VOLUME_TYPE_IMPERIAL =
      TankVolumeType._(3, _omitEnumNames ? '' : 'TANK_VOLUME_TYPE_IMPERIAL');

  static const $core.List<TankVolumeType> values = <TankVolumeType>[
    TANK_VOLUME_TYPE_UNSPECIFIED,
    TANK_VOLUME_TYPE_NONE,
    TANK_VOLUME_TYPE_METRIC,
    TANK_VOLUME_TYPE_IMPERIAL,
  ];

  static final $core.List<TankVolumeType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static TankVolumeType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TankVolumeType._(super.value, super.name);
}

/// Decompression model type.
class DecoModelType extends $pb.ProtobufEnum {
  static const DecoModelType DECO_MODEL_TYPE_UNSPECIFIED =
      DecoModelType._(0, _omitEnumNames ? '' : 'DECO_MODEL_TYPE_UNSPECIFIED');
  static const DecoModelType DECO_MODEL_TYPE_NONE =
      DecoModelType._(1, _omitEnumNames ? '' : 'DECO_MODEL_TYPE_NONE');
  static const DecoModelType DECO_MODEL_TYPE_BUHLMANN =
      DecoModelType._(2, _omitEnumNames ? '' : 'DECO_MODEL_TYPE_BUHLMANN');
  static const DecoModelType DECO_MODEL_TYPE_VPM =
      DecoModelType._(3, _omitEnumNames ? '' : 'DECO_MODEL_TYPE_VPM');
  static const DecoModelType DECO_MODEL_TYPE_RGBM =
      DecoModelType._(4, _omitEnumNames ? '' : 'DECO_MODEL_TYPE_RGBM');
  static const DecoModelType DECO_MODEL_TYPE_DCIEM =
      DecoModelType._(5, _omitEnumNames ? '' : 'DECO_MODEL_TYPE_DCIEM');

  static const $core.List<DecoModelType> values = <DecoModelType>[
    DECO_MODEL_TYPE_UNSPECIFIED,
    DECO_MODEL_TYPE_NONE,
    DECO_MODEL_TYPE_BUHLMANN,
    DECO_MODEL_TYPE_VPM,
    DECO_MODEL_TYPE_RGBM,
    DECO_MODEL_TYPE_DCIEM,
  ];

  static final $core.List<DecoModelType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static DecoModelType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DecoModelType._(super.value, super.name);
}

/// Decompression stop type (in samples).
class DecoStopType extends $pb.ProtobufEnum {
  static const DecoStopType DECO_STOP_TYPE_UNSPECIFIED =
      DecoStopType._(0, _omitEnumNames ? '' : 'DECO_STOP_TYPE_UNSPECIFIED');
  static const DecoStopType DECO_STOP_TYPE_NDL =
      DecoStopType._(1, _omitEnumNames ? '' : 'DECO_STOP_TYPE_NDL');
  static const DecoStopType DECO_STOP_TYPE_SAFETY_STOP =
      DecoStopType._(2, _omitEnumNames ? '' : 'DECO_STOP_TYPE_SAFETY_STOP');
  static const DecoStopType DECO_STOP_TYPE_DECO_STOP =
      DecoStopType._(3, _omitEnumNames ? '' : 'DECO_STOP_TYPE_DECO_STOP');
  static const DecoStopType DECO_STOP_TYPE_DEEP_STOP =
      DecoStopType._(4, _omitEnumNames ? '' : 'DECO_STOP_TYPE_DEEP_STOP');

  static const $core.List<DecoStopType> values = <DecoStopType>[
    DECO_STOP_TYPE_UNSPECIFIED,
    DECO_STOP_TYPE_NDL,
    DECO_STOP_TYPE_SAFETY_STOP,
    DECO_STOP_TYPE_DECO_STOP,
    DECO_STOP_TYPE_DEEP_STOP,
  ];

  static final $core.List<DecoStopType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static DecoStopType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DecoStopType._(super.value, super.name);
}

/// Sample event type.
class SampleEventType extends $pb.ProtobufEnum {
  static const SampleEventType SAMPLE_EVENT_TYPE_UNSPECIFIED =
      SampleEventType._(
          0, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_UNSPECIFIED');
  static const SampleEventType SAMPLE_EVENT_TYPE_NONE =
      SampleEventType._(1, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_NONE');
  static const SampleEventType SAMPLE_EVENT_TYPE_DECO_STOP =
      SampleEventType._(2, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_DECO_STOP');
  static const SampleEventType SAMPLE_EVENT_TYPE_RBT =
      SampleEventType._(3, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_RBT');
  static const SampleEventType SAMPLE_EVENT_TYPE_ASCENT =
      SampleEventType._(4, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_ASCENT');
  static const SampleEventType SAMPLE_EVENT_TYPE_CEILING =
      SampleEventType._(5, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_CEILING');
  static const SampleEventType SAMPLE_EVENT_TYPE_WORKLOAD =
      SampleEventType._(6, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_WORKLOAD');
  static const SampleEventType SAMPLE_EVENT_TYPE_TRANSMITTER =
      SampleEventType._(
          7, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_TRANSMITTER');
  static const SampleEventType SAMPLE_EVENT_TYPE_VIOLATION =
      SampleEventType._(8, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_VIOLATION');
  static const SampleEventType SAMPLE_EVENT_TYPE_BOOKMARK =
      SampleEventType._(9, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_BOOKMARK');
  static const SampleEventType SAMPLE_EVENT_TYPE_SURFACE =
      SampleEventType._(10, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_SURFACE');
  static const SampleEventType SAMPLE_EVENT_TYPE_SAFETY_STOP =
      SampleEventType._(
          11, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_SAFETY_STOP');
  static const SampleEventType SAMPLE_EVENT_TYPE_GAS_CHANGE = SampleEventType._(
      12, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_GAS_CHANGE');
  static const SampleEventType SAMPLE_EVENT_TYPE_SAFETY_STOP_VOLUNTARY =
      SampleEventType._(
          13, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_SAFETY_STOP_VOLUNTARY');
  static const SampleEventType SAMPLE_EVENT_TYPE_SAFETY_STOP_MANDATORY =
      SampleEventType._(
          14, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_SAFETY_STOP_MANDATORY');
  static const SampleEventType SAMPLE_EVENT_TYPE_DEEP_STOP = SampleEventType._(
      15, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_DEEP_STOP');
  static const SampleEventType SAMPLE_EVENT_TYPE_CEILING_SAFETY_STOP =
      SampleEventType._(
          16, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_CEILING_SAFETY_STOP');
  static const SampleEventType SAMPLE_EVENT_TYPE_FLOOR =
      SampleEventType._(17, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_FLOOR');
  static const SampleEventType SAMPLE_EVENT_TYPE_DIVE_TIME = SampleEventType._(
      18, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_DIVE_TIME');
  static const SampleEventType SAMPLE_EVENT_TYPE_MAX_DEPTH = SampleEventType._(
      19, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_MAX_DEPTH');
  static const SampleEventType SAMPLE_EVENT_TYPE_OLF =
      SampleEventType._(20, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_OLF');
  static const SampleEventType SAMPLE_EVENT_TYPE_PO2 =
      SampleEventType._(21, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_PO2');
  static const SampleEventType SAMPLE_EVENT_TYPE_AIR_TIME =
      SampleEventType._(22, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_AIR_TIME');
  static const SampleEventType SAMPLE_EVENT_TYPE_RGBM =
      SampleEventType._(23, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_RGBM');
  static const SampleEventType SAMPLE_EVENT_TYPE_HEADING =
      SampleEventType._(24, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_HEADING');
  static const SampleEventType SAMPLE_EVENT_TYPE_TISSUE_LEVEL =
      SampleEventType._(
          25, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_TISSUE_LEVEL');
  static const SampleEventType SAMPLE_EVENT_TYPE_GAS_CHANGE_2 =
      SampleEventType._(
          26, _omitEnumNames ? '' : 'SAMPLE_EVENT_TYPE_GAS_CHANGE_2');

  static const $core.List<SampleEventType> values = <SampleEventType>[
    SAMPLE_EVENT_TYPE_UNSPECIFIED,
    SAMPLE_EVENT_TYPE_NONE,
    SAMPLE_EVENT_TYPE_DECO_STOP,
    SAMPLE_EVENT_TYPE_RBT,
    SAMPLE_EVENT_TYPE_ASCENT,
    SAMPLE_EVENT_TYPE_CEILING,
    SAMPLE_EVENT_TYPE_WORKLOAD,
    SAMPLE_EVENT_TYPE_TRANSMITTER,
    SAMPLE_EVENT_TYPE_VIOLATION,
    SAMPLE_EVENT_TYPE_BOOKMARK,
    SAMPLE_EVENT_TYPE_SURFACE,
    SAMPLE_EVENT_TYPE_SAFETY_STOP,
    SAMPLE_EVENT_TYPE_GAS_CHANGE,
    SAMPLE_EVENT_TYPE_SAFETY_STOP_VOLUNTARY,
    SAMPLE_EVENT_TYPE_SAFETY_STOP_MANDATORY,
    SAMPLE_EVENT_TYPE_DEEP_STOP,
    SAMPLE_EVENT_TYPE_CEILING_SAFETY_STOP,
    SAMPLE_EVENT_TYPE_FLOOR,
    SAMPLE_EVENT_TYPE_DIVE_TIME,
    SAMPLE_EVENT_TYPE_MAX_DEPTH,
    SAMPLE_EVENT_TYPE_OLF,
    SAMPLE_EVENT_TYPE_PO2,
    SAMPLE_EVENT_TYPE_AIR_TIME,
    SAMPLE_EVENT_TYPE_RGBM,
    SAMPLE_EVENT_TYPE_HEADING,
    SAMPLE_EVENT_TYPE_TISSUE_LEVEL,
    SAMPLE_EVENT_TYPE_GAS_CHANGE_2,
  ];

  static final $core.List<SampleEventType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 26);
  static SampleEventType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SampleEventType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
