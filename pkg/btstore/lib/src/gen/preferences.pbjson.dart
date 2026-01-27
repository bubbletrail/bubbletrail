// This is a generated file - do not edit.
//
// Generated from preferences.proto.

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

@$core.Deprecated('Use depthUnitDescriptor instead')
const DepthUnit$json = {
  '1': 'DepthUnit',
  '2': [
    {'1': 'DEPTH_UNIT_METERS', '2': 0},
    {'1': 'DEPTH_UNIT_FEET', '2': 1},
  ],
};

/// Descriptor for `DepthUnit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List depthUnitDescriptor = $convert.base64Decode(
    'CglEZXB0aFVuaXQSFQoRREVQVEhfVU5JVF9NRVRFUlMQABITCg9ERVBUSF9VTklUX0ZFRVQQAQ'
    '==');

@$core.Deprecated('Use pressureUnitDescriptor instead')
const PressureUnit$json = {
  '1': 'PressureUnit',
  '2': [
    {'1': 'PRESSURE_UNIT_BAR', '2': 0},
    {'1': 'PRESSURE_UNIT_PSI', '2': 1},
  ],
};

/// Descriptor for `PressureUnit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List pressureUnitDescriptor = $convert.base64Decode(
    'CgxQcmVzc3VyZVVuaXQSFQoRUFJFU1NVUkVfVU5JVF9CQVIQABIVChFQUkVTU1VSRV9VTklUX1'
    'BTSRAB');

@$core.Deprecated('Use temperatureUnitDescriptor instead')
const TemperatureUnit$json = {
  '1': 'TemperatureUnit',
  '2': [
    {'1': 'TEMPERATURE_UNIT_CELSIUS', '2': 0},
    {'1': 'TEMPERATURE_UNIT_FAHRENHEIT', '2': 1},
  ],
};

/// Descriptor for `TemperatureUnit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List temperatureUnitDescriptor = $convert.base64Decode(
    'Cg9UZW1wZXJhdHVyZVVuaXQSHAoYVEVNUEVSQVRVUkVfVU5JVF9DRUxTSVVTEAASHwobVEVNUE'
    'VSQVRVUkVfVU5JVF9GQUhSRU5IRUlUEAE=');

@$core.Deprecated('Use volumeUnitDescriptor instead')
const VolumeUnit$json = {
  '1': 'VolumeUnit',
  '2': [
    {'1': 'VOLUME_UNIT_LITERS', '2': 0},
    {'1': 'VOLUME_UNIT_CUFT', '2': 1},
  ],
};

/// Descriptor for `VolumeUnit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List volumeUnitDescriptor = $convert.base64Decode(
    'CgpWb2x1bWVVbml0EhYKElZPTFVNRV9VTklUX0xJVEVSUxAAEhQKEFZPTFVNRV9VTklUX0NVRl'
    'QQAQ==');

@$core.Deprecated('Use weightUnitDescriptor instead')
const WeightUnit$json = {
  '1': 'WeightUnit',
  '2': [
    {'1': 'WEIGHT_UNIT_KG', '2': 0},
    {'1': 'WEIGHT_UNIT_LB', '2': 1},
  ],
};

/// Descriptor for `WeightUnit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List weightUnitDescriptor = $convert.base64Decode(
    'CgpXZWlnaHRVbml0EhIKDldFSUdIVF9VTklUX0tHEAASEgoOV0VJR0hUX1VOSVRfTEIQAQ==');

@$core.Deprecated('Use dateFormatPrefDescriptor instead')
const DateFormatPref$json = {
  '1': 'DateFormatPref',
  '2': [
    {'1': 'DATE_FORMAT_ISO', '2': 0},
    {'1': 'DATE_FORMAT_US', '2': 1},
    {'1': 'DATE_FORMAT_EU', '2': 2},
  ],
};

