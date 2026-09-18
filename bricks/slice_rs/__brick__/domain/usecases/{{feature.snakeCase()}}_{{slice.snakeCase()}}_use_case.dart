import 'package:app_core/app_core.dart';

import '../entities/{{model.snakeCase()}}_entity.dart';
import '../repositories/{{feature.snakeCase()}}_repository.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase
{{#is_list}} extends NoParamStreamUseCase<List<{{model.pascalCase()}}Entity>> { {{/is_list}}
{{^is_list}} extends NoParamStreamUseCase<{{model.pascalCase()}}Entity> { {{/is_list}}
  final {{feature.pascalCase()}}Repository _repository;

  const {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase({
    required {{feature.pascalCase()}}Repository {{feature.camelCase()}}Repository,
  }) : _repository = {{feature.camelCase()}}Repository;

  @override
  {{#is_list}}StreamResult<List<{{model.pascalCase()}}Entity>> call() =>{{/is_list}}
  {{^is_list}}StreamResult<{{model.pascalCase()}}Entity> call() =>{{/is_list}}
      _repository.{{method.camelCase()}}();
}
