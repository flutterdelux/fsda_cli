import 'package:app_core/app_core.dart';

import '../entities/{{feature.snakeCase()}}_entity.dart';
import '../repositories/{{feature.snakeCase()}}_repository.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase extends NoParamUseCase<List<{{feature.pascalCase()}}Entity>> {
  final {{feature.pascalCase()}}Repository _repository;

  const {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase({required {{feature.pascalCase()}}Repository {{feature.camelCase()}}Repository})
    : _repository = {{feature.camelCase()}}Repository;

  @override
  AsyncResult<List<{{feature.pascalCase()}}Entity>> call() => _repository.{{method.camelCase()}}();
}
