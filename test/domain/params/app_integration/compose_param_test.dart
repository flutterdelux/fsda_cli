import 'package:fsda_cli/domain/enums/compose_type.dart';
import 'package:fsda_cli/domain/params/app_integration/compose_param.dart';
import 'package:fsda_cli/domain/params/app_integration/reg_feature_param.dart';
import 'package:fsda_cli/domain/params/app_integration/reg_module_param.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('ComposeParam', () {
    group('Primary Constructor', () {
      test(
        'GIVEN required ComposeParam arguments without optional slices '
        'WHEN ComposeParam primary constructor is called '
        'THEN sets optional uiSlice and logicSlice to null and extends RegFeatureParam hierarchy',
        () {
          // Given
          final type = ComposeType.mutation;
          final target = 'task_delete_button';
          final logicFlowSlice = 'delete';
          final appName = 'portal_app';
          final featureName = 'task';
          final moduleName = 'project_management';
          final workspaceName = 'my_workspace';
          final workspacePath = '/projects/my_workspace';

          // When (non-const invocation so constructor & super initializer execute at runtime)
          final param = ComposeParam(
            type: type,
            target: target,
            logicFlowSlice: logicFlowSlice,
            appName: appName,
            featureName: featureName,
            moduleName: moduleName,
            workspaceName: workspaceName,
            workspacePath: workspacePath,
          );

          // Then
          expect(param, isA<RegFeatureParam>());
          expect(param, isA<RegModuleParam>());
          expect(param, isA<FeatureParam>());
          expect(param, isA<ModuleParam>());
          expect(param, isA<WorkspaceParam>());
          expect(param.type, type);
          expect(param.target, target);
          expect(param.logicFlowSlice, logicFlowSlice);
          expect(param.uiSlice, isNull);
          expect(param.logicSlice, isNull);
          expect(param.appName, appName);
          expect(param.featureName, featureName);
          expect(param.moduleName, moduleName);
          expect(param.workspaceName, workspaceName);
          expect(param.workspacePath, workspacePath);
        },
      );

      test('GIVEN explicit uiSlice and logicSlice '
          'WHEN ComposeParam primary constructor is called '
          'THEN stores all provided arguments accurately', () {
        // Given & When
        final param = const ComposeParam(
          type: ComposeType.form,
          target: 'task_create_page',
          logicFlowSlice: 'create',
          uiSlice: 'create_form',
          logicSlice: 'filter',
          appName: 'portal_app',
          featureName: 'task',
          moduleName: 'project_management',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );

        // Then
        expect(param.type, ComposeType.form);
        expect(param.target, 'task_create_page');
        expect(param.logicFlowSlice, 'create');
        expect(param.uiSlice, 'create_form');
        expect(param.logicSlice, 'filter');
      });
    });

    group('ComposeParam.fromRegFeature Factory', () {
      test(
        'GIVEN a RegFeatureParam instance without optional slices '
        'WHEN ComposeParam.fromRegFeature factory is called '
        'THEN copies RegFeatureParam hierarchy properties and leaves uiSlice and logicSlice null',
        () {
          // Given
          final baseRegFeature = const RegFeatureParam(
            appName: 'portal_app',
            featureName: 'task',
            moduleName: 'project_management',
            workspaceName: 'my_workspace',
            workspacePath: '/projects/my_workspace',
          );

          // When
          final param = ComposeParam.fromRegFeature(
            regFeature: baseRegFeature,
            type: ComposeType.retrieval,
            target: 'task_detail_page',
            logicFlowSlice: 'detail',
            withRoute: false,
          );

          // Then
          expect(param.type, ComposeType.retrieval);
          expect(param.target, 'task_detail_page');
          expect(param.logicFlowSlice, 'detail');
          expect(param.uiSlice, isNull);
          expect(param.logicSlice, isNull);
          expect(param.appName, baseRegFeature.appName);
          expect(param.featureName, baseRegFeature.featureName);
          expect(param.moduleName, baseRegFeature.moduleName);
          expect(param.workspaceName, baseRegFeature.workspaceName);
          expect(param.workspacePath, baseRegFeature.workspacePath);
        },
      );

      test(
        'GIVEN a RegFeatureParam instance with explicit uiSlice and logicSlice '
        'WHEN ComposeParam.fromRegFeature factory is called '
        'THEN copies RegFeatureParam properties and stores uiSlice and logicSlice accurately',
        () {
          // Given
          final baseRegFeature = const RegFeatureParam(
            appName: 'portal_app',
            featureName: 'task',
            moduleName: 'project_management',
            workspaceName: 'my_workspace',
            workspacePath: '/projects/my_workspace',
          );

          // When
          final param = ComposeParam.fromRegFeature(
            regFeature: baseRegFeature,
            type: ComposeType.pagination,
            target: 'task_list_page',
            logicFlowSlice: 'list',
            uiSlice: 'list_view',
            logicSlice: 'search_filter',
            withRoute: false,
          );

          // Then
          expect(param.type, ComposeType.pagination);
          expect(param.target, 'task_list_page');
          expect(param.logicFlowSlice, 'list');
          expect(param.uiSlice, 'list_view');
          expect(param.logicSlice, 'search_filter');
          expect(param.appName, baseRegFeature.appName);
          expect(param.featureName, baseRegFeature.featureName);
          expect(param.moduleName, baseRegFeature.moduleName);
          expect(param.workspaceName, baseRegFeature.workspaceName);
          expect(param.workspacePath, baseRegFeature.workspacePath);
        },
      );
    });
  });
}
