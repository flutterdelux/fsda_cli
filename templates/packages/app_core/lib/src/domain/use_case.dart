import 'dart:async';
import 'result.dart';

abstract class UseCase<T, P> {
  const UseCase();
  AsyncResult<T> call(P param);
}

abstract class NoParamUseCase<T> {
  const NoParamUseCase();
  AsyncResult<T> call();
}

abstract class SyncUseCase<T, P> {
  const SyncUseCase();
  Result<T> call(P param);
}

abstract class NoParamSyncUseCase<T> {
  const NoParamSyncUseCase();
  Result<T> call();
}

abstract class StreamUseCase<T, P> {
  const StreamUseCase();
  Stream<Result<T>> call(P param);
}

abstract class NoParamStreamUseCase<T> {
  const NoParamStreamUseCase();
  Stream<Result<T>> call();
}
