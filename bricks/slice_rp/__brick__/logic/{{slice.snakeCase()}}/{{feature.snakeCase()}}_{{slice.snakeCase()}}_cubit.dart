import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';

import '../../domain/params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';
import '../../domain/usecases/{{feature.snakeCase()}}_{{slice.snakeCase()}}_use_case.dart';
import '{{feature.snakeCase()}}_{{slice.snakeCase()}}_state.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit extends Cubit<{{feature.pascalCase()}}{{slice.pascalCase()}}State> {
  final {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase _useCase;
  final {{feature.pascalCase()}}{{slice.pascalCase()}}Param _param;

  {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit({
    required {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase {{feature.camelCase()}}{{slice.pascalCase()}}UseCase,
    required {{feature.pascalCase()}}{{slice.pascalCase()}}Param param,
  }) : _useCase = {{feature.camelCase()}}{{slice.pascalCase()}}UseCase,
       _param = param,
       super(const {{feature.pascalCase()}}{{slice.pascalCase()}}State.initial());

  Future<void> {{method.camelCase()}}() async {
    emit(const {{feature.pascalCase()}}{{slice.pascalCase()}}State.loading());

    final result = await _useCase(_param);

    emit(
      result.when(
        success: (data) => {{feature.pascalCase()}}{{slice.pascalCase()}}State.loaded(data: data),
        failure: (failure) => {{feature.pascalCase()}}{{slice.pascalCase()}}State.failure(failure: failure),
      ),
    );
  }
}
