import 'package:freezed_annotation/freezed_annotation.dart';

import '{{{type_import_logic}}}';

part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_form_state.freezed.dart';

@freezed
abstract class {{feature.pascalCase()}}{{slice.pascalCase()}}FormState with _${{feature.pascalCase()}}{{slice.pascalCase()}}FormState {
  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}FormState({
    {{type.pascalCase()}}? data,
    String? invalidMessage,
  }) = _{{feature.pascalCase()}}{{slice.pascalCase()}}FormState;
}
