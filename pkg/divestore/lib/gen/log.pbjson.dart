// This is a generated file - do not edit.
//
// Generated from log.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use waterTypeDescriptor instead')
const WaterType$json = {
  '1': 'WaterType',
  '2': [
    {'1': 'WATER_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'WATER_TYPE_EN13319', '2': 1},
    {'1': 'WATER_TYPE_FRESH', '2': 2},
    {'1': 'WATER_TYPE_SALT', '2': 3},
  ],
};

/// Descriptor for `WaterType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List waterTypeDescriptor = $convert.base64Decode(
    'CglXYXRlclR5cGUSGgoWV0FURVJfVFlQRV9VTlNQRUNJRklFRBAAEhYKEldBVEVSX1RZUEVfRU'
    '4xMzMxORABEhQKEFdBVEVSX1RZUEVfRlJFU0gQAhITCg9XQVRFUl9UWVBFX1NBTFQQAw==');

@$core.Deprecated('Use diveModeDescriptor instead')
const DiveMode$json = {
  '1': 'DiveMode',
  '2': [
    {'1': 'DIVE_MODE_UNSPECIFIED', '2': 0},
    {'1': 'DIVE_MODE_FREEDIVE', '2': 1},
    {'1': 'DIVE_MODE_GAUGE', '2': 2},
    {'1': 'DIVE_MODE_OPENCIRCUIT', '2': 3},
    {'1': 'DIVE_MODE_CLOSED_CIRCUIT_REBREATHER', '2': 4},
    {'1': 'DIVE_MODE_SEMI_CLOSED_REBREATHER', '2': 5},
  ],
};

/// Descriptor for `DiveMode`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List diveModeDescriptor = $convert.base64Decode(
    'CghEaXZlTW9kZRIZChVESVZFX01PREVfVU5TUEVDSUZJRUQQABIWChJESVZFX01PREVfRlJFRU'
    'RJVkUQARITCg9ESVZFX01PREVfR0FVR0UQAhIZChVESVZFX01PREVfT1BFTkNJUkNVSVQQAxIn'
    'CiNESVZFX01PREVfQ0xPU0VEX0NJUkNVSVRfUkVCUkVBVEhFUhAEEiQKIERJVkVfTU9ERV9TRU'
    '1JX0NMT1NFRF9SRUJSRUFUSEVSEAU=');

@$core.Deprecated('Use gasUsageDescriptor instead')
const GasUsage$json = {
  '1': 'GasUsage',
  '2': [
    {'1': 'GAS_USAGE_UNSPECIFIED', '2': 0},
    {'1': 'GAS_USAGE_NONE', '2': 1},
    {'1': 'GAS_USAGE_OXYGEN', '2': 2},
    {'1': 'GAS_USAGE_DILUENT', '2': 3},
    {'1': 'GAS_USAGE_SIDEMOUNT', '2': 4},
  ],
};

/// Descriptor for `GasUsage`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List gasUsageDescriptor = $convert.base64Decode(
    'CghHYXNVc2FnZRIZChVHQVNfVVNBR0VfVU5TUEVDSUZJRUQQABISCg5HQVNfVVNBR0VfTk9ORR'
    'ABEhQKEEdBU19VU0FHRV9PWFlHRU4QAhIVChFHQVNfVVNBR0VfRElMVUVOVBADEhcKE0dBU19V'
    'U0FHRV9TSURFTU9VTlQQBA==');

@$core.Deprecated('Use tankVolumeTypeDescriptor instead')
const TankVolumeType$json = {
  '1': 'TankVolumeType',
  '2': [
    {'1': 'TANK_VOLUME_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'TANK_VOLUME_TYPE_NONE', '2': 1},
    {'1': 'TANK_VOLUME_TYPE_METRIC', '2': 2},
    {'1': 'TANK_VOLUME_TYPE_IMPERIAL', '2': 3},
  ],
};

/// Descriptor for `TankVolumeType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List tankVolumeTypeDescriptor = $convert.base64Decode(
    'Cg5UYW5rVm9sdW1lVHlwZRIgChxUQU5LX1ZPTFVNRV9UWVBFX1VOU1BFQ0lGSUVEEAASGQoVVE'
    'FOS19WT0xVTUVfVFlQRV9OT05FEAESGwoXVEFOS19WT0xVTUVfVFlQRV9NRVRSSUMQAhIdChlU'
    'QU5LX1ZPTFVNRV9UWVBFX0lNUEVSSUFMEAM=');

