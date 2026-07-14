import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/errors/core_failure.dart';
import '../../domain/errors/failure.dart';
import 'app_exception.dart';

part 'core_exception.freezed.dart';

@freezed
sealed class CoreException with _$CoreException implements AppException {
  const CoreException._();

  const factory CoreException.cacheError({String? msg, StackTrace? st}) =
      _CacheError;

  const factory CoreException.serverError({String? msg, StackTrace? st}) =
      _ServerError;

  const factory CoreException.serviceUnavailable({
    String? msg,
    StackTrace? st,
  }) = _ServiceUnavailable;

  const factory CoreException.networkError({String? msg, StackTrace? st}) =
      _NetworkError;

  const factory CoreException.timeoutError({String? msg, StackTrace? st}) =
      _TimeoutError;

  const factory CoreException.unauthenticatedError({
    String? msg,
    StackTrace? st,
  }) = _UnauthenticatedError;

  @override
  String get message => when(
    cacheError: (msg, _) => msg ?? 'Cache/Local storage failure',
    serverError: (msg, _) => msg ?? 'Internal server error',
    networkError: (msg, _) => msg ?? 'Network connection failed',
    timeoutError: (msg, _) => msg ?? 'Request timeout',
    unauthenticatedError: (msg, _) => msg ?? 'User session invalid',
    serviceUnavailable: (msg, _) => msg ?? 'Service unavailable',
  );

  @override
  StackTrace? get stackTrace => st;

  @override
  Failure toFailure() => when(
    serverError: (_, _) => CoreFailure.serverError,
    networkError: (_, _) => CoreFailure.networkError,
    timeoutError: (_, _) => CoreFailure.timeoutError,
    cacheError: (_, _) => CoreFailure.cacheError,
    unauthenticatedError: (_, _) => CoreFailure.unauthenticated,
    serviceUnavailable: (_, _) => CoreFailure.serviceUnavailable,
  );

  factory CoreException.fromException(
    Object e, {
    StackTrace? st,
    bool isLocal = false,
  }) {
    final msg = e.toString().toLowerCase();

    if (msg.contains('unauthenticated') ||
        msg.contains('401') ||
        msg.contains('jwt')) {
      return CoreException.unauthenticatedError(msg: msg, st: st);
    }

    if (e is SocketException ||
        e is HttpException ||
        msg.contains('network_error')) {
      return CoreException.networkError(msg: msg, st: st);
    }

    if (e is TimeoutException || msg.contains('timeout')) {
      return CoreException.timeoutError(msg: msg, st: st);
    }

    if (e is PlatformException && e.code == 'service_unavailable') {
      return CoreException.serviceUnavailable(msg: msg, st: st);
    }

    return isLocal
        ? CoreException.cacheError(msg: msg, st: st)
        : CoreException.serverError(msg: msg, st: st);
  }
}
