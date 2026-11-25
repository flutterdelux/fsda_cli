import 'package:fsda_cli/core/extensions/slice_param_x.dart';
import 'package:fsda_cli/domain/params/slice_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('SliceGateParamX', () {
    const param = SliceParam(
      sliceName: 'task_detail_view',
      featureName: 'task',
      moduleName: 'project_management',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );

    test(
      'GIVEN a SliceGateParam instance with snake_case slice '
      'WHEN case-conversion getters are accessed '
      'THEN returns snake_case, camelCase, PascalCase, and Title Case variants accurately',
      () {
        // When & Then
        expect(param.sliceSnake, 'task_detail_view');
        expect(param.sliceCamel, 'taskDetailView');
        expect(param.slicePascal, 'TaskDetailView');
        expect(param.sliceTitle, 'Task Detail View');
      },
    );

    test(
      'GIVEN a SliceGateParam instance '
      'WHEN logicSlicePath and uiSlicePath getters are accessed '
      'THEN returns joined logic and ui slice directories under featurePath',
      () {
        // Given
        final expectedFeaturePath = p.join(
          '/projects/my_workspace',
          'modules',
          'project_management',
          'lib',
          'src',
          'features',
          'task',
        );

        // When & Then
        expect(
          param.logicSlicePath,
          p.join(expectedFeaturePath, 'logic', 'task_detail_view'),
        );
        expect(
          param.uiSlicePath,
          p.join(expectedFeaturePath, 'ui', 'task_detail_view'),
        );
      },
    );
  });
}
