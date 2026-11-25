import 'package:fsda_cli/core/extensions/logic_param_x.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  LogicParam createParam({
    StateControl control = StateControl.cubit,
    String featureName = 'task',
    String slice = 'list',
  }) {
    return LogicParam(
      props: const [],
      control: control,
      featureName: featureName,
      moduleName: 'project_management',
      sliceName: slice,
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('LogicParamX', () {
    final expectedLogicSliceDir = p.join(
      '/projects/my_workspace',
      'modules',
      'project_management',
      'lib',
      'src',
      'features',
      'task',
      'logic',
      'list',
    );

    group('Controller Naming & Path Getters', () {
      test(
        'GIVEN a LogicParam instance with StateControl.cubit '
        'WHEN controller getters are accessed '
        'THEN returns snake_case, camelCase, PascalCase, and file path with cubit suffix',
        () {
          // Given
          final param = createParam(control: StateControl.cubit);

          // When & Then
          expect(param.controllerSnake, 'task_list_cubit');
          expect(param.controllerCamel, 'taskListCubit');
          expect(param.controllerPascal, 'TaskListCubit');
          expect(
            param.controllerPath,
            p.join(expectedLogicSliceDir, 'task_list_cubit.dart'),
          );
        },
      );

      test('GIVEN a LogicParam instance with StateControl.getx '
          'WHEN controller getters are accessed '
          'THEN returns names and file path with controller suffix', () {
        // Given
        final param = createParam(control: StateControl.getx);

        // When & Then
        expect(param.controllerSnake, 'task_list_controller');
        expect(param.controllerCamel, 'taskListController');
        expect(param.controllerPascal, 'TaskListController');
        expect(
          param.controllerPath,
          p.join(expectedLogicSliceDir, 'task_list_controller.dart'),
        );
      });

      test(
        'GIVEN LogicParam instances with StateControl.provider and StateControl.riverpod '
        'WHEN controller getters are accessed '
        'THEN returns names and file paths with provider suffix',
        () {
          // Given
          final providerParam = createParam(control: StateControl.provider);
          final riverpodParam = createParam(control: StateControl.riverpod);

          // When & Then
          for (final param in [providerParam, riverpodParam]) {
            expect(param.controllerSnake, 'task_list_provider');
            expect(param.controllerCamel, 'taskListProvider');
            expect(param.controllerPascal, 'TaskListProvider');
            expect(
              param.controllerPath,
              p.join(expectedLogicSliceDir, 'task_list_provider.dart'),
            );
          }
        },
      );
    });

    group('State Naming & Path Getters', () {
      test('GIVEN a LogicParam instance with featureName and slice '
          'WHEN state getters are accessed '
          'THEN returns accurate stateSnake, statePascal, and statePath', () {
        // Given
        final param = createParam(
          featureName: 'user_profile',
          slice: 'avatar_edit',
        );
        final expectedCustomDir = p.join(
          '/projects/my_workspace',
          'modules',
          'project_management',
          'lib',
          'src',
          'features',
          'user_profile',
          'logic',
          'avatar_edit',
        );

        // When & Then
        expect(param.stateSnake, 'user_profile_avatar_edit_state');
        expect(param.statePascal, 'UserProfileAvatarEditState');
        expect(
          param.statePath,
          p.join(expectedCustomDir, 'user_profile_avatar_edit_state.dart'),
        );
      });
    });
  });
}