@$core.Deprecated('Use decoModelTypeDescriptor instead')
const DecoModelType$json = {
  '1': 'DecoModelType',
  '2': [
    {'1': 'DECO_MODEL_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'DECO_MODEL_TYPE_NONE', '2': 1},
    {'1': 'DECO_MODEL_TYPE_BUHLMANN', '2': 2},
    {'1': 'DECO_MODEL_TYPE_VPM', '2': 3},
    {'1': 'DECO_MODEL_TYPE_RGBM', '2': 4},
    {'1': 'DECO_MODEL_TYPE_DCIEM', '2': 5},
  ],
};

/// Descriptor for `DecoModelType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List decoModelTypeDescriptor = $convert.base64Decode(
    'Cg1EZWNvTW9kZWxUeXBlEh8KG0RFQ09fTU9ERUxfVFlQRV9VTlNQRUNJRklFRBAAEhgKFERFQ0'
    '9fTU9ERUxfVFlQRV9OT05FEAESHAoYREVDT19NT0RFTF9UWVBFX0JVSExNQU5OEAISFwoTREVD'
    'T19NT0RFTF9UWVBFX1ZQTRADEhgKFERFQ09fTU9ERUxfVFlQRV9SR0JNEAQSGQoVREVDT19NT0'
    'RFTF9UWVBFX0RDSUVNEAU=');

@$core.Deprecated('Use decoStopTypeDescriptor instead')
const DecoStopType$json = {
  '1': 'DecoStopType',
  '2': [
    {'1': 'DECO_STOP_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'DECO_STOP_TYPE_NDL', '2': 1},
    {'1': 'DECO_STOP_TYPE_SAFETY_STOP', '2': 2},
    {'1': 'DECO_STOP_TYPE_DECO_STOP', '2': 3},
    {'1': 'DECO_STOP_TYPE_DEEP_STOP', '2': 4},
  ],
};

/// Descriptor for `DecoStopType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List decoStopTypeDescriptor = $convert.base64Decode(
    'CgxEZWNvU3RvcFR5cGUSHgoaREVDT19TVE9QX1RZUEVfVU5TUEVDSUZJRUQQABIWChJERUNPX1'
    'NUT1BfVFlQRV9OREwQARIeChpERUNPX1NUT1BfVFlQRV9TQUZFVFlfU1RPUBACEhwKGERFQ09f'
    'U1RPUF9UWVBFX0RFQ09fU1RPUBADEhwKGERFQ09fU1RPUF9UWVBFX0RFRVBfU1RPUBAE');

@$core.Deprecated('Use sampleEventTypeDescriptor instead')
const SampleEventType$json = {
  '1': 'SampleEventType',
  '2': [
    {'1': 'SAMPLE_EVENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SAMPLE_EVENT_TYPE_NONE', '2': 1},
    {'1': 'SAMPLE_EVENT_TYPE_DECO_STOP', '2': 2},
    {'1': 'SAMPLE_EVENT_TYPE_RBT', '2': 3},
    {'1': 'SAMPLE_EVENT_TYPE_ASCENT', '2': 4},
    {'1': 'SAMPLE_EVENT_TYPE_CEILING', '2': 5},
    {'1': 'SAMPLE_EVENT_TYPE_WORKLOAD', '2': 6},
    {'1': 'SAMPLE_EVENT_TYPE_TRANSMITTER', '2': 7},
    {'1': 'SAMPLE_EVENT_TYPE_VIOLATION', '2': 8},
    {'1': 'SAMPLE_EVENT_TYPE_BOOKMARK', '2': 9},
    {'1': 'SAMPLE_EVENT_TYPE_SURFACE', '2': 10},
    {'1': 'SAMPLE_EVENT_TYPE_SAFETY_STOP', '2': 11},
    {'1': 'SAMPLE_EVENT_TYPE_GAS_CHANGE', '2': 12},
    {'1': 'SAMPLE_EVENT_TYPE_SAFETY_STOP_VOLUNTARY', '2': 13},
    {'1': 'SAMPLE_EVENT_TYPE_SAFETY_STOP_MANDATORY', '2': 14},
    {'1': 'SAMPLE_EVENT_TYPE_DEEP_STOP', '2': 15},
    {'1': 'SAMPLE_EVENT_TYPE_CEILING_SAFETY_STOP', '2': 16},
    {'1': 'SAMPLE_EVENT_TYPE_FLOOR', '2': 17},
    {'1': 'SAMPLE_EVENT_TYPE_DIVE_TIME', '2': 18},
    {'1': 'SAMPLE_EVENT_TYPE_MAX_DEPTH', '2': 19},
    {'1': 'SAMPLE_EVENT_TYPE_OLF', '2': 20},
    {'1': 'SAMPLE_EVENT_TYPE_PO2', '2': 21},
    {'1': 'SAMPLE_EVENT_TYPE_AIR_TIME', '2': 22},
    {'1': 'SAMPLE_EVENT_TYPE_RGBM', '2': 23},
    {'1': 'SAMPLE_EVENT_TYPE_HEADING', '2': 24},
    {'1': 'SAMPLE_EVENT_TYPE_TISSUE_LEVEL', '2': 25},
    {'1': 'SAMPLE_EVENT_TYPE_GAS_CHANGE_2', '2': 26},
  ],
};

