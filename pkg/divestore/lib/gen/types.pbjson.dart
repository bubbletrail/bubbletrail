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

@$core.Deprecated('Use cylinderDescriptor instead')
const Cylinder$json = {
  '1': 'Cylinder',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'created_at', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'deletedAt'},
    {'1': 'size', '3': 5, '4': 1, '5': 1, '10': 'size'},
    {'1': 'workpressure', '3': 6, '4': 1, '5': 1, '10': 'workpressure'},
    {'1': 'description', '3': 7, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `Cylinder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cylinderDescriptor = $convert.base64Decode('CghDeWxpbmRlchIOCgJpZBgBIAEoCVICaWQSOQoKY3JlYXRlZF9hdBgCIAEoCzIaLmdvb2dsZS'
    '5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GAMgASgLMhouZ29v'
    'Z2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0EjkKCmRlbGV0ZWRfYXQYBCABKAsyGi'
    '5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglkZWxldGVkQXQSEgoEc2l6ZRgFIAEoAVIEc2l6'
    'ZRIiCgx3b3JrcHJlc3N1cmUYBiABKAFSDHdvcmtwcmVzc3VyZRIgCgtkZXNjcmlwdGlvbhgHIA'
    'EoCVILZGVzY3JpcHRpb24=');
