import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';

import '../../domain/usecases/{{feature.snakeCase()}}_{{slice.snakeCase()}}_use_case.dart';
import '{{feature.snakeCase()}}_{{slice.snakeCase()}}_state.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit extends Cubit<{{feature.pascalCase()}}{{slice.pascalCase()}}State> {
  final {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase _useCase;

  {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit({
    required {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase {{feature.camelCase()}}{{slice.pascalCase()}}UseCase,
  }) : _useCase = {{feature.camelCase()}}{{slice.pascalCase()}}UseCase,
       super(const {{feature.pascalCase()}}{{slice.pascalCase()}}State.initial());

  Future<void> {{method.camelCase()}}() async {
    emit(const {{feature.pascalCase()}}{{slice.pascalCase()}}State.loading());

    final result = await _useCase();

    emit(
      result.when(
        success: (_) => const {{feature.pascalCase()}}{{slice.pascalCase()}}State.success(),
        failure: (failure) => {{feature.pascalCase()}}{{slice.pascalCase()}}State.failure(failure: failure),
      ),
    );
  }
}
