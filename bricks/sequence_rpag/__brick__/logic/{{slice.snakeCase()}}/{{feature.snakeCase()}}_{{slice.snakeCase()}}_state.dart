import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/{{feature.snakeCase()}}_entity.dart';
import '../../domain/params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';

part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_state.freezed.dart';

@freezed
abstract class {{feature.pascalCase()}}{{slice.pascalCase()}}State with _${{feature.pascalCase()}}{{slice.pascalCase()}}State {
  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}State({
    @Default([]) List<{{feature.pascalCase()}}Entity> list,
    @Default(false) bool hasReachedMax,
    @Default(false) bool isLoading,
    Failure? failure,
    @Default({{feature.pascalCase()}}{{slice.pascalCase()}}Param()) {{feature.pascalCase()}}{{slice.pascalCase()}}Param param,
  }) = _{{feature.pascalCase()}}{{slice.pascalCase()}}State;
}
