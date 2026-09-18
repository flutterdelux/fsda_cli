import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';

import '../../domain/params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';
import '../../domain/usecases/{{feature.snakeCase()}}_{{slice.snakeCase()}}_use_case.dart';
import '{{feature.snakeCase()}}_{{slice.snakeCase()}}_state.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit extends Cubit<{{feature.pascalCase()}}{{slice.pascalCase()}}State> {
  final {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase _useCase;

  {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit({required {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase useCase})
    : _useCase = useCase,
      super(const {{feature.pascalCase()}}{{slice.pascalCase()}}State.initial());

  Future<void> {{method.camelCase()}}({{feature.pascalCase()}}{{slice.pascalCase()}}Param param) async {
    emit(const {{feature.pascalCase()}}{{slice.pascalCase()}}State.loading());

    final result = await _useCase(param);

    emit(
      result.when(
        success: (data) => {{feature.pascalCase()}}{{slice.pascalCase()}}State.success(data: data),
        failure: (failure) => {{feature.pascalCase()}}{{slice.pascalCase()}}State.failure(failure: failure),
      ),
    );
  }
}
