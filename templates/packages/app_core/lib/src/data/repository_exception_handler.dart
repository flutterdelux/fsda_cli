import '../domain/errors/core_failure.dart';
import '../domain/errors/failure.dart';
import '../domain/result.dart';
import '../logging/app_logger.dart';
import 'errors/app_exception.dart';

mixin RepositoryExceptionHandler {
  AppLogger get log;
  bool get isLocal => false;

  Failure get defaultFailure =>
      isLocal ? CoreFailure.cacheError : CoreFailure.serverError;

  Result<T> handleException<T>(String methodName, Object e, StackTrace st) {
    if (e is AppException) {
      log.warning('$methodName: ${e.message}', error: e, stackTrace: st);
      return Result.failure(e.toFailure());
    }

    log.error(methodName, error: e, stackTrace: st);
    return Result.failure(defaultFailure);
  }
}
