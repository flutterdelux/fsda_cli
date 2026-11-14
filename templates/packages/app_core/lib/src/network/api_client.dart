import 'api_response.dart';
import 'network_file.dart';

abstract interface class ApiClient {
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Stream<T> stream<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResponse<T>> upload<T>(
    String path, {
    Map<String, String>? fields,
    Map<String, NetworkFile>? files,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
}
