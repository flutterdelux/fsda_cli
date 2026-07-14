import 'dart:convert';

abstract final class NetworkHelper {
  static Uri buildUri(
    String baseUrl,
    String path,
    Map<String, dynamic>? queryParameters,
  ) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  static Map<String, String> jsonHeaders(Map<String, String>? headers) {
    return {'Content-Type': 'application/json', ...?headers};
  }

  static Map<String, String> sseHeaders(Map<String, String>? headers) {
    return {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      ...?headers,
    };
  }

  static String? encodeRequestBody(Object? body) {
    if (body == null) return null;

    return jsonEncode(body);
  }
}
