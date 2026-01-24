// This is a generated file - do not edit.
//
// Generated from computer.proto.

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

@$core.Deprecated('Use computerDescriptor instead')
const Computer$json = {
  '1': 'Computer',
  '2': [
    {'1': 'remote_id', '3': 1, '4': 1, '5': 9, '10': 'remoteId'},
    {
      '1': 'meta',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.btstore.Metadata',
      '10': 'meta'
    },
    {'1': 'advertised_name', '3': 3, '4': 1, '5': 9, '10': 'advertisedName'},
    {'1': 'vendor', '3': 4, '4': 1, '5': 9, '10': 'vendor'},
    {'1': 'product', '3': 5, '4': 1, '5': 9, '10': 'product'},
    {'1': 'serial', '3': 6, '4': 1, '5': 9, '10': 'serial'},
    {'1': 'ldc_fingerprint', '3': 7, '4': 1, '5': 12, '10': 'ldcFingerprint'},
    {
      '1': 'last_log_date',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastLogDate'
    },
  ],
};

/// Descriptor for `Computer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computerDescriptor = $convert.base64Decode(
    'CghDb21wdXRlchIbCglyZW1vdGVfaWQYASABKAlSCHJlbW90ZUlkEiUKBG1ldGEYAiABKAsyES'
    '5idHN0b3JlLk1ldGFkYXRhUgRtZXRhEicKD2FkdmVydGlzZWRfbmFtZRgDIAEoCVIOYWR2ZXJ0'
    'aXNlZE5hbWUSFgoGdmVuZG9yGAQgASgJUgZ2ZW5kb3ISGAoHcHJvZHVjdBgFIAEoCVIHcHJvZH'
    'VjdBIWCgZzZXJpYWwYBiABKAlSBnNlcmlhbBInCg9sZGNfZmluZ2VycHJpbnQYByABKAxSDmxk'
    'Y0ZpbmdlcnByaW50Ej4KDWxhc3RfbG9nX2RhdGUYCCABKAsyGi5nb29nbGUucHJvdG9idWYuVG'
    'ltZXN0YW1wUgtsYXN0TG9nRGF0ZQ==');
