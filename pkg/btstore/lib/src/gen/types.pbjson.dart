// This is a generated file - do not edit.
//
// Generated from types.proto.

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

@$core.Deprecated('Use positionDescriptor instead')
const Position$json = {
  '1': 'Position',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'altitude', '3': 3, '4': 1, '5': 1, '10': 'altitude'},
  ],
};

/// Descriptor for `Position`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionDescriptor = $convert.base64Decode(
    'CghQb3NpdGlvbhIaCghsYXRpdHVkZRgBIAEoAVIIbGF0aXR1ZGUSHAoJbG9uZ2l0dWRlGAIgAS'
    'gBUglsb25naXR1ZGUSGgoIYWx0aXR1ZGUYAyABKAFSCGFsdGl0dWRl');

@$core.Deprecated('Use metadataDescriptor instead')
const Metadata$json = {
  '1': 'Metadata',
  '2': [
    {
      '1': 'created_at',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'deleted_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'deletedAt'
    },
  ],
};

/// Descriptor for `Metadata`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List metadataDescriptor = $convert.base64Decode(
    'CghNZXRhZGF0YRI5CgpjcmVhdGVkX2F0GAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdG'
    'FtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGlt'
    'ZXN0YW1wUgl1cGRhdGVkQXQSOQoKZGVsZXRlZF9hdBgDIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi'
    '5UaW1lc3RhbXBSCWRlbGV0ZWRBdA==');

@$core.Deprecated('Use tissuesDescriptor instead')
const Tissues$json = {
  '1': 'Tissues',
  '2': [
    {'1': 'n2_pressures', '3': 1, '4': 3, '5': 1, '10': 'n2Pressures'},
    {'1': 'he_pressures', '3': 2, '4': 3, '5': 1, '10': 'hePressures'},
    {
      '1': 'timestamp',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'chain_id', '3': 4, '4': 1, '5': 9, '10': 'chainId'},
    {'1': 'generation', '3': 5, '4': 1, '5': 5, '10': 'generation'},
  ],
};

/// Descriptor for `Tissues`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tissuesDescriptor = $convert.base64Decode(
    'CgdUaXNzdWVzEiEKDG4yX3ByZXNzdXJlcxgBIAMoAVILbjJQcmVzc3VyZXMSIQoMaGVfcHJlc3'
    'N1cmVzGAIgAygBUgtoZVByZXNzdXJlcxI4Cgl0aW1lc3RhbXAYAyABKAsyGi5nb29nbGUucHJv'
    'dG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASGQoIY2hhaW5faWQYBCABKAlSB2NoYWluSWQSHg'
    'oKZ2VuZXJhdGlvbhgFIAEoBVIKZ2VuZXJhdGlvbg==');

@$core.Deprecated('Use cylinderDescriptor instead')
const Cylinder$json = {
  '1': 'Cylinder',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'meta',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.btstore.Metadata',
      '10': 'meta'
    },
    {'1': 'volume_l', '3': 3, '4': 1, '5': 1, '10': 'volumeL'},
    {
      '1': 'working_pressure_bar',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'workingPressureBar'
    },
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'volume_cuft', '3': 6, '4': 1, '5': 1, '10': 'volumeCuft'},
    {
      '1': 'working_pressure_psi',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'workingPressurePsi'
    },
    {
      '1': 'default_for_backgas',
      '3': 8,
      '4': 1,
      '5': 8,
      '10': 'defaultForBackgas'
    },
    {
      '1': 'default_for_deep_deco',
      '3': 9,
      '4': 1,
      '5': 8,
      '10': 'defaultForDeepDeco'
    },
    {
      '1': 'default_for_shallow_deco',
      '3': 10,
      '4': 1,
      '5': 8,
      '10': 'defaultForShallowDeco'
    },
  ],
};

/// Descriptor for `Cylinder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cylinderDescriptor = $convert.base64Decode(
    'CghDeWxpbmRlchIOCgJpZBgBIAEoCVICaWQSJQoEbWV0YRgCIAEoCzIRLmJ0c3RvcmUuTWV0YW'
    'RhdGFSBG1ldGESGQoIdm9sdW1lX2wYAyABKAFSB3ZvbHVtZUwSMAoUd29ya2luZ19wcmVzc3Vy'
    'ZV9iYXIYBCABKAFSEndvcmtpbmdQcmVzc3VyZUJhchIgCgtkZXNjcmlwdGlvbhgFIAEoCVILZG'
    'VzY3JpcHRpb24SHwoLdm9sdW1lX2N1ZnQYBiABKAFSCnZvbHVtZUN1ZnQSMAoUd29ya2luZ19w'
    'cmVzc3VyZV9wc2kYByABKAFSEndvcmtpbmdQcmVzc3VyZVBzaRIuChNkZWZhdWx0X2Zvcl9iYW'
    'NrZ2FzGAggASgIUhFkZWZhdWx0Rm9yQmFja2dhcxIxChVkZWZhdWx0X2Zvcl9kZWVwX2RlY28Y'
    'CSABKAhSEmRlZmF1bHRGb3JEZWVwRGVjbxI3ChhkZWZhdWx0X2Zvcl9zaGFsbG93X2RlY28YCi'
    'ABKAhSFWRlZmF1bHRGb3JTaGFsbG93RGVjbw==');