/// Descriptor for `SampleEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sampleEventTypeDescriptor = $convert.base64Decode(
    'Cg9TYW1wbGVFdmVudFR5cGUSIQodU0FNUExFX0VWRU5UX1RZUEVfVU5TUEVDSUZJRUQQABIaCh'
    'ZTQU1QTEVfRVZFTlRfVFlQRV9OT05FEAESHwobU0FNUExFX0VWRU5UX1RZUEVfREVDT19TVE9Q'
    'EAISGQoVU0FNUExFX0VWRU5UX1RZUEVfUkJUEAMSHAoYU0FNUExFX0VWRU5UX1RZUEVfQVNDRU'
    '5UEAQSHQoZU0FNUExFX0VWRU5UX1RZUEVfQ0VJTElORxAFEh4KGlNBTVBMRV9FVkVOVF9UWVBF'
    'X1dPUktMT0FEEAYSIQodU0FNUExFX0VWRU5UX1RZUEVfVFJBTlNNSVRURVIQBxIfChtTQU1QTE'
    'VfRVZFTlRfVFlQRV9WSU9MQVRJT04QCBIeChpTQU1QTEVfRVZFTlRfVFlQRV9CT09LTUFSSxAJ'
    'Eh0KGVNBTVBMRV9FVkVOVF9UWVBFX1NVUkZBQ0UQChIhCh1TQU1QTEVfRVZFTlRfVFlQRV9TQU'
    'ZFVFlfU1RPUBALEiAKHFNBTVBMRV9FVkVOVF9UWVBFX0dBU19DSEFOR0UQDBIrCidTQU1QTEVf'
    'RVZFTlRfVFlQRV9TQUZFVFlfU1RPUF9WT0xVTlRBUlkQDRIrCidTQU1QTEVfRVZFTlRfVFlQRV'
    '9TQUZFVFlfU1RPUF9NQU5EQVRPUlkQDhIfChtTQU1QTEVfRVZFTlRfVFlQRV9ERUVQX1NUT1AQ'
    'DxIpCiVTQU1QTEVfRVZFTlRfVFlQRV9DRUlMSU5HX1NBRkVUWV9TVE9QEBASGwoXU0FNUExFX0'
    'VWRU5UX1RZUEVfRkxPT1IQERIfChtTQU1QTEVfRVZFTlRfVFlQRV9ESVZFX1RJTUUQEhIfChtT'
    'QU1QTEVfRVZFTlRfVFlQRV9NQVhfREVQVEgQExIZChVTQU1QTEVfRVZFTlRfVFlQRV9PTEYQFB'
    'IZChVTQU1QTEVfRVZFTlRfVFlQRV9QTzIQFRIeChpTQU1QTEVfRVZFTlRfVFlQRV9BSVJfVElN'
    'RRAWEhoKFlNBTVBMRV9FVkVOVF9UWVBFX1JHQk0QFxIdChlTQU1QTEVfRVZFTlRfVFlQRV9IRU'
    'FESU5HEBgSIgoeU0FNUExFX0VWRU5UX1RZUEVfVElTU1VFX0xFVkVMEBkSIgoeU0FNUExFX0VW'
    'RU5UX1RZUEVfR0FTX0NIQU5HRV8yEBo=');

