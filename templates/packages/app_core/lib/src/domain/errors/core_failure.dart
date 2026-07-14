import 'failure.dart';

enum CoreFailure implements Failure {
  unauthenticated,
  serviceUnavailable,
  networkError,
  timeoutError,
  serverError,
  cacheError,
}
