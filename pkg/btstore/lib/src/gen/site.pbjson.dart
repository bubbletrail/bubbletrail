// This is a generated file - do not edit.
//
// Generated from site.proto.

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

@$core.Deprecated('Use siteDescriptor instead')
const Site$json = {
  '1': 'Site',
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
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'position',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.btstore.Position',
      '10': 'position'
    },
    {'1': 'country', '3': 5, '4': 1, '5': 9, '10': 'country'},
    {'1': 'location', '3': 6, '4': 1, '5': 9, '10': 'location'},
    {'1': 'body_of_water', '3': 7, '4': 1, '5': 9, '10': 'bodyOfWater'},
    {'1': 'difficulty', '3': 8, '4': 1, '5': 9, '10': 'difficulty'},
    {'1': 'tags', '3': 9, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'notes', '3': 10, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `Site`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List siteDescriptor = $convert.base64Decode(
    'CgRTaXRlEg4KAmlkGAEgASgJUgJpZBIlCgRtZXRhGAIgASgLMhEuYnRzdG9yZS5NZXRhZGF0YV'
    'IEbWV0YRISCgRuYW1lGAMgASgJUgRuYW1lEi0KCHBvc2l0aW9uGAQgASgLMhEuYnRzdG9yZS5Q'
    'b3NpdGlvblIIcG9zaXRpb24SGAoHY291bnRyeRgFIAEoCVIHY291bnRyeRIaCghsb2NhdGlvbh'
    'gGIAEoCVIIbG9jYXRpb24SIgoNYm9keV9vZl93YXRlchgHIAEoCVILYm9keU9mV2F0ZXISHgoK'
    'ZGlmZmljdWx0eRgIIAEoCVIKZGlmZmljdWx0eRISCgR0YWdzGAkgAygJUgR0YWdzEhQKBW5vdG'
    'VzGAogASgJUgVub3Rlcw==');
