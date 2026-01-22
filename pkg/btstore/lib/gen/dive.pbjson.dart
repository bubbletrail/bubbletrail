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
    {'1': 'meta', '3': 2, '4': 1, '5': 11, '6': '.btstore.Metadata', '10': 'meta'},
    {'1': 'synced_etag', '3': 3, '4': 1, '5': 9, '10': 'syncedEtag'},
    {'1': 'number', '3': 4, '4': 1, '5': 5, '10': 'number'},
    {'1': 'rating', '3': 5, '4': 1, '5': 5, '10': 'rating'},
    {'1': 'tags', '3': 6, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'start', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'start'},
    {'1': 'duration', '3': 8, '4': 1, '5': 5, '10': 'duration'},
    {'1': 'max_depth', '3': 9, '4': 1, '5': 1, '10': 'maxDepth'},
    {'1': 'mean_depth', '3': 10, '4': 1, '5': 1, '10': 'meanDepth'},
    {'1': 'min_temp', '3': 11, '4': 1, '5': 1, '10': 'minTemp'},
    {'1': 'max_temp', '3': 12, '4': 1, '5': 1, '10': 'maxTemp'},
    {'1': 'sac', '3': 13, '4': 1, '5': 1, '10': 'sac'},
    {'1': 'otu', '3': 14, '4': 1, '5': 5, '10': 'otu'},
    {'1': 'cns', '3': 15, '4': 1, '5': 5, '10': 'cns'},
    {'1': 'site_id', '3': 16, '4': 1, '5': 9, '10': 'siteId'},
    {'1': 'instructor', '3': 17, '4': 1, '5': 9, '10': 'instructor'},
    {'1': 'divemaster', '3': 18, '4': 1, '5': 9, '10': 'divemaster'},
    {'1': 'buddies', '3': 19, '4': 3, '5': 9, '10': 'buddies'},
    {'1': 'notes', '3': 20, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'cylinders', '3': 21, '4': 3, '5': 11, '6': '.btstore.DiveCylinder', '10': 'cylinders'},
    {'1': 'weightsystems', '3': 22, '4': 3, '5': 11, '6': '.btstore.Weightsystem', '10': 'weightsystems'},
    {'1': 'events', '3': 24, '4': 3, '5': 11, '6': '.btstore.SampleEvent', '10': 'events'},
    {'1': 'start_tissues', '3': 25, '4': 1, '5': 11, '6': '.btstore.Tissues', '10': 'startTissues'},
    {'1': 'end_tissues', '3': 26, '4': 1, '5': 11, '6': '.btstore.Tissues', '10': 'endTissues'},
    {'1': 'end_surf_gf', '3': 28, '4': 1, '5': 1, '10': 'endSurfGf'},
    {'1': 'deprecated_logs', '3': 23, '4': 3, '5': 11, '6': '.btstore.Log', '10': 'deprecatedLogs'},
    {'1': 'logs', '3': 64, '4': 3, '5': 11, '6': '.btstore.Log', '10': 'logs'},
  ],
  '9': [
    {'1': 27, '2': 28},
  ],
};

