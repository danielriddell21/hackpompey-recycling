// This is a generated file - do not edit.
//
// Generated from recycling.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class RecyclingItem_BinColour extends $pb.ProtobufEnum {
  static const RecyclingItem_BinColour BIN_COLOUR_UNKNOWN =
      RecyclingItem_BinColour._(0, _omitEnumNames ? '' : 'BIN_COLOUR_UNKNOWN');
  static const RecyclingItem_BinColour BLUE =
      RecyclingItem_BinColour._(1, _omitEnumNames ? '' : 'BLUE');
  static const RecyclingItem_BinColour GREEN =
      RecyclingItem_BinColour._(2, _omitEnumNames ? '' : 'GREEN');
  static const RecyclingItem_BinColour BROWN =
      RecyclingItem_BinColour._(3, _omitEnumNames ? '' : 'BROWN');
  static const RecyclingItem_BinColour BLACK =
      RecyclingItem_BinColour._(4, _omitEnumNames ? '' : 'BLACK');

  static const $core.List<RecyclingItem_BinColour> values =
      <RecyclingItem_BinColour>[
    BIN_COLOUR_UNKNOWN,
    BLUE,
    GREEN,
    BROWN,
    BLACK,
  ];

  static final $core.List<RecyclingItem_BinColour?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static RecyclingItem_BinColour? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const RecyclingItem_BinColour._(super.value, super.name);
}

class RecyclingItem_BinType extends $pb.ProtobufEnum {
  static const RecyclingItem_BinType BIN_TYPE_UNKNOWN =
      RecyclingItem_BinType._(0, _omitEnumNames ? '' : 'BIN_TYPE_UNKNOWN');
  static const RecyclingItem_BinType PAPER =
      RecyclingItem_BinType._(1, _omitEnumNames ? '' : 'PAPER');
  static const RecyclingItem_BinType PLASTIC =
      RecyclingItem_BinType._(2, _omitEnumNames ? '' : 'PLASTIC');
  static const RecyclingItem_BinType GLASS =
      RecyclingItem_BinType._(3, _omitEnumNames ? '' : 'GLASS');
  static const RecyclingItem_BinType WASTE =
      RecyclingItem_BinType._(4, _omitEnumNames ? '' : 'WASTE');

  static const $core.List<RecyclingItem_BinType> values =
      <RecyclingItem_BinType>[
    BIN_TYPE_UNKNOWN,
    PAPER,
    PLASTIC,
    GLASS,
    WASTE,
  ];

  static final $core.List<RecyclingItem_BinType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static RecyclingItem_BinType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const RecyclingItem_BinType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
