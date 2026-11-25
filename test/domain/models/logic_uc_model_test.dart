import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:test/test.dart';

void main() {
  group('LogicUcModel', () {
    test(
      'GIVEN only required parameters without returnType and paramType '
      'WHEN LogicUcModel constructor is called '
      'THEN stores required properties accurately and defaults optional types to null',
      () {
        // Given
        const name = 'DeleteTaskUseCase';
        const path = 'domain/usecases/delete_task_use_case.dart';
        const type = UcType.paramUc;
        const method = 'deleteTask';

        // When
        const model = LogicUcModel(
          name: name,
          path: path,
          type: type,
          repoMethod: method,
        );

        // Then
        expect(model.name, name);
        expect(model.path, path);
        expect(model.type, type);
        expect(model.repoMethod, method);
        expect(model.returnType, isNull);
        expect(model.paramType, isNull);
      },
    );

    test(
      'GIVEN all required and optional parameters including generic and nullable returnType and paramType '
      'WHEN LogicUcModel constructor is called '
      'THEN stores all property values accurately',
      () {
        // Given
        const name = 'GetTaskListUseCase';
        const path = 'domain/usecases/get_task_list_use_case.dart';
        const type = UcType.returnParamUc;
        const method = 'getTaskList';
        const returnType = 'List<TaskEntity>?';
        const paramType = 'GetTaskListParam';

        // When
        const model = LogicUcModel(
          name: name,
          path: path,
          type: type,
          repoMethod: method,
          returnType: returnType,
          paramType: paramType,
        );

        // Then
        expect(model.name, name);
        expect(model.path, path);
        expect(model.type, type);
        expect(model.repoMethod, method);
        expect(model.returnType, returnType);
        expect(model.paramType, paramType);
      },
    );
  });
}
