import 'package:bloc/bloc.dart';

import '../../domain/params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';
import '{{feature.snakeCase()}}_{{slice.snakeCase()}}_form_state.dart';

class {{feature.pascalCase()}}{{slice.pascalCase()}}FormCubit extends Cubit<{{feature.pascalCase()}}{{slice.pascalCase()}}FormState> {
  {{feature.pascalCase()}}{{slice.pascalCase()}}FormCubit() : super(const {{feature.pascalCase()}}{{slice.pascalCase()}}FormState());

  void update({{feature.pascalCase()}}{{slice.pascalCase()}}Param? param, String? invalidMessage) {
    emit(state.copyWith(param: param, invalidMessage: invalidMessage));
  }
}