@$core.Deprecated('Use logDescriptor instead')
const Log$json = {
  '1': 'Log',
  '2': [
    {'1': 'model', '3': 1, '4': 1, '5': 9, '10': 'model'},
    {'1': 'serial', '3': 2, '4': 1, '5': 9, '10': 'serial'},
    {
      '1': 'date_time',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'dateTime'
    },
    {'1': 'dive_time', '3': 4, '4': 1, '5': 5, '10': 'diveTime'},
    {'1': 'max_depth', '3': 5, '4': 1, '5': 1, '10': 'maxDepth'},
    {'1': 'avg_depth', '3': 6, '4': 1, '5': 1, '10': 'avgDepth'},
    {
      '1': 'surface_temperature',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'surfaceTemperature'
    },
    {'1': 'min_temperature', '3': 8, '4': 1, '5': 1, '10': 'minTemperature'},
    {'1': 'max_temperature', '3': 9, '4': 1, '5': 1, '10': 'maxTemperature'},
    {
      '1': 'salinity',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.divestore.Salinity',
      '10': 'salinity'
    },
    {
      '1': 'atmospheric_pressure',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'atmosphericPressure'
    },
    {
      '1': 'dive_mode',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.divestore.DiveMode',
      '10': 'diveMode'
    },
    {
      '1': 'deco_model',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.divestore.DecoModel',
      '10': 'decoModel'
    },
    {
      '1': 'position',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.divestore.Position',
      '10': 'position'
    },
    {
      '1': 'gas_mixes',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.divestore.GasMix',
      '10': 'gasMixes'
    },
    {
      '1': 'tanks',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.divestore.Tank',
      '10': 'tanks'
    },
    {
      '1': 'samples',
      '3': 17,
      '4': 3,
      '5': 11,
      '6': '.divestore.LogSample',
      '10': 'samples'
    },
    {'1': 'ldc_fingerprint', '3': 18, '4': 1, '5': 12, '10': 'ldcFingerprint'},
    {'1': 'uniqueID', '3': 19, '4': 1, '5': 9, '10': 'uniqueID'},
  ],
};

/// Descriptor for `Log`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logDescriptor = $convert.base64Decode(
    'CgNMb2cSFAoFbW9kZWwYASABKAlSBW1vZGVsEhYKBnNlcmlhbBgCIAEoCVIGc2VyaWFsEjcKCW'
    'RhdGVfdGltZRgDIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCGRhdGVUaW1lEhsK'
    'CWRpdmVfdGltZRgEIAEoBVIIZGl2ZVRpbWUSGwoJbWF4X2RlcHRoGAUgASgBUghtYXhEZXB0aB'
    'IbCglhdmdfZGVwdGgYBiABKAFSCGF2Z0RlcHRoEi8KE3N1cmZhY2VfdGVtcGVyYXR1cmUYByAB'
    'KAFSEnN1cmZhY2VUZW1wZXJhdHVyZRInCg9taW5fdGVtcGVyYXR1cmUYCCABKAFSDm1pblRlbX'
    'BlcmF0dXJlEicKD21heF90ZW1wZXJhdHVyZRgJIAEoAVIObWF4VGVtcGVyYXR1cmUSLwoIc2Fs'
    'aW5pdHkYCiABKAsyEy5kaXZlc3RvcmUuU2FsaW5pdHlSCHNhbGluaXR5EjEKFGF0bW9zcGhlcm'
    'ljX3ByZXNzdXJlGAsgASgBUhNhdG1vc3BoZXJpY1ByZXNzdXJlEjAKCWRpdmVfbW9kZRgMIAEo'
    'DjITLmRpdmVzdG9yZS5EaXZlTW9kZVIIZGl2ZU1vZGUSMwoKZGVjb19tb2RlbBgNIAEoCzIULm'
    'RpdmVzdG9yZS5EZWNvTW9kZWxSCWRlY29Nb2RlbBIvCghwb3NpdGlvbhgOIAEoCzITLmRpdmVz'
    'dG9yZS5Qb3NpdGlvblIIcG9zaXRpb24SLgoJZ2FzX21peGVzGA8gAygLMhEuZGl2ZXN0b3JlLk'
    'dhc01peFIIZ2FzTWl4ZXMSJQoFdGFua3MYECADKAsyDy5kaXZlc3RvcmUuVGFua1IFdGFua3MS'
    'LgoHc2FtcGxlcxgRIAMoCzIULmRpdmVzdG9yZS5Mb2dTYW1wbGVSB3NhbXBsZXMSJwoPbGRjX2'
    'ZpbmdlcnByaW50GBIgASgMUg5sZGNGaW5nZXJwcmludBIaCgh1bmlxdWVJRBgTIAEoCVIIdW5p'
    'cXVlSUQ=');

