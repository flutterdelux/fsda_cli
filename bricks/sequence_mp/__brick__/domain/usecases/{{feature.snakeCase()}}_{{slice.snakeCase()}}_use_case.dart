import 'package:app_core/app_core.dart';

import '../params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';
import '../repositories/{{feature.snakeCase()}}_repository.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase extends UseCase<void, {{feature.pascalCase()}}{{slice.pascalCase()}}Param> {
  final {{feature.pascalCase()}}Repository _repository;

  const {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase({required {{feature.pascalCase()}}Repository {{feature.snakeCase()}}Repository})
    : _repository = {{feature.snakeCase()}}Repository;

  @override
  AsyncResult<void> call({{feature.pascalCase()}}{{slice.pascalCase()}}Param param) {
    return _repository.{{method.camelCase()}}(param);
  }
}