/// Descriptor for `Dive`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diveDescriptor = $convert.base64Decode('CgREaXZlEg4KAmlkGAEgASgJUgJpZBInCgRtZXRhGAIgASgLMhMuZGl2ZXN0b3JlLk1ldGFkYX'
    'RhUgRtZXRhEh8KC3N5bmNlZF9ldGFnGAMgASgJUgpzeW5jZWRFdGFnEhYKBm51bWJlchgEIAEo'
    'BVIGbnVtYmVyEhYKBnJhdGluZxgFIAEoBVIGcmF0aW5nEhIKBHRhZ3MYBiADKAlSBHRhZ3MSMA'
    'oFc3RhcnQYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgVzdGFydBIaCghkdXJh'
    'dGlvbhgIIAEoBVIIZHVyYXRpb24SGwoJbWF4X2RlcHRoGAkgASgBUghtYXhEZXB0aBIdCgptZW'
    'FuX2RlcHRoGAogASgBUgltZWFuRGVwdGgSGQoIbWluX3RlbXAYCyABKAFSB21pblRlbXASGQoI'
    'bWF4X3RlbXAYDCABKAFSB21heFRlbXASEAoDc2FjGA0gASgBUgNzYWMSEAoDb3R1GA4gASgFUg'
    'NvdHUSEAoDY25zGA8gASgFUgNjbnMSFwoHc2l0ZV9pZBgQIAEoCVIGc2l0ZUlkEh4KCmluc3Ry'
    'dWN0b3IYESABKAlSCmluc3RydWN0b3ISHgoKZGl2ZW1hc3RlchgSIAEoCVIKZGl2ZW1hc3Rlch'
    'IYCgdidWRkaWVzGBMgAygJUgdidWRkaWVzEhQKBW5vdGVzGBQgASgJUgVub3RlcxI1CgljeWxp'
    'bmRlcnMYFSADKAsyFy5kaXZlc3RvcmUuRGl2ZUN5bGluZGVyUgljeWxpbmRlcnMSPQoNd2VpZ2'
    'h0c3lzdGVtcxgWIAMoCzIXLmRpdmVzdG9yZS5XZWlnaHRzeXN0ZW1SDXdlaWdodHN5c3RlbXMS'
    'LgoGZXZlbnRzGBggAygLMhYuZGl2ZXN0b3JlLlNhbXBsZUV2ZW50UgZldmVudHMSNwoNc3Rhcn'
    'RfdGlzc3VlcxgZIAEoCzISLmRpdmVzdG9yZS5UaXNzdWVzUgxzdGFydFRpc3N1ZXMSMwoLZW5k'
    'X3Rpc3N1ZXMYGiABKAsyEi5kaXZlc3RvcmUuVGlzc3Vlc1IKZW5kVGlzc3VlcxIeCgtlbmRfc3'
    'VyZl9nZhgcIAEoAVIJZW5kU3VyZkdmEjcKD2RlcHJlY2F0ZWRfbG9ncxgXIAMoCzIOLmRpdmVz'
    'dG9yZS5Mb2dSDmRlcHJlY2F0ZWRMb2dzEiIKBGxvZ3MYQCADKAsyDi5kaXZlc3RvcmUuTG9nUg'
    'Rsb2dzSgQIGxAc');

@$core.Deprecated('Use diveCylinderDescriptor instead')
const DiveCylinder$json = {
  '1': 'DiveCylinder',
  '2': [
    {'1': 'cylinder_id', '3': 1, '4': 1, '5': 9, '10': 'cylinderId'},
    {'1': 'begin_pressure', '3': 2, '4': 1, '5': 1, '10': 'beginPressure'},
    {'1': 'end_pressure', '3': 3, '4': 1, '5': 1, '10': 'endPressure'},
    {'1': 'oxygen', '3': 4, '4': 1, '5': 1, '10': 'oxygen'},
    {'1': 'helium', '3': 5, '4': 1, '5': 1, '10': 'helium'},
    {'1': 'used_volume', '3': 6, '4': 1, '5': 1, '10': 'usedVolume'},
    {'1': 'sac', '3': 7, '4': 1, '5': 1, '10': 'sac'},
    {'1': 'cylinder', '3': 8, '4': 1, '5': 11, '6': '.btstore.Cylinder', '10': 'cylinder'},
  ],
};

/// Descriptor for `DiveCylinder`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diveCylinderDescriptor = $convert.base64Decode('CgxEaXZlQ3lsaW5kZXISHwoLY3lsaW5kZXJfaWQYASABKAlSCmN5bGluZGVySWQSJQoOYmVnaW'
    '5fcHJlc3N1cmUYAiABKAFSDWJlZ2luUHJlc3N1cmUSIQoMZW5kX3ByZXNzdXJlGAMgASgBUgtl'
    'bmRQcmVzc3VyZRIWCgZveHlnZW4YBCABKAFSBm94eWdlbhIWCgZoZWxpdW0YBSABKAFSBmhlbG'
    'l1bRIfCgt1c2VkX3ZvbHVtZRgGIAEoAVIKdXNlZFZvbHVtZRIQCgNzYWMYByABKAFSA3NhYxIv'
    'CghjeWxpbmRlchgIIAEoCzITLmRpdmVzdG9yZS5DeWxpbmRlclIIY3lsaW5kZXI=');

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
