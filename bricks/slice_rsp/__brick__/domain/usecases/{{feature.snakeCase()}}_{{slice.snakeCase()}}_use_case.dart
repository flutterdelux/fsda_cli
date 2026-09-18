import 'package:app_core/app_core.dart';

import '../entities/{{model.snakeCase()}}_entity.dart';
import '../params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';
import '../repositories/{{feature.snakeCase()}}_repository.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase
  {{#is_list}}  extends StreamUseCase<List<{{model.pascalCase()}}Entity>, {{feature.pascalCase()}}{{slice.pascalCase()}}Param> { {{/is_list}}
  {{^is_list}}  extends StreamUseCase<{{model.pascalCase()}}Entity, {{feature.pascalCase()}}{{slice.pascalCase()}}Param> { {{/is_list}}
  final {{feature.pascalCase()}}Repository _repository;

  const {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase({required {{feature.pascalCase()}}Repository {{feature.camelCase()}}Repository})
    : _repository = {{feature.camelCase()}}Repository;

  @override
  {{#is_list}}StreamResult<List<{{model.pascalCase()}}Entity>> call({{feature.pascalCase()}}{{slice.pascalCase()}}Param param) { {{/is_list}}
  {{^is_list}}StreamResult<{{model.pascalCase()}}Entity> call({{feature.pascalCase()}}{{slice.pascalCase()}}Param param) { {{/is_list}}
    return _repository.{{method.camelCase()}}(param);
  }
}
