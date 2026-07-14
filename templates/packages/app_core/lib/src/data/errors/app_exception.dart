import '../../domain/errors/failure.dart';

abstract interface class AppException implements Exception {
  String get message;
  StackTrace? get stackTrace;
  Failure toFailure();
}