/// Descriptor for `DateFormatPref`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List dateFormatPrefDescriptor = $convert.base64Decode(
    'Cg5EYXRlRm9ybWF0UHJlZhITCg9EQVRFX0ZPUk1BVF9JU08QABISCg5EQVRFX0ZPUk1BVF9VUx'
    'ABEhIKDkRBVEVfRk9STUFUX0VVEAI=');

@$core.Deprecated('Use timeFormatPrefDescriptor instead')
const TimeFormatPref$json = {
  '1': 'TimeFormatPref',
  '2': [
    {'1': 'TIME_FORMAT_H24', '2': 0},
    {'1': 'TIME_FORMAT_H12', '2': 1},
  ],
};

/// Descriptor for `TimeFormatPref`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List timeFormatPrefDescriptor = $convert.base64Decode(
    'Cg5UaW1lRm9ybWF0UHJlZhITCg9USU1FX0ZPUk1BVF9IMjQQABITCg9USU1FX0ZPUk1BVF9IMT'
    'IQAQ==');

@$core.Deprecated('Use themeModePrefDescriptor instead')
const ThemeModePref$json = {
  '1': 'ThemeModePref',
  '2': [
    {'1': 'THEME_MODE_SYSTEM', '2': 0},
    {'1': 'THEME_MODE_LIGHT', '2': 1},
    {'1': 'THEME_MODE_DARK', '2': 2},
  ],
};

/// Descriptor for `ThemeModePref`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List themeModePrefDescriptor = $convert.base64Decode(
    'Cg1UaGVtZU1vZGVQcmVmEhUKEVRIRU1FX01PREVfU1lTVEVNEAASFAoQVEhFTUVfTU9ERV9MSU'
    'dIVBABEhMKD1RIRU1FX01PREVfREFSSxAC');

@$core.Deprecated('Use syncProviderPrefDescriptor instead')
const SyncProviderPref$json = {
  '1': 'SyncProviderPref',
  '2': [
    {'1': 'SYNC_PROVIDER_NONE', '2': 0},
    {'1': 'SYNC_PROVIDER_BUBBLETRAIL', '2': 1},
    {'1': 'SYNC_PROVIDER_S3', '2': 2},
  ],
};

/// Descriptor for `SyncProviderPref`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List syncProviderPrefDescriptor = $convert.base64Decode(
    'ChBTeW5jUHJvdmlkZXJQcmVmEhYKElNZTkNfUFJPVklERVJfTk9ORRAAEh0KGVNZTkNfUFJPVk'
    'lERVJfQlVCQkxFVFJBSUwQARIUChBTWU5DX1BST1ZJREVSX1MzEAI=');

@$core.Deprecated('Use s3ConfigDescriptor instead')
const S3Config$json = {
  '1': 'S3Config',
  '2': [
    {'1': 'endpoint', '3': 1, '4': 1, '5': 9, '10': 'endpoint'},
    {'1': 'bucket', '3': 2, '4': 1, '5': 9, '10': 'bucket'},
    {'1': 'access_key', '3': 3, '4': 1, '5': 9, '10': 'accessKey'},
    {'1': 'secret_key', '3': 4, '4': 1, '5': 9, '10': 'secretKey'},
    {'1': 'region', '3': 5, '4': 1, '5': 9, '10': 'region'},
    {'1': 'vault_key', '3': 6, '4': 1, '5': 9, '10': 'vaultKey'},
  ],
};

/// Descriptor for `S3Config`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List s3ConfigDescriptor = $convert.base64Decode(
    'CghTM0NvbmZpZxIaCghlbmRwb2ludBgBIAEoCVIIZW5kcG9pbnQSFgoGYnVja2V0GAIgASgJUg'
    'ZidWNrZXQSHQoKYWNjZXNzX2tleRgDIAEoCVIJYWNjZXNzS2V5Eh0KCnNlY3JldF9rZXkYBCAB'
    'KAlSCXNlY3JldEtleRIWCgZyZWdpb24YBSABKAlSBnJlZ2lvbhIbCgl2YXVsdF9rZXkYBiABKA'
    'lSCHZhdWx0S2V5');

