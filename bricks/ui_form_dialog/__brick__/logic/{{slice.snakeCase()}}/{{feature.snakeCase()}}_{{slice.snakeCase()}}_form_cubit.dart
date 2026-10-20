import 'package:bloc/bloc.dart';

import '{{{type_import_logic}}}';

import '{{feature.snakeCase()}}_{{slice.snakeCase()}}_form_state.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}FormCubit extends Cubit<{{feature.pascalCase()}}{{slice.pascalCase()}}FormState> {
  {{feature.pascalCase()}}{{slice.pascalCase()}}FormCubit() : super(const {{feature.pascalCase()}}{{slice.pascalCase()}}FormState());

  void update({{type.pascalCase()}}? data, String? invalidMessage) {
    emit(state.copyWith(data: data, invalidMessage: invalidMessage));
  }
}
