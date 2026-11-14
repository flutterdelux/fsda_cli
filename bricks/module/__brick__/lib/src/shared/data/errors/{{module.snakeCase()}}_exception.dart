import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/errors/{{module.snakeCase()}}_failure.dart';

part '{{module.snakeCase()}}_exception.freezed.dart';

@freezed
sealed class {{module.pascalCase()}}Exception with _${{module.pascalCase()}}Exception implements AppException {
  const {{module.pascalCase()}}Exception._();

  const factory {{module.pascalCase()}}Exception.{{module.camelCase()}}NotFound({
    String? msg,
    StackTrace? st
  }) = _{{module.pascalCase()}}NotFound;

  @override
  String get message => when(
    {{module.camelCase()}}NotFound: (msg, _) => msg ?? '{{module.titleCase()}} not found',
  );

  @override
  StackTrace? get stackTrace => st;

  @override
  Failure toFailure() => when(
    {{module.camelCase()}}NotFound: (_, _) => {{module.pascalCase()}}Failure.{{module.camelCase()}}NotFound,
  );

  static AppException fromApiResponse(ApiResponse response, {StackTrace? st}) {
    if (response.body is Map<String, dynamic>) {
      final code = response.body['code'] as String?;
      final message = response.body['message'] as String?;
      return switch (code) {
        '{{module.constantCase()}}_NOT_FOUND' => {{module.pascalCase()}}Exception.{{module.camelCase()}}NotFound(
          msg: message,
          st: st,
        ),
        _ => CoreException.fromException(response.body.toString(), st: st),
      };
    }
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

