abstract final class NetworkTimeoutConfig {
  static const requestTimeout = Duration(seconds: 30);
  static const connectTimeout = Duration(seconds: 15);
  static const sendTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);
  static const streamConnectionTimeout = Duration(seconds: 15);
}
