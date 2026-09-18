import 'package:app_core/app_core.dart';

import '../entities/{{model.snakeCase()}}_entity.dart';
import '../repositories/{{feature.snakeCase()}}_repository.dart';

{{#is_list}}class {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase
    extends NoParamUseCase<List<{{model.pascalCase()}}Entity>> { {{/is_list}}
{{^is_list}}class {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase
    extends NoParamUseCase<{{model.pascalCase()}}Entity> { {{/is_list}}
  final {{feature.pascalCase()}}Repository _repository;

  const {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase({
    required {{feature.pascalCase()}}Repository {{feature.camelCase()}}Repository,
  }) : _repository = {{feature.camelCase()}}Repository;

  @override
  {{#is_list}}AsyncResult<List<{{model.pascalCase()}}Entity>> call() =>{{/is_list}}
  {{^is_list}}AsyncResult<{{model.pascalCase()}}Entity> call() =>{{/is_list}}
      _repository.{{method.camelCase()}}();
}