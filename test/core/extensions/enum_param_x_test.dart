import 'package:fsda_cli/core/extensions/enum_param_x.dart';
import 'package:fsda_cli/domain/params/enum_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('EnumParamX', () {
    const param = EnumParam(
      enumName: 'task_status',
      values: ['todo', 'in_progress', 'completed'],
      isLower: true,
      featureName: 'task',
      moduleName: 'project_management',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );

    final expectedFeaturePath = p.join(
      '/projects/my_workspace',
      'modules',
      'project_management',
      'lib',
      'src',
      'features',
      'task',
    );

    group('Enum Naming & Path Getters', () {
      test(
        'GIVEN an EnumParam instance with snake_case enumName '
        'WHEN enum case-conversion and path getters are accessed '
        'THEN returns accurate snake_case, camelCase, PascalCase, Title Case, and domain enum path',
        () {
          // When & Then
          expect(param.enumSnake, 'task_status');
          expect(param.enumCamel, 'taskStatus');
          expect(param.enumPascal, 'TaskStatus');
          expect(param.enumTitle, 'Task Status');
          expect(
            param.enumPath,
            p.join(expectedFeaturePath, 'domain', 'enums', 'task_status.dart'),
          );
        },
      );
    });

    group('Converter Naming & Path Getters', () {
      test(
        'GIVEN an EnumParam instance '
        'WHEN converter getters are accessed '
        'THEN returns accurate <enumName>_converter names and data converter path',
        () {
          // When & Then
          expect(param.converterSnake, 'task_status_converter');
          expect(param.converterCamel, 'taskStatusConverter');
          expect(param.converterPascal, 'TaskStatusConverter');
          expect(
            param.converterPath,
            p.join(
              expectedFeaturePath,
              'data',
              'converters',
              'task_status_converter.dart',
            ),
          );
        },
      );
    });

    group('Extension Naming & Path Getters', () {
      test(
        'GIVEN an EnumParam instance '
        'WHEN extension getters are accessed '
        'THEN returns accurate <enumName>_x names and ui shared extension path',
        () {
          // When & Then
          expect(param.extensionSnake, 'task_status_x');
          expect(param.extensionCamel, 'taskStatusX');
          expect(param.extensionPascal, 'TaskStatusX');
          expect(
            param.extensionPath,
            p.join(
              expectedFeaturePath,
              'ui',
              'shared',
              'extensions',
              'task_status_x.dart',
            ),
          );
        },
      );
    });
  });
}
