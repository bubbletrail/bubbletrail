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
final $typed_data.Uint8List positionDescriptor = $convert.base64Decode('CghQb3NpdGlvbhIaCghsYXRpdHVkZRgBIAEoAVIIbGF0aXR1ZGUSHAoJbG9uZ2l0dWRlGAIgAS'
    'gBUglsb25naXR1ZGUSGgoIYWx0aXR1ZGUYAyABKAFSCGFsdGl0dWRl');

@$core.Deprecated('Use metadataDescriptor instead')
const Metadata$json = {
  '1': 'Metadata',
  '2': [
    {'1': 'created_at', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'deletedAt'},
  ],
};

/// Descriptor for `Metadata`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List metadataDescriptor = $convert.base64Decode('CghNZXRhZGF0YRI5CgpjcmVhdGVkX2F0GAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdG'
    'FtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGlt'
    'ZXN0YW1wUgl1cGRhdGVkQXQSOQoKZGVsZXRlZF9hdBgDIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi'
    '5UaW1lc3RhbXBSCWRlbGV0ZWRBdA==');

@$core.Deprecated('Use tissuesDescriptor instead')
const Tissues$json = {
  '1': 'Tissues',
  '2': [
    {'1': 'n2_pressures', '3': 1, '4': 3, '5': 1, '10': 'n2Pressures'},
    {'1': 'he_pressures', '3': 2, '4': 3, '5': 1, '10': 'hePressures'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timestamp'},
    {'1': 'chain_id', '3': 4, '4': 1, '5': 9, '10': 'chainId'},
    {'1': 'generation', '3': 5, '4': 1, '5': 5, '10': 'generation'},
  ],
};

/// Descriptor for `Tissues`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tissuesDescriptor = $convert.base64Decode('CgdUaXNzdWVzEiEKDG4yX3ByZXNzdXJlcxgBIAMoAVILbjJQcmVzc3VyZXMSIQoMaGVfcHJlc3'
    'N1cmVzGAIgAygBUgtoZVByZXNzdXJlcxI4Cgl0aW1lc3RhbXAYAyABKAsyGi5nb29nbGUucHJv'
    'dG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASGQoIY2hhaW5faWQYBCABKAlSB2NoYWluSWQSHg'
    'oKZ2VuZXJhdGlvbhgFIAEoBVIKZ2VuZXJhdGlvbg==');

@$core.Deprecated('Use cylinderDescriptor instead')
const Cylinder$json = {
  '1': 'Cylinder',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'meta', '3': 2, '4': 1, '5': 11, '6': '.btstore.Metadata', '10': 'meta'},
    {'1': 'volume_l', '3': 3, '4': 1, '5': 1, '10': 'volumeL'},
    {'1': 'working_pressure_bar', '3': 4, '4': 1, '5': 1, '10': 'workingPressureBar'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'volume_cuft', '3': 6, '4': 1, '5': 1, '9': 0, '10': 'volumeCuft', '17': true},
    {'1': 'working_pressure_psi', '3': 7, '4': 1, '5': 1, '9': 1, '10': 'workingPressurePsi', '17': true},
  ],
  '8': [
    {'1': '_volume_cuft'},
    {'1': '_working_pressure_psi'},
  ],
};

/// Descriptor for `Cylinder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cylinderDescriptor = $convert.base64Decode('CghDeWxpbmRlchIOCgJpZBgBIAEoCVICaWQSJwoEbWV0YRgCIAEoCzITLmRpdmVzdG9yZS5NZX'
    'RhZGF0YVIEbWV0YRIZCgh2b2x1bWVfbBgDIAEoAVIHdm9sdW1lTBIwChR3b3JraW5nX3ByZXNz'
    'dXJlX2JhchgEIAEoAVISd29ya2luZ1ByZXNzdXJlQmFyEiAKC2Rlc2NyaXB0aW9uGAUgASgJUg'
    'tkZXNjcmlwdGlvbhIkCgt2b2x1bWVfY3VmdBgGIAEoAUgAUgp2b2x1bWVDdWZ0iAEBEjUKFHdv'
    'cmtpbmdfcHJlc3N1cmVfcHNpGAcgASgBSAFSEndvcmtpbmdQcmVzc3VyZVBzaYgBAUIOCgxfdm'
    '9sdW1lX2N1ZnRCFwoVX3dvcmtpbmdfcHJlc3N1cmVfcHNp');
