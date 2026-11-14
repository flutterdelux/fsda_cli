import 'dart:async';
import 'result.dart';

/// ============ Deprecated ============

@Deprecated('Use ReturnParamUseCase<T, P> instead.')
abstract class UseCase<T, P> {
  const UseCase();
  AsyncResult<T> call(P param);
}

@Deprecated('Use ReturnUseCase<T> instead.')
abstract class NoParamUseCase<T> {
  const NoParamUseCase();
  AsyncResult<T> call();
}

@Deprecated('Use ReturnParamSyncUseCase<T, P> instead.')
abstract class SyncUseCase<T, P> {
  const SyncUseCase();
  Result<T> call(P param);
}

@Deprecated('Use ReturnSyncUseCase<T> instead.')
abstract class NoParamSyncUseCase<T> {
  const NoParamSyncUseCase();
  Result<T> call();
}

@Deprecated('Use ReturnParamStreamUseCase<T, P> instead.')
abstract class StreamUseCase<T, P> {
  const StreamUseCase();
  Stream<Result<T>> call(P param);
}

@Deprecated('Use ReturnStreamUseCase<T> instead.')
abstract class NoParamStreamUseCase<T> {
  const NoParamStreamUseCase();
  Stream<Result<T>> call();
}

/// ============ New Async ============

abstract class VoidUseCase {
  const VoidUseCase();
  AsyncResult<void> call();
}

abstract class ParamUseCase<P> {
  const ParamUseCase();
  AsyncResult<void> call(P param);
}

abstract class ReturnUseCase<T> {
  const ReturnUseCase();
  AsyncResult<T> call();
}

abstract class ReturnParamUseCase<T, P> {
  const ReturnParamUseCase();
  AsyncResult<T> call(P param);
}

/// ============ New Sync ============

abstract class VoidSyncUseCase {
  const VoidSyncUseCase();
  Result<void> call();
}

abstract class ParamSyncUseCase<P> {
  const ParamSyncUseCase();
  Result<void> call(P param);
}

abstract class ReturnSyncUseCase<T> {
  const ReturnSyncUseCase();
  Result<T> call();
}

abstract class ReturnParamSyncUseCase<T, P> {
  const ReturnParamSyncUseCase();
  Result<T> call(P param);
}

/// ============ New Stream ============

abstract class VoidStreamUseCase {
  const VoidStreamUseCase();
  Stream<Result<void>> call();
}

abstract class ParamStreamUseCase<P> {
  const ParamStreamUseCase();
  Stream<Result<void>> call(P param);
}

abstract class ReturnStreamUseCase<T> {
  const ReturnStreamUseCase();
  Stream<Result<T>> call();
}

abstract class ReturnParamStreamUseCase<T, P> {
  const ReturnParamStreamUseCase();
  Stream<Result<T>> call(P param);
}
