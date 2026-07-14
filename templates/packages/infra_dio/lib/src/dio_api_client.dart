import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_core/app_core.dart';
import 'package:dio/dio.dart';

class DioApiClient implements ApiClient {
  static const instanceName = 'DioApiClient';

  final Dio _dio;
  final Duration _connectTimeout;
  final Duration _sendTimeout;
  final Duration _receiveTimeout;
  final Duration _streamConnectionTimeout;

  DioApiClient({
    required Dio dio,
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration sendTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration streamConnectionTimeout = const Duration(seconds: 15),
  }) : _dio = dio..options.baseUrl = baseUrl,
       _connectTimeout = connectTimeout,
       _sendTimeout = sendTimeout,
       _receiveTimeout = receiveTimeout,
       _streamConnectionTimeout = streamConnectionTimeout;

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          connectTimeout: _connectTimeout,
          receiveTimeout: _receiveTimeout,
          sendTimeout: _sendTimeout,
        ),
      );

      return _mapResponse<T>(response);
    } catch (e, st) {
      throw _fromException(e, st);
    }
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          connectTimeout: _connectTimeout,
          receiveTimeout: _receiveTimeout,
          sendTimeout: _sendTimeout,
        ),
      );

      return _mapResponse<T>(response);
    } catch (e, st) {
      throw _fromException(e, st);
    }
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          connectTimeout: _connectTimeout,
          receiveTimeout: _receiveTimeout,
          sendTimeout: _sendTimeout,
        ),
      );

      return _mapResponse<T>(response);
    } catch (e, st) {
      throw _fromException(e, st);
    }
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          connectTimeout: _connectTimeout,
          receiveTimeout: _receiveTimeout,
          sendTimeout: _sendTimeout,
        ),
      );

      return _mapResponse<T>(response);
    } catch (e, st) {
      throw _fromException(e, st);
    }
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          connectTimeout: _connectTimeout,
          receiveTimeout: _receiveTimeout,
          sendTimeout: _sendTimeout,
        ),
      );

      return _mapResponse<T>(response);
    } catch (e, st) {
      throw _fromException(e, st);
    }
  }

  @override
  Stream<T> stream<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async* {
    try {
      final response = await _dio.get<ResponseBody>(
        path,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.stream,
          headers: NetworkHelper.sseHeaders(headers),
          connectTimeout: _streamConnectionTimeout,
          receiveTimeout: null,
          sendTimeout: _sendTimeout,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final streamLines = response.data!.stream
            .map((Uint8List data) => data as List<int>)
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in streamLines) {
          if (line.startsWith('data: ')) {
            final jsonString = line.substring(6);
            if (jsonString.isNotEmpty) {
              yield jsonDecode(jsonString) as T;
            }
          }
        }
      }
    } catch (e, st) {
      throw _fromException(e, st);
    }
  }
}

ApiResponse<T> _mapResponse<T>(Response<T> response) {
  return ApiResponse<T>(
    statusCode: response.statusCode ?? 0,
    body: response.data as T,
    headers: {
      for (final entry in response.headers.map.entries)
        entry.key: entry.value.join(','),
    },
  );
}

CoreException _fromException(Object e, StackTrace st) {
  if (e is DioException) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => CoreException.timeoutError(
        msg: e.message,
        st: e.stackTrace,
      ),

      DioExceptionType.connectionError => CoreException.networkError(
        msg: e.message,
        st: e.stackTrace,
      ),

      DioExceptionType.badResponse => switch (e.response?.statusCode) {
        401 => CoreException.unauthenticatedError(
          msg: e.message,
          st: e.stackTrace,
        ),
        503 => CoreException.serviceUnavailable(
          msg: e.message,
          st: e.stackTrace,
        ),
        _ => CoreException.serverError(msg: e.message, st: e.stackTrace),
      },

      _ => CoreException.serverError(msg: e.message, st: e.stackTrace),
    };
  }

  return CoreException.fromException(e, st: st);
}