@$core.Deprecated('Use logSampleDescriptor instead')
const LogSample$json = {
  '1': 'LogSample',
  '2': [
    {'1': 'time', '3': 1, '4': 1, '5': 1, '10': 'time'},
    {'1': 'depth', '3': 2, '4': 1, '5': 1, '10': 'depth'},
    {'1': 'temperature', '3': 3, '4': 1, '5': 1, '10': 'temperature'},
    {
      '1': 'pressures',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.divestore.TankPressure',
      '10': 'pressures'
    },
    {
      '1': 'events',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.divestore.SampleEvent',
      '10': 'events'
    },
    {'1': 'rbt', '3': 6, '4': 1, '5': 5, '10': 'rbt'},
    {'1': 'heartbeat', '3': 7, '4': 1, '5': 5, '10': 'heartbeat'},
    {'1': 'bearing', '3': 8, '4': 1, '5': 5, '10': 'bearing'},
    {'1': 'setpoint', '3': 9, '4': 1, '5': 1, '10': 'setpoint'},
    {
      '1': 'ppo2',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.divestore.Ppo2Reading',
      '10': 'ppo2'
    },
    {'1': 'cns', '3': 11, '4': 1, '5': 1, '10': 'cns'},
    {
      '1': 'deco',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.divestore.DecoStatus',
      '10': 'deco'
    },
    {'1': 'gas_mix_index', '3': 13, '4': 1, '5': 5, '10': 'gasMixIndex'},
    {
      '1': 'vendor_data',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.divestore.VendorData',
      '10': 'vendorData'
    },
  ],
};

/// Descriptor for `LogSample`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logSampleDescriptor = $convert.base64Decode(
    'CglMb2dTYW1wbGUSEgoEdGltZRgBIAEoAVIEdGltZRIUCgVkZXB0aBgCIAEoAVIFZGVwdGgSIA'
    'oLdGVtcGVyYXR1cmUYAyABKAFSC3RlbXBlcmF0dXJlEjUKCXByZXNzdXJlcxgEIAMoCzIXLmRp'
    'dmVzdG9yZS5UYW5rUHJlc3N1cmVSCXByZXNzdXJlcxIuCgZldmVudHMYBSADKAsyFi5kaXZlc3'
    'RvcmUuU2FtcGxlRXZlbnRSBmV2ZW50cxIQCgNyYnQYBiABKAVSA3JidBIcCgloZWFydGJlYXQY'
    'ByABKAVSCWhlYXJ0YmVhdBIYCgdiZWFyaW5nGAggASgFUgdiZWFyaW5nEhoKCHNldHBvaW50GA'
    'kgASgBUghzZXRwb2ludBIqCgRwcG8yGAogAygLMhYuZGl2ZXN0b3JlLlBwbzJSZWFkaW5nUgRw'
    'cG8yEhAKA2NucxgLIAEoAVIDY25zEikKBGRlY28YDCABKAsyFS5kaXZlc3RvcmUuRGVjb1N0YX'
    'R1c1IEZGVjbxIiCg1nYXNfbWl4X2luZGV4GA0gASgFUgtnYXNNaXhJbmRleBI2Cgt2ZW5kb3Jf'
    'ZGF0YRgOIAMoCzIVLmRpdmVzdG9yZS5WZW5kb3JEYXRhUgp2ZW5kb3JEYXRh');

