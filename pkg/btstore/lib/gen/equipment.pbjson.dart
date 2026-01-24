// This is a generated file - do not edit.
//
// Generated from equipment.proto.

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

@$core.Deprecated('Use equipmentDescriptor instead')
const Equipment$json = {
  '1': 'Equipment',
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
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
    {'1': 'manufacturer', '3': 4, '4': 1, '5': 9, '10': 'manufacturer'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'serial', '3': 6, '4': 1, '5': 9, '10': 'serial'},
    {
      '1': 'purchase_date',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'purchaseDate'
    },
    {'1': 'purchase_price', '3': 8, '4': 1, '5': 1, '10': 'purchasePrice'},
    {'1': 'weight', '3': 9, '4': 1, '5': 1, '10': 'weight'},
    {
      '1': 'next_service',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'nextService'
    },
  ],
};

/// Descriptor for `Equipment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List equipmentDescriptor = $convert.base64Decode(
    'CglFcXVpcG1lbnQSDgoCaWQYASABKAlSAmlkEiUKBG1ldGEYAiABKAsyES5idHN0b3JlLk1ldG'
    'FkYXRhUgRtZXRhEhIKBHR5cGUYAyABKAlSBHR5cGUSIgoMbWFudWZhY3R1cmVyGAQgASgJUgxt'
    'YW51ZmFjdHVyZXISEgoEbmFtZRgFIAEoCVIEbmFtZRIWCgZzZXJpYWwYBiABKAlSBnNlcmlhbB'
    'I/Cg1wdXJjaGFzZV9kYXRlGAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIMcHVy'
    'Y2hhc2VEYXRlEiUKDnB1cmNoYXNlX3ByaWNlGAggASgBUg1wdXJjaGFzZVByaWNlEhYKBndlaW'
    'dodBgJIAEoAVIGd2VpZ2h0Ej0KDG5leHRfc2VydmljZRgKIAEoCzIaLmdvb2dsZS5wcm90b2J1'
    'Zi5UaW1lc3RhbXBSC25leHRTZXJ2aWNl');
