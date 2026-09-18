import 'package:app_core/app_core.dart';

import '../entities/{{model.snakeCase()}}_entity.dart';
import '../params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';
import '../repositories/{{feature.snakeCase()}}_repository.dart';

{{#is_list}}
class {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase
  extends UseCase<List<{{model.pascalCase()}}Entity>, {{feature.pascalCase()}}{{slice.pascalCase()}}Param> {
{{/is_list}}
{{^is_list}}
class {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase
  extends UseCase<{{model.pascalCase()}}Entity, {{feature.pascalCase()}}{{slice.pascalCase()}}Param> {
{{/is_list}}
  final {{feature.pascalCase()}}Repository _repository;

  const {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase({required {{feature.pascalCase()}}Repository {{feature.camelCase()}}Repository})
    : _repository = {{feature.camelCase()}}Repository;

  @override
  {{#is_list}}
  AsyncResult<List<{{model.pascalCase()}}Entity>> call({{feature.pascalCase()}}{{slice.pascalCase()}}Param param) =>
      _repository.{{method.camelCase()}}(param);
  {{/is_list}}
  {{^is_list}}
  AsyncResult<{{model.pascalCase()}}Entity> call({{feature.pascalCase()}}{{slice.pascalCase()}}Param param) =>
      _repository.{{method.camelCase()}}(param);
  {{/is_list}}
}