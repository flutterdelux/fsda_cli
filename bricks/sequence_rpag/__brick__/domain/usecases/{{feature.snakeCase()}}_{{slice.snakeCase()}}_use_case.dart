import 'package:app_core/app_core.dart';

import '../entities/{{feature.snakeCase()}}_entity.dart';
import '../params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';
import '../repositories/{{feature.snakeCase()}}_repository.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase extends UseCase<List<{{feature.pascalCase()}}Entity>, {{feature.pascalCase()}}{{slice.pascalCase()}}Param> {
  final {{feature.pascalCase()}}Repository _repository;

  const {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase({required {{feature.pascalCase()}}Repository {{feature.camelCase()}}Repository})
    : _repository = {{feature.camelCase()}}Repository;

  @override
  AsyncResult<List<{{feature.pascalCase()}}Entity>> call({{feature.pascalCase()}}{{slice.pascalCase()}}Param param) {
    return _repository.{{method.camelCase()}}(param);
  }
}
