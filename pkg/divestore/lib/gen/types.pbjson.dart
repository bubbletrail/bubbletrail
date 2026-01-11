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

@$core.Deprecated('Use cylinderDescriptor instead')
const Cylinder$json = {
  '1': 'Cylinder',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'created_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'deleted_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'deletedAt'
    },
    {'1': 'volume_l', '3': 5, '4': 1, '5': 1, '10': 'volumeL'},
    {
      '1': 'working_pressure_bar',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'workingPressureBar'
    },
    {'1': 'description', '3': 7, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'volume_cuft',
      '3': 8,
      '4': 1,
      '5': 1,
      '9': 0,
      '10': 'volumeCuft',
      '17': true
    },
    {
      '1': 'working_pressure_psi',
      '3': 9,
      '4': 1,
      '5': 1,
      '9': 1,
      '10': 'workingPressurePsi',
      '17': true
    },
  ],
  '8': [
    {'1': '_volume_cuft'},
    {'1': '_working_pressure_psi'},
  ],
};

/// Descriptor for `Cylinder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cylinderDescriptor = $convert.base64Decode(
    'CghDeWxpbmRlchIOCgJpZBgBIAEoCVICaWQSOQoKY3JlYXRlZF9hdBgCIAEoCzIaLmdvb2dsZS'
    '5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GAMgASgLMhouZ29v'
    'Z2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0EjkKCmRlbGV0ZWRfYXQYBCABKAsyGi'
    '5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglkZWxldGVkQXQSGQoIdm9sdW1lX2wYBSABKAFS'
    'B3ZvbHVtZUwSMAoUd29ya2luZ19wcmVzc3VyZV9iYXIYBiABKAFSEndvcmtpbmdQcmVzc3VyZU'
    'JhchIgCgtkZXNjcmlwdGlvbhgHIAEoCVILZGVzY3JpcHRpb24SJAoLdm9sdW1lX2N1ZnQYCCAB'
    'KAFIAFIKdm9sdW1lQ3VmdIgBARI1ChR3b3JraW5nX3ByZXNzdXJlX3BzaRgJIAEoAUgBUhJ3b3'
    'JraW5nUHJlc3N1cmVQc2mIAQFCDgoMX3ZvbHVtZV9jdWZ0QhcKFV93b3JraW5nX3ByZXNzdXJl'
    'X3BzaQ==');
