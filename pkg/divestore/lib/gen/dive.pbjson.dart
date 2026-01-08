// This is a generated file - do not edit.
//
// Generated from dive.proto.

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

@$core.Deprecated('Use diveDescriptor instead')
const Dive$json = {
  '1': 'Dive',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'created_at', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'deletedAt'},
    {'1': 'synced_etag', '3': 5, '4': 1, '5': 9, '10': 'syncedEtag'},
    {'1': 'number', '3': 8, '4': 1, '5': 5, '10': 'number'},
    {'1': 'rating', '3': 9, '4': 1, '5': 5, '10': 'rating'},
    {'1': 'tags', '3': 10, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'start', '3': 11, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'start'},
    {'1': 'duration', '3': 12, '4': 1, '5': 5, '10': 'duration'},
    {'1': 'max_depth', '3': 13, '4': 1, '5': 1, '10': 'maxDepth'},
    {'1': 'mean_depth', '3': 14, '4': 1, '5': 1, '10': 'meanDepth'},
    {'1': 'min_temp', '3': 27, '4': 1, '5': 1, '10': 'minTemp'},
    {'1': 'max_temp', '3': 28, '4': 1, '5': 1, '10': 'maxTemp'},
    {'1': 'sac', '3': 15, '4': 1, '5': 1, '10': 'sac'},
    {'1': 'otu', '3': 16, '4': 1, '5': 5, '10': 'otu'},
    {'1': 'cns', '3': 17, '4': 1, '5': 5, '10': 'cns'},
    {'1': 'site_id', '3': 18, '4': 1, '5': 9, '10': 'siteId'},
    {'1': 'instructor', '3': 19, '4': 1, '5': 9, '10': 'instructor'},
    {'1': 'divemaster', '3': 20, '4': 1, '5': 9, '10': 'divemaster'},
    {'1': 'buddies', '3': 21, '4': 3, '5': 9, '10': 'buddies'},
    {'1': 'notes', '3': 22, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'cylinders', '3': 23, '4': 3, '5': 11, '6': '.divestore.DiveCylinder', '10': 'cylinders'},
    {'1': 'weightsystems', '3': 24, '4': 3, '5': 11, '6': '.divestore.Weightsystem', '10': 'weightsystems'},
    {'1': 'logs', '3': 25, '4': 3, '5': 11, '6': '.divestore.Log', '10': 'logs'},
    {'1': 'events', '3': 26, '4': 3, '5': 11, '6': '.divestore.SampleEvent', '10': 'events'},
  ],
};

/// Descriptor for `Dive`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diveDescriptor = $convert.base64Decode('CgREaXZlEg4KAmlkGAEgASgJUgJpZBI5CgpjcmVhdGVkX2F0GAIgASgLMhouZ29vZ2xlLnByb3'
    'RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYAyABKAsyGi5nb29nbGUu'
    'cHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQSOQoKZGVsZXRlZF9hdBgEIAEoCzIaLmdvb2'
    'dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWRlbGV0ZWRBdBIfCgtzeW5jZWRfZXRhZxgFIAEoCVIK'
    'c3luY2VkRXRhZxIWCgZudW1iZXIYCCABKAVSBm51bWJlchIWCgZyYXRpbmcYCSABKAVSBnJhdG'
    'luZxISCgR0YWdzGAogAygJUgR0YWdzEjAKBXN0YXJ0GAsgASgLMhouZ29vZ2xlLnByb3RvYnVm'
    'LlRpbWVzdGFtcFIFc3RhcnQSGgoIZHVyYXRpb24YDCABKAVSCGR1cmF0aW9uEhsKCW1heF9kZX'
    'B0aBgNIAEoAVIIbWF4RGVwdGgSHQoKbWVhbl9kZXB0aBgOIAEoAVIJbWVhbkRlcHRoEhkKCG1p'
    'bl90ZW1wGBsgASgBUgdtaW5UZW1wEhkKCG1heF90ZW1wGBwgASgBUgdtYXhUZW1wEhAKA3NhYx'
    'gPIAEoAVIDc2FjEhAKA290dRgQIAEoBVIDb3R1EhAKA2NucxgRIAEoBVIDY25zEhcKB3NpdGVf'
    'aWQYEiABKAlSBnNpdGVJZBIeCgppbnN0cnVjdG9yGBMgASgJUgppbnN0cnVjdG9yEh4KCmRpdm'
    'VtYXN0ZXIYFCABKAlSCmRpdmVtYXN0ZXISGAoHYnVkZGllcxgVIAMoCVIHYnVkZGllcxIUCgVu'
    'b3RlcxgWIAEoCVIFbm90ZXMSNQoJY3lsaW5kZXJzGBcgAygLMhcuZGl2ZXN0b3JlLkRpdmVDeW'
    'xpbmRlclIJY3lsaW5kZXJzEj0KDXdlaWdodHN5c3RlbXMYGCADKAsyFy5kaXZlc3RvcmUuV2Vp'
    'Z2h0c3lzdGVtUg13ZWlnaHRzeXN0ZW1zEiIKBGxvZ3MYGSADKAsyDi5kaXZlc3RvcmUuTG9nUg'
    'Rsb2dzEi4KBmV2ZW50cxgaIAMoCzIWLmRpdmVzdG9yZS5TYW1wbGVFdmVudFIGZXZlbnRz');

