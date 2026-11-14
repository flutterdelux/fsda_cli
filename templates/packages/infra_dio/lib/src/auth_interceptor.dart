import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Future<String?> Function(String path)? _getValidToken;

  AuthInterceptor({Future<String?> Function(String path)? getValidToken})
    : _getValidToken = getValidToken;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_getValidToken != null) {
      final token = await _getValidToken(options.path);

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    return handler.next(options);
  }
}