@$core.Deprecated('Use preferencesDescriptor instead')
const Preferences$json = {
  '1': 'Preferences',
  '2': [
    {
      '1': 'depth_unit',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.btstore.DepthUnit',
      '10': 'depthUnit'
    },
    {
      '1': 'pressure_unit',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.btstore.PressureUnit',
      '10': 'pressureUnit'
    },
    {
      '1': 'temperature_unit',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.btstore.TemperatureUnit',
      '10': 'temperatureUnit'
    },
    {
      '1': 'volume_unit',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.btstore.VolumeUnit',
      '10': 'volumeUnit'
    },
    {
      '1': 'weight_unit',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.btstore.WeightUnit',
      '10': 'weightUnit'
    },
    {
      '1': 'date_format',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.btstore.DateFormatPref',
      '10': 'dateFormat'
    },
    {
      '1': 'time_format',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.btstore.TimeFormatPref',
      '10': 'timeFormat'
    },
    {
      '1': 'theme_mode',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.btstore.ThemeModePref',
      '10': 'themeMode'
    },
    {
      '1': 'sync_provider',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.btstore.SyncProviderPref',
      '10': 'syncProvider'
    },
    {
      '1': 's3_config',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.btstore.S3Config',
      '10': 's3Config'
    },
    {'1': 'gf_low', '3': 11, '4': 1, '5': 1, '7': '0.3', '10': 'gfLow'},
    {'1': 'gf_high', '3': 12, '4': 1, '5': 1, '7': '0.7', '10': 'gfHigh'},
  ],
};

/// Descriptor for `Preferences`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List preferencesDescriptor = $convert.base64Decode(
    'CgtQcmVmZXJlbmNlcxIxCgpkZXB0aF91bml0GAEgASgOMhIuYnRzdG9yZS5EZXB0aFVuaXRSCW'
    'RlcHRoVW5pdBI6Cg1wcmVzc3VyZV91bml0GAIgASgOMhUuYnRzdG9yZS5QcmVzc3VyZVVuaXRS'
    'DHByZXNzdXJlVW5pdBJDChB0ZW1wZXJhdHVyZV91bml0GAMgASgOMhguYnRzdG9yZS5UZW1wZX'
    'JhdHVyZVVuaXRSD3RlbXBlcmF0dXJlVW5pdBI0Cgt2b2x1bWVfdW5pdBgEIAEoDjITLmJ0c3Rv'
    'cmUuVm9sdW1lVW5pdFIKdm9sdW1lVW5pdBI0Cgt3ZWlnaHRfdW5pdBgFIAEoDjITLmJ0c3Rvcm'
    'UuV2VpZ2h0VW5pdFIKd2VpZ2h0VW5pdBI4CgtkYXRlX2Zvcm1hdBgGIAEoDjIXLmJ0c3RvcmUu'
    'RGF0ZUZvcm1hdFByZWZSCmRhdGVGb3JtYXQSOAoLdGltZV9mb3JtYXQYByABKA4yFy5idHN0b3'
    'JlLlRpbWVGb3JtYXRQcmVmUgp0aW1lRm9ybWF0EjUKCnRoZW1lX21vZGUYCCABKA4yFi5idHN0'
    'b3JlLlRoZW1lTW9kZVByZWZSCXRoZW1lTW9kZRI+Cg1zeW5jX3Byb3ZpZGVyGAkgASgOMhkuYn'
    'RzdG9yZS5TeW5jUHJvdmlkZXJQcmVmUgxzeW5jUHJvdmlkZXISLgoJczNfY29uZmlnGAogASgL'
    'MhEuYnRzdG9yZS5TM0NvbmZpZ1IIczNDb25maWcSGgoGZ2ZfbG93GAsgASgBOgMwLjNSBWdmTG'
    '93EhwKB2dmX2hpZ2gYDCABKAE6AzAuN1IGZ2ZIaWdo');