@$core.Deprecated('Use salinityDescriptor instead')
const Salinity$json = {
  '1': 'Salinity',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.divestore.WaterType',
      '10': 'type'
    },
    {'1': 'density', '3': 2, '4': 1, '5': 1, '10': 'density'},
  ],
};

/// Descriptor for `Salinity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List salinityDescriptor = $convert.base64Decode(
    'CghTYWxpbml0eRIoCgR0eXBlGAEgASgOMhQuZGl2ZXN0b3JlLldhdGVyVHlwZVIEdHlwZRIYCg'
    'dkZW5zaXR5GAIgASgBUgdkZW5zaXR5');

@$core.Deprecated('Use gasMixDescriptor instead')
const GasMix$json = {
  '1': 'GasMix',
  '2': [
    {'1': 'oxygen', '3': 1, '4': 1, '5': 1, '10': 'oxygen'},
    {'1': 'helium', '3': 2, '4': 1, '5': 1, '10': 'helium'},
    {'1': 'nitrogen', '3': 3, '4': 1, '5': 1, '10': 'nitrogen'},
    {
      '1': 'usage',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.divestore.GasUsage',
      '10': 'usage'
    },
  ],
};

/// Descriptor for `GasMix`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gasMixDescriptor = $convert.base64Decode(
    'CgZHYXNNaXgSFgoGb3h5Z2VuGAEgASgBUgZveHlnZW4SFgoGaGVsaXVtGAIgASgBUgZoZWxpdW'
    '0SGgoIbml0cm9nZW4YAyABKAFSCG5pdHJvZ2VuEikKBXVzYWdlGAQgASgOMhMuZGl2ZXN0b3Jl'
    'Lkdhc1VzYWdlUgV1c2FnZQ==');

@$core.Deprecated('Use tankDescriptor instead')
const Tank$json = {
  '1': 'Tank',
  '2': [
    {'1': 'gas_mix_index', '3': 1, '4': 1, '5': 5, '10': 'gasMixIndex'},
    {
      '1': 'volume_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.divestore.TankVolumeType',
      '10': 'volumeType'
    },
    {'1': 'volume', '3': 3, '4': 1, '5': 1, '10': 'volume'},
    {'1': 'work_pressure', '3': 4, '4': 1, '5': 1, '10': 'workPressure'},
    {'1': 'begin_pressure', '3': 5, '4': 1, '5': 1, '10': 'beginPressure'},
    {'1': 'end_pressure', '3': 6, '4': 1, '5': 1, '10': 'endPressure'},
    {
      '1': 'usage',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.divestore.GasUsage',
      '10': 'usage'
    },
  ],
};

/// Descriptor for `Tank`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tankDescriptor = $convert.base64Decode(
    'CgRUYW5rEiIKDWdhc19taXhfaW5kZXgYASABKAVSC2dhc01peEluZGV4EjoKC3ZvbHVtZV90eX'
    'BlGAIgASgOMhkuZGl2ZXN0b3JlLlRhbmtWb2x1bWVUeXBlUgp2b2x1bWVUeXBlEhYKBnZvbHVt'
    'ZRgDIAEoAVIGdm9sdW1lEiMKDXdvcmtfcHJlc3N1cmUYBCABKAFSDHdvcmtQcmVzc3VyZRIlCg'
    '5iZWdpbl9wcmVzc3VyZRgFIAEoAVINYmVnaW5QcmVzc3VyZRIhCgxlbmRfcHJlc3N1cmUYBiAB'
    'KAFSC2VuZFByZXNzdXJlEikKBXVzYWdlGAcgASgOMhMuZGl2ZXN0b3JlLkdhc1VzYWdlUgV1c2'
    'FnZQ==');

@$core.Deprecated('Use decoModelDescriptor instead')
const DecoModel$json = {
  '1': 'DecoModel',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.divestore.DecoModelType',
      '10': 'type'
    },
    {'1': 'conservatism', '3': 2, '4': 1, '5': 5, '10': 'conservatism'},
    {'1': 'gf_low', '3': 3, '4': 1, '5': 5, '10': 'gfLow'},
    {'1': 'gf_high', '3': 4, '4': 1, '5': 5, '10': 'gfHigh'},
  ],
};

