// This is a generated file - do not edit.
//
// Generated from recycling.proto.

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

@$core.Deprecated('Use recyclingItemDescriptor instead')
const RecyclingItem$json = {
  '1': 'RecyclingItem',
  '2': [
    {'1': 'recyclable', '3': 1, '4': 1, '5': 8, '10': 'recyclable'},
    {'1': 'advice', '3': 2, '4': 1, '5': 9, '10': 'advice'},
    {
      '1': 'bin_colour',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.recycling.RecyclingItem.BinColour',
      '10': 'binColour'
    },
    {
      '1': 'bin_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.recycling.RecyclingItem.BinType',
      '10': 'binType'
    },
  ],
  '4': [RecyclingItem_BinColour$json, RecyclingItem_BinType$json],
};

@$core.Deprecated('Use recyclingItemDescriptor instead')
const RecyclingItem_BinColour$json = {
  '1': 'BinColour',
  '2': [
    {'1': 'BIN_COLOUR_UNKNOWN', '2': 0},
    {'1': 'BLUE', '2': 1},
    {'1': 'GREEN', '2': 2},
    {'1': 'BROWN', '2': 3},
    {'1': 'BLACK', '2': 4},
  ],
};

@$core.Deprecated('Use recyclingItemDescriptor instead')
const RecyclingItem_BinType$json = {
  '1': 'BinType',
  '2': [
    {'1': 'BIN_TYPE_UNKNOWN', '2': 0},
    {'1': 'PAPER', '2': 1},
    {'1': 'PLASTIC', '2': 2},
    {'1': 'GLASS', '2': 3},
    {'1': 'WASTE', '2': 4},
  ],
};

/// Descriptor for `RecyclingItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recyclingItemDescriptor = $convert.base64Decode(
    'Cg1SZWN5Y2xpbmdJdGVtEh4KCnJlY3ljbGFibGUYASABKAhSCnJlY3ljbGFibGUSFgoGYWR2aW'
    'NlGAIgASgJUgZhZHZpY2USQQoKYmluX2NvbG91chgDIAEoDjIiLnJlY3ljbGluZy5SZWN5Y2xp'
    'bmdJdGVtLkJpbkNvbG91clIJYmluQ29sb3VyEjsKCGJpbl90eXBlGAQgASgOMiAucmVjeWNsaW'
    '5nLlJlY3ljbGluZ0l0ZW0uQmluVHlwZVIHYmluVHlwZSJOCglCaW5Db2xvdXISFgoSQklOX0NP'
    'TE9VUl9VTktOT1dOEAASCAoEQkxVRRABEgkKBUdSRUVOEAISCQoFQlJPV04QAxIJCgVCTEFDSx'
    'AEIk0KB0JpblR5cGUSFAoQQklOX1RZUEVfVU5LTk9XThAAEgkKBVBBUEVSEAESCwoHUExBU1RJ'
    'QxACEgkKBUdMQVNTEAMSCQoFV0FTVEUQBA==');

@$core.Deprecated('Use canItBeRecycledRequestDescriptor instead')
const CanItBeRecycledRequest$json = {
  '1': 'CanItBeRecycledRequest',
  '2': [
    {'1': 'barcode', '3': 1, '4': 1, '5': 9, '10': 'barcode'},
  ],
};

/// Descriptor for `CanItBeRecycledRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List canItBeRecycledRequestDescriptor =
    $convert.base64Decode(
        'ChZDYW5JdEJlUmVjeWNsZWRSZXF1ZXN0EhgKB2JhcmNvZGUYASABKAlSB2JhcmNvZGU=');

@$core.Deprecated('Use canItBeRecycledResponseDescriptor instead')
const CanItBeRecycledResponse$json = {
  '1': 'CanItBeRecycledResponse',
  '2': [
    {
      '1': 'data',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.recycling.RecyclingItem',
      '10': 'data'
    },
  ],
};

/// Descriptor for `CanItBeRecycledResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List canItBeRecycledResponseDescriptor =
    $convert.base64Decode(
        'ChdDYW5JdEJlUmVjeWNsZWRSZXNwb25zZRIsCgRkYXRhGAEgASgLMhgucmVjeWNsaW5nLlJlY3'
        'ljbGluZ0l0ZW1SBGRhdGE=');
