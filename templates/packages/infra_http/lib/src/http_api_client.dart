import 'dart:convert';

import 'package:app_core/app_core.dart';
import 'package:http/http.dart';

class HttpApiClient implements ApiClient {
  static const instanceName = 'HttpApiClient';

  final Client _client;
  final String _baseUrl;
  final Duration _requestTimeout;
  final Duration _streamConnectionTimeout;
  final Future<String?> Function(String path)? _getValidToken;

  const HttpApiClient({
    required Client client,
    required String baseUrl,
    Duration requestTimeout = const Duration(seconds: 30),
    Duration streamConnectionTimeout = const Duration(seconds: 15),
    final Future<String?> Function(String path)? getValidToken,
  }) : _client = client,
       _baseUrl = baseUrl,
       _requestTimeout = requestTimeout,
       _streamConnectionTimeout = streamConnectionTimeout,
       _getValidToken = getValidToken;

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _performRequest(path, (authHeaders) {
        return _client
            .get(
              NetworkHelper.buildUri(_baseUrl, path, queryParameters),
              headers: NetworkHelper.jsonHeaders(authHeaders),
            )
            .timeout(_requestTimeout);
      }, headers);

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
      final response = await _performRequest(path, (authHeaders) {
        return _client
            .post(
              NetworkHelper.buildUri(_baseUrl, path, queryParameters),
              headers: NetworkHelper.jsonHeaders(authHeaders),
              body: NetworkHelper.encodeRequestBody(body),
            )
            .timeout(_requestTimeout);
      }, headers);

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
      final response = await _performRequest(path, (authHeaders) {
        return _client
            .put(
              NetworkHelper.buildUri(_baseUrl, path, queryParameters),
              headers: NetworkHelper.jsonHeaders(authHeaders),
              body: NetworkHelper.encodeRequestBody(body),
            )
            .timeout(_requestTimeout);
      }, headers);

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
      final response = await _performRequest(path, (authHeaders) {
        return _client
            .patch(
              NetworkHelper.buildUri(_baseUrl, path, queryParameters),
              headers: NetworkHelper.jsonHeaders(authHeaders),
              body: NetworkHelper.encodeRequestBody(body),
            )
            .timeout(_requestTimeout);
      }, headers);
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
      final response = await _performRequest(path, (authHeaders) {
        return _client
            .delete(
              NetworkHelper.buildUri(_baseUrl, path, queryParameters),
              headers: NetworkHelper.jsonHeaders(authHeaders),
              body: NetworkHelper.encodeRequestBody(body),
            )
            .timeout(_requestTimeout);
      }, headers);

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

  @override
  Future<ApiResponse<T>> upload<T>(
    String path, {
    Map<String, String>? fields,
    Map<String, NetworkFile>? files,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = NetworkHelper.buildUri(_baseUrl, path, queryParameters);

      final responseStream = await _performRequest(path, (authHeaders) async {
        final request = MultipartRequest('POST', uri);

        request.headers.addAll(NetworkHelper.jsonHeaders(authHeaders));
        if (headers != null) request.headers.addAll(headers);

        if (fields != null) request.fields.addAll(fields);

        if (files != null) {
          for (final entry in files.entries) {
            request.files.add(
              MultipartFile.fromBytes(
                entry.key,
                entry.value.bytes,
                filename: entry.value.name,
              ),
            );
          }
        }

        final streamedResponse = await _client
            .send(request)
            .timeout(_requestTimeout);
        return await Response.fromStream(streamedResponse);
      }, headers);

      return _mapResponse<T>(responseStream);
    } catch (e, st) {
      throw CoreException.fromException(e, st: st);
    }
  }

  Future<Response> _performRequest(
    String path,
    Future<Response> Function(Map<String, String> headers) requestCall,
    Map<String, String>? headers,
  ) async {
    final reqHeaders = Map<String, String>.from(headers ?? {});

    if (_getValidToken != null) {
      final token = await _getValidToken(path);
      if (token != null && token.isNotEmpty) {
        reqHeaders['Authorization'] = 'Bearer $token';
      }
    }

    return await requestCall(reqHeaders);
  }
}

ApiResponse<T> _mapResponse<T>(Response response) {
  return ApiResponse<T>(
    statusCode: response.statusCode,
    body: jsonDecode(response.body) as T,
    headers: response.headers,
  );
}
