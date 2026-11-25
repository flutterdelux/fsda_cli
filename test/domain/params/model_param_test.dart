import 'package:fsda_cli/domain/enums/model_type.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/model_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('ModelParam', () {
    const sampleProps = [
      PropModel(
        type: 'String',
        name: 'title',
        defaultValue: "''",
        converter: '',
      ),
      PropModel(
        type: 'int',
        name: 'priority',
        defaultValue: '0',
        converter: '',
      ),
    ];

    group('Primary Constructor', () {
      test(
        'GIVEN valid modelName, type, props, and feature hierarchy parameters without isL10n '
        'WHEN ModelParam primary constructor is called '
        'THEN sets isL10n to false by default and extends FeatureParam hierarchy',
        () {
          // Given
          const modelName = 'task_entity';
          const type = ModelType.entity;
          const featureName = 'task';
          const moduleName = 'project_management';
          const workspaceName = 'my_workspace';
          const workspacePath = '/projects/my_workspace';

          // When
          const param = ModelParam(
            modelName: modelName,
            type: type,
            props: sampleProps,
            featureName: featureName,
            moduleName: moduleName,
            workspaceName: workspaceName,
            workspacePath: workspacePath,
          );

          // Then
          expect(param, isA<FeatureParam>());
          expect(param, isA<ModuleParam>());
          expect(param, isA<WorkspaceParam>());
          expect(param.modelName, modelName);
          expect(param.type, type);
          expect(param.props, sampleProps);
          expect(param.isL10n, isFalse);
          expect(param.featureName, featureName);
          expect(param.moduleName, moduleName);
          expect(param.workspaceName, workspaceName);
          expect(param.workspacePath, workspacePath);
        },
      );

      test('GIVEN explicit isL10n set to true '
          'WHEN ModelParam primary constructor is called '
          'THEN stores isL10n as true accurately', () {
        // Given & When
        const param = ModelParam(
          modelName: 'task_create_param',
          type: ModelType.param,
          props: sampleProps,
          isL10n: true,
          featureName: 'task',
          moduleName: 'project_management',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );

        // Then
        expect(param.modelName, 'task_create_param');
        expect(param.type, ModelType.param);
        expect(param.props, sampleProps);
        expect(param.isL10n, isTrue);
      });
    });

    group('ModelParam.fromFeature Factory', () {
      test(
        'GIVEN a FeatureParam instance and model arguments '
        'WHEN ModelParam.fromFeature factory is called '
        'THEN copies feature hierarchy properties and stores all model arguments',
        () {
          // Given
          const baseFeature = FeatureParam(
            featureName: 'task',
            moduleName: 'project_management',
            workspaceName: 'my_workspace',
            workspacePath: '/projects/my_workspace',
          );

          // When
          final param = ModelParam.fromFeature(
            feature: baseFeature,
            modelName: 'task_dto',
            type: ModelType.dto,
            props: sampleProps,
            isL10n: true,
          );

          // Then
          expect(param.modelName, 'task_dto');
          expect(param.type, ModelType.dto);
          expect(param.props, sampleProps);
          expect(param.isL10n, isTrue);
          expect(param.featureName, baseFeature.featureName);
          expect(param.moduleName, baseFeature.moduleName);
          expect(param.workspaceName, baseFeature.workspaceName);
          expect(param.workspacePath, baseFeature.workspacePath);
        },
      );
    });
  });
}
