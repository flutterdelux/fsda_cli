import 'package:fsda_cli/core/extensions/model_param_x.dart';
import 'package:fsda_cli/domain/enums/model_type.dart';
import 'package:fsda_cli/domain/params/model_param.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  ModelParam createParam({required String modelName, required ModelType type}) {
    return ModelParam(
      modelName: modelName,
      type: type,
      props: const [],
      featureName: 'task',
      moduleName: 'project_management',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('ModelParamX', () {
    final expectedFeaturePath = p.join(
      '/projects/my_workspace',
      'modules',
      'project_management',
      'lib',
      'src',
      'features',
      'task',
    );

    group('Naming Getters (name* & baseName*)', () {
      test(
        'GIVEN a multi-word snake_case modelName '
        'WHEN name and baseName getters are accessed '
        'THEN returns accurate snake, camel, pascal, and title case variants',
        () {
          // Given
          final param = createParam(
            modelName: 'user_profile_create_param',
            type: ModelType.param,
          );

          // When & Then
          expect(param.nameSnake, 'user_profile_create_param');
          expect(param.nameCamel, 'userProfileCreateParam');
          expect(param.namePascal, 'UserProfileCreateParam');
          expect(param.nameTitle, 'User Profile Create Param');

          expect(param.baseNameSnake, 'user_profile_create');
          expect(param.baseNameCamel, 'userProfileCreate');
          expect(param.baseNamePascal, 'UserProfileCreate');
          expect(param.baseNameTitle, 'User Profile Create');
        },
      );
    });

    group('modelPath Resolution', () {
      test('GIVEN ModelParam instances across all ModelType values '
          'WHEN modelPath getter is accessed '
          'THEN resolves the matching layer directory and file path', () {
        // Given
        final cases = <(String, ModelType, String)>[
          ('task_entity', ModelType.entity, 'domain/entities'),
          ('task_create_param', ModelType.param, 'domain/params'),
          ('task_dto', ModelType.dto, 'data/dtos'),
          ('task_create_request', ModelType.request, 'data/requests'),
          ('task_response', ModelType.response, 'data/responses'),
        ];

        // When & Then
        for (final (modelName, type, expectedSubDir) in cases) {
          final param = createParam(modelName: modelName, type: type);

          expect(
            param.modelPath,
            p.join(expectedFeaturePath, expectedSubDir, '$modelName.dart'),
          );
        }
      });
    });
  });
}
