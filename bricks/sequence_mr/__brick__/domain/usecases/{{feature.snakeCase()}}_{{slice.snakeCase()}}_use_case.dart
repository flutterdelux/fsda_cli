import 'package:app_core/app_core.dart';

import '../entities/{{feature.snakeCase()}}_entity.dart';
import '../repositories/{{feature.snakeCase()}}_repository.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase extends NoParamUseCase<{{feature.pascalCase()}}Entity> {
  final {{feature.pascalCase()}}Repository _repository;

  const {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase({required {{feature.pascalCase()}}Repository {{feature.snakeCase()}}Repository})
    : _repository = {{feature.snakeCase()}}Repository;

  @override
  AsyncResult<{{feature.pascalCase()}}Entity> call() => _repository.{{method.camelCase()}}();
}
