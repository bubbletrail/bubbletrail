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
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'position',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.divestore.Position',
      '10': 'position'
    },
    {'1': 'country', '3': 7, '4': 1, '5': 9, '10': 'country'},
    {'1': 'location', '3': 8, '4': 1, '5': 9, '10': 'location'},
    {'1': 'body_of_water', '3': 9, '4': 1, '5': 9, '10': 'bodyOfWater'},
    {'1': 'difficulty', '3': 10, '4': 1, '5': 9, '10': 'difficulty'},
    {'1': 'tags', '3': 11, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `Site`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List siteDescriptor = $convert.base64Decode(
    'CgRTaXRlEg4KAmlkGAEgASgJUgJpZBI5CgpjcmVhdGVkX2F0GAIgASgLMhouZ29vZ2xlLnByb3'
    'RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYAyABKAsyGi5nb29nbGUu'
    'cHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQSOQoKZGVsZXRlZF9hdBgEIAEoCzIaLmdvb2'
    'dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWRlbGV0ZWRBdBISCgRuYW1lGAUgASgJUgRuYW1lEi8K'
    'CHBvc2l0aW9uGAYgASgLMhMuZGl2ZXN0b3JlLlBvc2l0aW9uUghwb3NpdGlvbhIYCgdjb3VudH'
    'J5GAcgASgJUgdjb3VudHJ5EhoKCGxvY2F0aW9uGAggASgJUghsb2NhdGlvbhIiCg1ib2R5X29m'
    'X3dhdGVyGAkgASgJUgtib2R5T2ZXYXRlchIeCgpkaWZmaWN1bHR5GAogASgJUgpkaWZmaWN1bH'
    'R5EhIKBHRhZ3MYCyADKAlSBHRhZ3M=');
