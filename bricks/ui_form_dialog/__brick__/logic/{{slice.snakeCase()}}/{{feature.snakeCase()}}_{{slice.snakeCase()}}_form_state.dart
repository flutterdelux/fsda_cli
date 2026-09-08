import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';

part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_form_state.freezed.dart';

@freezed
abstract class {{feature.pascalCase()}}{{slice.pascalCase()}}FormState with _${{feature.pascalCase()}}{{slice.pascalCase()}}FormState {
  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}FormState({
    {{feature.pascalCase()}}{{slice.pascalCase()}}Param? param,
    String? invalidMessage,
  }) = _{{feature.pascalCase()}}{{slice.pascalCase()}}FormState;
}
