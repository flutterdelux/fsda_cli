import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/{{feature.snakeCase()}}_entity.dart';

part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_state.freezed.dart';

@freezed
sealed class {{feature.pascalCase()}}{{slice.pascalCase()}}State with _${{feature.pascalCase()}}{{slice.pascalCase()}}State {
  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}State.initial() = _Initial;
  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}State.loading() = _Loading;
  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}State.success({required {{feature.pascalCase()}}Entity data}) = _Success;
  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}State.failure({required Failure failure}) = _Failure;
}
