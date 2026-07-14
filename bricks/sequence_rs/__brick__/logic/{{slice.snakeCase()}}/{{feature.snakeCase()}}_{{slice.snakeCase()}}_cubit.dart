import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';

import '../../domain/entities/{{feature.snakeCase()}}_entity.dart';
import '../../domain/usecases/{{feature.snakeCase()}}_{{slice.snakeCase()}}_use_case.dart';
import '{{feature.snakeCase()}}_{{slice.snakeCase()}}_state.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit extends Cubit<{{feature.pascalCase()}}{{slice.pascalCase()}}State> {
  final {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase _useCase;

  StreamSubscription<Result<List<{{feature.pascalCase()}}Entity>>>? _subscription;

  {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit({required {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase {{feature.camelCase()}}{{slice.pascalCase()}}UseCase})
    : _useCase = {{feature.camelCase()}}{{slice.pascalCase()}}UseCase,
      super(const {{feature.pascalCase()}}{{slice.pascalCase()}}State.initial());

  void {{method.camelCase()}}() {
    emit(const {{feature.pascalCase()}}{{slice.pascalCase()}}State.loading());

    _subscription?.cancel();
    _subscription = _useCase().listen(
      (result) {
        emit(
          result.when(
            success: (data) => {{feature.pascalCase()}}{{slice.pascalCase()}}State.loaded(data: data),
            failure: (failure) => {{feature.pascalCase()}}{{slice.pascalCase()}}State.failure(failure: failure),
          ),
        );
      },
      onError: (e) {
        emit(
          {{feature.pascalCase()}}{{slice.pascalCase()}}State.failure(
            failure: CoreException.fromException(
              e.toString(),
              st: StackTrace.current,
            ).toFailure(),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
