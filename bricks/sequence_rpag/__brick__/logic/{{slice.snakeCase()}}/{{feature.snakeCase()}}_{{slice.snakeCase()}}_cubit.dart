import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';

import '../../domain/usecases/{{feature.snakeCase()}}_{{slice.snakeCase()}}_use_case.dart';
import '{{feature.snakeCase()}}_{{slice.snakeCase()}}_state.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit extends Cubit<{{feature.pascalCase()}}{{slice.pascalCase()}}State> {
  final {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase _useCase;

  {{feature.pascalCase()}}{{slice.pascalCase()}}Cubit({required {{feature.pascalCase()}}{{slice.pascalCase()}}UseCase {{feature.camelCase()}}{{slice.pascalCase()}}UseCase})
    : _useCase = {{feature.camelCase()}}{{slice.pascalCase()}}UseCase,
      super(const {{feature.pascalCase()}}{{slice.pascalCase()}}State());

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    await _getData(page: 1);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasReachedMax) return;
    await _getData(page: state.param.page + 1);
  }

  Future<void> _getData({required int page}) async {
    emit(
      state.copyWith(
        isLoading: true,
        failure: null,
        list: page == 1 ? [] : state.list,
      ),
    );

    final selectedParam = state.param.copyWith(page: page);
    final result = await _useCase(selectedParam);

    emit(
      result.when(
        success: (data) => state.copyWith(
          list: [...state.list, ...data],
          hasReachedMax: data.length < state.param.pageSize,
          isLoading: false,
          param: selectedParam,
        ),
        failure: (failure) =>
            state.copyWith(isLoading: false, failure: failure),
      ),
    );
  }
}
