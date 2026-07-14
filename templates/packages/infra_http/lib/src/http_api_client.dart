import 'dart:convert';

import 'package:app_core/app_core.dart';
import 'package:http/http.dart';

class HttpApiClient implements ApiClient {
  static const instanceName = 'HttpApiClient';

  final Client _client;
  final String _baseUrl;
  final Duration _requestTimeout;
  final Duration _streamConnectionTimeout;

  const HttpApiClient({
    required Client client,
    required String baseUrl,
    Duration requestTimeout = const Duration(seconds: 30),
    Duration streamConnectionTimeout = const Duration(seconds: 15),
  }) : _client = client,
       _baseUrl = baseUrl,
       _requestTimeout = requestTimeout,
       _streamConnectionTimeout = streamConnectionTimeout;

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .get(
            NetworkHelper.buildUri(_baseUrl, path, queryParameters),
            headers: NetworkHelper.jsonHeaders(headers),
          )
          .timeout(_requestTimeout);

      return _mapResponse<T>(response);
    } catch (e, st) {
      throw CoreException.fromException(e, st: st);
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
      final response = await _client
          .post(
            NetworkHelper.buildUri(_baseUrl, path, queryParameters),
            headers: NetworkHelper.jsonHeaders(headers),
            body: NetworkHelper.encodeRequestBody(body),
          )
          .timeout(_requestTimeout);

      return _mapResponse<T>(response);
    } catch (e, st) {
      throw CoreException.fromException(e, st: st);
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
      final response = await _client
          .put(
            NetworkHelper.buildUri(_baseUrl, path, queryParameters),
            headers: NetworkHelper.jsonHeaders(headers),
            body: NetworkHelper.encodeRequestBody(body),
          )
          .timeout(_requestTimeout);

      return _mapResponse<T>(response);
    } catch (e, st) {
      throw CoreException.fromException(e, st: st);
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
      final response = await _client
          .patch(
            NetworkHelper.buildUri(_baseUrl, path, queryParameters),
            headers: NetworkHelper.jsonHeaders(headers),
            body: NetworkHelper.encodeRequestBody(body),
          )
          .timeout(_requestTimeout);
      return _mapResponse<T>(response);
    } catch (e, st) {
      throw CoreException.fromException(e, st: st);
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
      final response = await _client
          .delete(
            NetworkHelper.buildUri(_baseUrl, path, queryParameters),
            headers: NetworkHelper.jsonHeaders(headers),
            body: NetworkHelper.encodeRequestBody(body),
          )
          .timeout(_requestTimeout);

      return _mapResponse<T>(response);
    } catch (e, st) {
      throw CoreException.fromException(e, st: st);
    }
  }

  @override
  Stream<T> stream<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async* {
    try {
      final uri = NetworkHelper.buildUri(_baseUrl, path, queryParameters);

      final request = Request('GET', uri);
      request.headers.addAll(NetworkHelper.sseHeaders(headers));

      final response = await _client
          .send(request)
          .timeout(_streamConnectionTimeout);

      if (response.statusCode == 200) {
        final streamLines = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in streamLines) {
          final trimmedLine = line.trim();

          if (trimmedLine.startsWith('data: ')) {
            final jsonString = trimmedLine.substring(6).trim();
            if (jsonString.isNotEmpty) {
              yield jsonDecode(jsonString) as T;
            }
          }
        }
      } else {
        throw CoreException.serverError(
          msg: 'Stream failed with status code: ${response.statusCode}',
        );
      }
    } on AppException {
      rethrow;
    } catch (e, st) {
      throw CoreException.fromException(e, st: st);
    }
  }
}

ApiResponse<T> _mapResponse<T>(Response response) {
  return ApiResponse<T>(
    statusCode: response.statusCode,
    body: jsonDecode(response.body) as T,
    headers: response.headers,
  );
}
