import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/errors/{{module.snakeCase()}}_failure.dart';

part '{{module.snakeCase()}}_exception.freezed.dart';

@freezed
sealed class {{module.pascalCase()}}Exception with _${{module.pascalCase()}}Exception implements AppException {
  const {{module.pascalCase()}}Exception._();

  const factory {{module.pascalCase()}}Exception.{{module.camelCase()}}NotFound({String? msg, StackTrace? st}) =
      _{{module.pascalCase()}}NotFound;

  @override
  String get message => when({{module.camelCase()}}NotFound: (msg, _) => msg ?? '{{module.pascalCase()}} not found');

  @override
  StackTrace? get stackTrace => st;

  @override
  Failure toFailure() => when({{module.camelCase()}}NotFound: (_, _) => {{module.pascalCase()}}Failure.{{module.camelCase()}}NotFound);

  static AppException fromApiResponse(ApiResponse response, {StackTrace? st}) {
    return CoreException.fromException(response.body.toString(), st: st);
  }

  static AppException fromException(
    Object e, {
    StackTrace? st,
    bool isLocal = false,
  }) {
    if (e is AppException) {
      return e;
    }

    return CoreException.fromException(e, st: st, isLocal: isLocal);
  }
}
