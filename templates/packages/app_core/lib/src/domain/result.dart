import 'package:freezed_annotation/freezed_annotation.dart';
import 'errors/failure.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<T> with _$Result<T> {
  const Result._();

  const factory Result.success(T value) = _Success<T>;
  const factory Result.failure(Failure failure) = _Failure<T>;

  bool get isSuccess => this is _Success<T>;
  bool get isFailure => this is _Failure<T>;

  T? get valueOrNull => when(success: (v) => v, failure: (_) => null);
  Failure? get failureOrNull => when(success: (_) => null, failure: (f) => f);
}

typedef AsyncResult<T> = Future<Result<T>>;
typedef StreamResult<T> = Stream<Result<T>>;
