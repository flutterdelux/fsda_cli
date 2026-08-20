import 'failure.dart';

enum CoreFailure implements Failure {
  unauthenticated,
  unauthorized,
  serviceUnavailable,
  networkError,
  timeoutError,
  serverError,
  cacheError,
}
