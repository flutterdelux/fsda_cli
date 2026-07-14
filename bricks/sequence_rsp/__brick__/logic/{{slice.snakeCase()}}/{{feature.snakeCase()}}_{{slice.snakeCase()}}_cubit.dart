import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';

import '../../domain/entities/{{feature.snakeCase()}}_entity.dart';
import '../../domain/params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';
import '../../domain/usecases/{{feature.snakeCase()}}_{{slice.snakeCase()}}_use_case.dart';
import '{{feature.snakeCase()}}_{{slice.snakeCase()}}_state.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit extends Cubit<{{feature.pascalCase()}}{{slice.pascalCase()}}State> {
  final {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase _useCase;
  final String _id;

  StreamSubscription<Result<{{feature.pascalCase()}}Entity>>? _subscription;

  {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit({
    required {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase {{feature.camelCase()}}{{slice.pascalCase()}}UseCase,
    required String id,
  }) : _useCase = {{feature.camelCase()}}{{slice.pascalCase()}}UseCase,
       _id = id,
       super(const {{feature.pascalCase()}}{{slice.pascalCase()}}State.initial());

  void {{method.camelCase()}}() {
    emit(const {{feature.pascalCase()}}{{slice.pascalCase()}}State.loading());

    _subscription?.cancel();
    final param = {{feature.pascalCase()}}{{slice.pascalCase()}}Param(id: _id);
    _subscription = _useCase(param).listen(_onData, onError: _onError);
  }

  void _onData(Result<{{feature.pascalCase()}}Entity> result) {
    emit(
      result.when(
        success: (data) => {{feature.pascalCase()}}{{slice.pascalCase()}}State.loaded(data: data),
        failure: (failure) => {{feature.pascalCase()}}{{slice.pascalCase()}}State.failure(failure: failure),
      ),
    );
  }

  void _onError(dynamic e) {
    emit(
      {{feature.pascalCase()}}{{slice.pascalCase()}}State.failure(
        failure: CoreException.fromException(
          e.toString(),
          st: StackTrace.current,
        ).toFailure(),
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
