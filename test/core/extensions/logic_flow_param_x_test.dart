import 'package:fsda_cli/core/extensions/logic_flow_param_x.dart';
import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  LogicFlowParam createParam({
    StateControl control = StateControl.cubit,
    String featureName = 'task',
    String slice = 'list',
    String uc = 'task_list_get_use_case.dart',
  }) {
    return LogicFlowParam(
      type: LogicFlowType.retrieval,
      uc: uc,
      control: control,
      featureName: featureName,
      moduleName: 'project_management',
      sliceName: slice,
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('LogicFlowParamX', () {
    final expectedFeatureDir = p.join(
      '/projects/my_workspace',
      'modules',
      'project_management',
      'lib',
      'src',
      'features',
      'task',
    );
    final expectedLogicSliceDir = p.join(expectedFeatureDir, 'logic', 'list');

    group('Controller Naming & Path Getters (<feature><slice><context>)', () {
      test(
        'GIVEN a LogicFlowParam instance with StateControl.cubit '
        'WHEN controller getters are accessed '
        'THEN returns <feature>_<slice>_cubit names and logicSlicePath file path',
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

      test(
        'GIVEN a LogicFlowParam instance with StateControl.getx '
        'WHEN controller getters are accessed '
        'THEN returns <feature>_<slice>_controller names and logicSlicePath file path',
        () {
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
        },
      );

      test(
        'GIVEN LogicFlowParam instances with StateControl.provider and StateControl.riverpod '
        'WHEN controller getters are accessed '
        'THEN returns <feature>_<slice>_provider names and logicSlicePath file paths',
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

    group('State Naming & Path Getters (<feature><slice><context>)', () {
      test(
        'GIVEN a LogicFlowParam instance with featureName and slice '
        'WHEN state getters are accessed '
        'THEN returns <feature>_<slice>_state names and uiSlicePath file path',
        () {
          // Given
          final param = createParam(
            featureName: 'user_profile',
            slice: 'edit_avatar',
          );
          final expectedLogicSliceDir = p.join(
            '/projects/my_workspace',
            'modules',
            'project_management',
            'lib',
            'src',
            'features',
            'user_profile',
            'logic',
            'edit_avatar',
          );

          // When & Then
          expect(param.stateSnake, 'user_profile_edit_avatar_state');
          expect(param.statePascal, 'UserProfileEditAvatarState');
          expect(
            param.statePath,
            p.join(
              expectedLogicSliceDir,
              'user_profile_edit_avatar_state.dart',
            ),
          );
        },
      );
    });

    group('UseCase Path Getter', () {
      test('GIVEN a LogicFlowParam instance with uc file name '
          'WHEN ucPath is accessed '
          'THEN returns full path inside domain/usecases', () {
        // Given
        final param = createParam(uc: 'task_create_use_case');

        // When & Then
        expect(
          param.ucPath,
          p.join(
            expectedFeatureDir,
            'domain',
            'usecases',
            'task_create_use_case.dart',
          ),
        );
      });
    });
  });
}
