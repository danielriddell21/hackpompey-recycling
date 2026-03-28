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

import 'recycling.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'recycling.pbenum.dart';

/// Messages for recycling items
class RecyclingItem extends $pb.GeneratedMessage {
  factory RecyclingItem({
    $core.bool? recyclable,
    $core.String? advice,
    RecyclingItem_BinColour? binColour,
    RecyclingItem_BinType? binType,
  }) {
    final result = create();
    if (recyclable != null) result.recyclable = recyclable;
    if (advice != null) result.advice = advice;
    if (binColour != null) result.binColour = binColour;
    if (binType != null) result.binType = binType;
    return result;
  }

  RecyclingItem._();

  factory RecyclingItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecyclingItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecyclingItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'recycling'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'recyclable')
    ..aOS(2, _omitFieldNames ? '' : 'advice')
    ..aE<RecyclingItem_BinColour>(3, _omitFieldNames ? '' : 'binColour',
        enumValues: RecyclingItem_BinColour.values)
    ..aE<RecyclingItem_BinType>(4, _omitFieldNames ? '' : 'binType',
        enumValues: RecyclingItem_BinType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecyclingItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecyclingItem copyWith(void Function(RecyclingItem) updates) =>
      super.copyWith((message) => updates(message as RecyclingItem))
          as RecyclingItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecyclingItem create() => RecyclingItem._();
  @$core.override
  RecyclingItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecyclingItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecyclingItem>(create);
  static RecyclingItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get recyclable => $_getBF(0);
  @$pb.TagNumber(1)
  set recyclable($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecyclable() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecyclable() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get advice => $_getSZ(1);
  @$pb.TagNumber(2)
  set advice($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAdvice() => $_has(1);
  @$pb.TagNumber(2)
  void clearAdvice() => $_clearField(2);

  @$pb.TagNumber(3)
  RecyclingItem_BinColour get binColour => $_getN(2);
  @$pb.TagNumber(3)
  set binColour(RecyclingItem_BinColour value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBinColour() => $_has(2);
  @$pb.TagNumber(3)
  void clearBinColour() => $_clearField(3);

  @$pb.TagNumber(4)
  RecyclingItem_BinType get binType => $_getN(3);
  @$pb.TagNumber(4)
  set binType(RecyclingItem_BinType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasBinType() => $_has(3);
  @$pb.TagNumber(4)
  void clearBinType() => $_clearField(4);
}

class CanItBeRecycledRequest extends $pb.GeneratedMessage {
  factory CanItBeRecycledRequest({
    $core.String? barcode,
  }) {
    final result = create();
    if (barcode != null) result.barcode = barcode;
    return result;
  }

  CanItBeRecycledRequest._();

  factory CanItBeRecycledRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CanItBeRecycledRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CanItBeRecycledRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'recycling'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'barcode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledRequest copyWith(
          void Function(CanItBeRecycledRequest) updates) =>
      super.copyWith((message) => updates(message as CanItBeRecycledRequest))
          as CanItBeRecycledRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledRequest create() => CanItBeRecycledRequest._();
  @$core.override
  CanItBeRecycledRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CanItBeRecycledRequest>(create);
  static CanItBeRecycledRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get barcode => $_getSZ(0);
  @$pb.TagNumber(1)
  set barcode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBarcode() => $_has(0);
  @$pb.TagNumber(1)
  void clearBarcode() => $_clearField(1);
}

class CanItBeRecycledResponse extends $pb.GeneratedMessage {
  factory CanItBeRecycledResponse({
    RecyclingItem? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  CanItBeRecycledResponse._();

  factory CanItBeRecycledResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CanItBeRecycledResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CanItBeRecycledResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'recycling'),
      createEmptyInstance: create)
    ..aOM<RecyclingItem>(1, _omitFieldNames ? '' : 'data',
        subBuilder: RecyclingItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledResponse copyWith(
          void Function(CanItBeRecycledResponse) updates) =>
      super.copyWith((message) => updates(message as CanItBeRecycledResponse))
          as CanItBeRecycledResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledResponse create() => CanItBeRecycledResponse._();
  @$core.override
  CanItBeRecycledResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CanItBeRecycledResponse>(create);
  static CanItBeRecycledResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RecyclingItem get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(RecyclingItem value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  RecyclingItem ensureData() => $_ensure(0);
}

class CanItBeRecycledSearchRequest extends $pb.GeneratedMessage {
  factory CanItBeRecycledSearchRequest({
    $core.String? query,
  }) {
    final result = create();
    if (query != null) result.query = query;
    return result;
  }

  CanItBeRecycledSearchRequest._();

  factory CanItBeRecycledSearchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CanItBeRecycledSearchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CanItBeRecycledSearchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'recycling'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledSearchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledSearchRequest copyWith(
          void Function(CanItBeRecycledSearchRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CanItBeRecycledSearchRequest))
          as CanItBeRecycledSearchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledSearchRequest create() =>
      CanItBeRecycledSearchRequest._();
  @$core.override
  CanItBeRecycledSearchRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledSearchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CanItBeRecycledSearchRequest>(create);
  static CanItBeRecycledSearchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);
}

class CanItBeRecycledSearchResponse extends $pb.GeneratedMessage {
  factory CanItBeRecycledSearchResponse({
    $core.Iterable<RecyclingItem>? data,
  }) {
    final result = create();
    if (data != null) result.data.addAll(data);
    return result;
  }

  CanItBeRecycledSearchResponse._();

  factory CanItBeRecycledSearchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CanItBeRecycledSearchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CanItBeRecycledSearchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'recycling'),
      createEmptyInstance: create)
    ..pPM<RecyclingItem>(1, _omitFieldNames ? '' : 'data',
        subBuilder: RecyclingItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledSearchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledSearchResponse copyWith(
          void Function(CanItBeRecycledSearchResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CanItBeRecycledSearchResponse))
          as CanItBeRecycledSearchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledSearchResponse create() =>
      CanItBeRecycledSearchResponse._();
  @$core.override
  CanItBeRecycledSearchResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledSearchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CanItBeRecycledSearchResponse>(create);
  static CanItBeRecycledSearchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RecyclingItem> get data => $_getList(0);
}

class CanItBeRecycledImageRequest extends $pb.GeneratedMessage {
  factory CanItBeRecycledImageRequest({
    $core.List<$core.int>? image,
  }) {
    final result = create();
    if (image != null) result.image = image;
    return result;
  }

  CanItBeRecycledImageRequest._();

  factory CanItBeRecycledImageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CanItBeRecycledImageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CanItBeRecycledImageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'recycling'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'image', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledImageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledImageRequest copyWith(
          void Function(CanItBeRecycledImageRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CanItBeRecycledImageRequest))
          as CanItBeRecycledImageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledImageRequest create() =>
      CanItBeRecycledImageRequest._();
  @$core.override
  CanItBeRecycledImageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledImageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CanItBeRecycledImageRequest>(create);
  static CanItBeRecycledImageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get image => $_getN(0);
  @$pb.TagNumber(1)
  set image($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasImage() => $_has(0);
  @$pb.TagNumber(1)
  void clearImage() => $_clearField(1);
}

class CanItBeRecycledImageResponse extends $pb.GeneratedMessage {
  factory CanItBeRecycledImageResponse({
    RecyclingItem? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  CanItBeRecycledImageResponse._();

  factory CanItBeRecycledImageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CanItBeRecycledImageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CanItBeRecycledImageResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'recycling'),
      createEmptyInstance: create)
    ..aOM<RecyclingItem>(1, _omitFieldNames ? '' : 'data',
        subBuilder: RecyclingItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledImageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CanItBeRecycledImageResponse copyWith(
          void Function(CanItBeRecycledImageResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CanItBeRecycledImageResponse))
          as CanItBeRecycledImageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledImageResponse create() =>
      CanItBeRecycledImageResponse._();
  @$core.override
  CanItBeRecycledImageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CanItBeRecycledImageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CanItBeRecycledImageResponse>(create);
  static CanItBeRecycledImageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RecyclingItem get data => $_getN(0);
  @$pb.TagNumber(1)
  set data(RecyclingItem value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
  @$pb.TagNumber(1)
  RecyclingItem ensureData() => $_ensure(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
