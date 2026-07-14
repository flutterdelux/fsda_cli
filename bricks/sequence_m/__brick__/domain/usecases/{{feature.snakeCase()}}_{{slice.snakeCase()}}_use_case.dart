import 'package:app_core/app_core.dart';

import '../repositories/{{feature.snakeCase()}}_repository.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase extends NoParamUseCase<void> {
  final {{feature.pascalCase()}}Repository _repository;

  const {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase({required {{feature.pascalCase()}}Repository {{feature.snakeCase()}}Repository})
    : _repository = {{feature.snakeCase()}}Repository;

  @override
  AsyncResult<void> call() => _repository.{{method.camelCase()}}();
}