@$core.Deprecated('Use diveCylinderDescriptor instead')
const DiveCylinder$json = {
  '1': 'DiveCylinder',
  '2': [
    {'1': 'cylinder_id', '3': 1, '4': 1, '5': 9, '10': 'cylinderId'},
    {'1': 'begin_pressure', '3': 2, '4': 1, '5': 1, '10': 'beginPressure'},
    {'1': 'end_pressure', '3': 3, '4': 1, '5': 1, '10': 'endPressure'},
    {'1': 'oxygen', '3': 4, '4': 1, '5': 1, '10': 'oxygen'},
    {'1': 'helium', '3': 5, '4': 1, '5': 1, '10': 'helium'},
    {'1': 'used_volume', '3': 16, '4': 1, '5': 1, '10': 'usedVolume'},
    {'1': 'sac', '3': 17, '4': 1, '5': 1, '10': 'sac'},
    {'1': 'cylinder', '3': 32, '4': 1, '5': 11, '6': '.divestore.Cylinder', '10': 'cylinder'},
  ],
};

/// Descriptor for `DiveCylinder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diveCylinderDescriptor = $convert.base64Decode('CgxEaXZlQ3lsaW5kZXISHwoLY3lsaW5kZXJfaWQYASABKAlSCmN5bGluZGVySWQSJQoOYmVnaW'
    '5fcHJlc3N1cmUYAiABKAFSDWJlZ2luUHJlc3N1cmUSIQoMZW5kX3ByZXNzdXJlGAMgASgBUgtl'
    'bmRQcmVzc3VyZRIWCgZveHlnZW4YBCABKAFSBm94eWdlbhIWCgZoZWxpdW0YBSABKAFSBmhlbG'
    'l1bRIfCgt1c2VkX3ZvbHVtZRgQIAEoAVIKdXNlZFZvbHVtZRIQCgNzYWMYESABKAFSA3NhYxIv'
    'CghjeWxpbmRlchggIAEoCzITLmRpdmVzdG9yZS5DeWxpbmRlclIIY3lsaW5kZXI=');

@$core.Deprecated('Use weightsystemDescriptor instead')
const Weightsystem$json = {
  '1': 'Weightsystem',
  '2': [
    {'1': 'weight', '3': 1, '4': 1, '5': 1, '10': 'weight'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `Weightsystem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List weightsystemDescriptor = $convert.base64Decode('CgxXZWlnaHRzeXN0ZW0SFgoGd2VpZ2h0GAEgASgBUgZ3ZWlnaHQSIAoLZGVzY3JpcHRpb24YAi'
    'ABKAlSC2Rlc2NyaXB0aW9u');