/// Descriptor for `DecoModel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decoModelDescriptor = $convert.base64Decode(
    'CglEZWNvTW9kZWwSLAoEdHlwZRgBIAEoDjIYLmRpdmVzdG9yZS5EZWNvTW9kZWxUeXBlUgR0eX'
    'BlEiIKDGNvbnNlcnZhdGlzbRgCIAEoBVIMY29uc2VydmF0aXNtEhUKBmdmX2xvdxgDIAEoBVIF'
    'Z2ZMb3cSFwoHZ2ZfaGlnaBgEIAEoBVIGZ2ZIaWdo');

@$core.Deprecated('Use tankPressureDescriptor instead')
const TankPressure$json = {
  '1': 'TankPressure',
  '2': [
    {'1': 'tank_index', '3': 1, '4': 1, '5': 5, '10': 'tankIndex'},
    {'1': 'pressure', '3': 2, '4': 1, '5': 1, '10': 'pressure'},
  ],
};

/// Descriptor for `TankPressure`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tankPressureDescriptor = $convert.base64Decode(
    'CgxUYW5rUHJlc3N1cmUSHQoKdGFua19pbmRleBgBIAEoBVIJdGFua0luZGV4EhoKCHByZXNzdX'
    'JlGAIgASgBUghwcmVzc3VyZQ==');

@$core.Deprecated('Use ppo2ReadingDescriptor instead')
const Ppo2Reading$json = {
  '1': 'Ppo2Reading',
  '2': [
    {'1': 'sensor_index', '3': 1, '4': 1, '5': 5, '10': 'sensorIndex'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
};

/// Descriptor for `Ppo2Reading`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ppo2ReadingDescriptor = $convert.base64Decode(
    'CgtQcG8yUmVhZGluZxIhCgxzZW5zb3JfaW5kZXgYASABKAVSC3NlbnNvckluZGV4EhQKBXZhbH'
    'VlGAIgASgBUgV2YWx1ZQ==');

@$core.Deprecated('Use decoStatusDescriptor instead')
const DecoStatus$json = {
  '1': 'DecoStatus',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.divestore.DecoStopType',
      '10': 'type'
    },
    {'1': 'time', '3': 2, '4': 1, '5': 5, '10': 'time'},
    {'1': 'depth', '3': 3, '4': 1, '5': 1, '10': 'depth'},
    {'1': 'tts', '3': 4, '4': 1, '5': 5, '10': 'tts'},
  ],
};

/// Descriptor for `DecoStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decoStatusDescriptor = $convert.base64Decode(
    'CgpEZWNvU3RhdHVzEisKBHR5cGUYASABKA4yFy5kaXZlc3RvcmUuRGVjb1N0b3BUeXBlUgR0eX'
    'BlEhIKBHRpbWUYAiABKAVSBHRpbWUSFAoFZGVwdGgYAyABKAFSBWRlcHRoEhAKA3R0cxgEIAEo'
    'BVIDdHRz');

@$core.Deprecated('Use sampleEventDescriptor instead')
const SampleEvent$json = {
  '1': 'SampleEvent',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.divestore.SampleEventType',
      '10': 'type'
    },
    {'1': 'time', '3': 2, '4': 1, '5': 5, '10': 'time'},
    {'1': 'flags', '3': 3, '4': 1, '5': 13, '10': 'flags'},
    {'1': 'value', '3': 4, '4': 1, '5': 5, '10': 'value'},
  ],
};

/// Descriptor for `SampleEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sampleEventDescriptor = $convert.base64Decode(
    'CgtTYW1wbGVFdmVudBIuCgR0eXBlGAEgASgOMhouZGl2ZXN0b3JlLlNhbXBsZUV2ZW50VHlwZV'
    'IEdHlwZRISCgR0aW1lGAIgASgFUgR0aW1lEhQKBWZsYWdzGAMgASgNUgVmbGFncxIUCgV2YWx1'
    'ZRgEIAEoBVIFdmFsdWU=');

@$core.Deprecated('Use vendorDataDescriptor instead')
const VendorData$json = {
  '1': 'VendorData',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `VendorData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vendorDataDescriptor = $convert.base64Decode(
    'CgpWZW5kb3JEYXRhEhIKBHR5cGUYASABKAVSBHR5cGUSEgoEZGF0YRgCIAEoDFIEZGF0YQ==');
