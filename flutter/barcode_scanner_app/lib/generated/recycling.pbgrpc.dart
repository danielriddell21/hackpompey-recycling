// This is a generated file - do not edit.
//
// Generated from recycling.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'recycling.pb.dart' as $0;

export 'recycling.pb.dart';

/// Service definition
@$pb.GrpcServiceName('recycling.RecyclingService')
class RecyclingServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RecyclingServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.CanItBeRecycledResponse> canItBeRecycled(
    $0.CanItBeRecycledRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$canItBeRecycled, request, options: options);
  }

  $grpc.ResponseFuture<$0.CanItBeRecycledImageResponse> canItBeRecycledImage(
    $0.CanItBeRecycledImageRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$canItBeRecycledImage, request, options: options);
  }

  // method descriptors

  static final _$canItBeRecycled =
      $grpc.ClientMethod<$0.CanItBeRecycledRequest, $0.CanItBeRecycledResponse>(
          '/recycling.RecyclingService/CanItBeRecycled',
          ($0.CanItBeRecycledRequest value) => value.writeToBuffer(),
          $0.CanItBeRecycledResponse.fromBuffer);
  static final _$canItBeRecycledImage = $grpc.ClientMethod<
          $0.CanItBeRecycledImageRequest, $0.CanItBeRecycledImageResponse>(
      '/recycling.RecyclingService/CanItBeRecycledImage',
      ($0.CanItBeRecycledImageRequest value) => value.writeToBuffer(),
      $0.CanItBeRecycledImageResponse.fromBuffer);
}

@$pb.GrpcServiceName('recycling.RecyclingService')
abstract class RecyclingServiceBase extends $grpc.Service {
  $core.String get $name => 'recycling.RecyclingService';

  RecyclingServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CanItBeRecycledRequest,
            $0.CanItBeRecycledResponse>(
        'CanItBeRecycled',
        canItBeRecycled_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CanItBeRecycledRequest.fromBuffer(value),
        ($0.CanItBeRecycledResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CanItBeRecycledImageRequest,
            $0.CanItBeRecycledImageResponse>(
        'CanItBeRecycledImage',
        canItBeRecycledImage_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CanItBeRecycledImageRequest.fromBuffer(value),
        ($0.CanItBeRecycledImageResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CanItBeRecycledResponse> canItBeRecycled_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CanItBeRecycledRequest> $request) async {
    return canItBeRecycled($call, await $request);
  }

  $async.Future<$0.CanItBeRecycledResponse> canItBeRecycled(
      $grpc.ServiceCall call, $0.CanItBeRecycledRequest request);

  $async.Future<$0.CanItBeRecycledImageResponse> canItBeRecycledImage_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CanItBeRecycledImageRequest> $request) async {
    return canItBeRecycledImage($call, await $request);
  }

  $async.Future<$0.CanItBeRecycledImageResponse> canItBeRecycledImage(
      $grpc.ServiceCall call, $0.CanItBeRecycledImageRequest request);
}
