import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('SequenceParam', () {
    group('Primary Constructor', () {
      test(
        'GIVEN only required sequence and feature parameters '
        'WHEN SequenceParam primary constructor is called '
        'THEN applies default values and extends FeatureParam, ModuleParam, and WorkspaceParam',
        () {
          // Given
          const action = Action.get;
          const usecase = 'task_list_use_case';
          const method = 'get_task_list';
          const featureName = 'task';
          const moduleName = 'project_management';
          const workspaceName = 'my_workspace';
          const workspacePath = '/projects/my_workspace';

          // When
          const param = SequenceParam(
            action: action,
            usecase: usecase,
            method: method,
            featureName: featureName,
            moduleName: moduleName,
            workspaceName: workspaceName,
            workspacePath: workspacePath,
          );

          // Then
          expect(param, isA<FeatureParam>());
          expect(param, isA<ModuleParam>());
          expect(param, isA<WorkspaceParam>());
          expect(param.action, action);
          expect(param.usecase, usecase);
          expect(param.method, method);
          expect(param.flow, FlowType.asynchronous);
          expect(param.dsMode, DsMode.remote);
          expect(param.isList, isFalse);
          expect(param.entity, isNull);
          expect(param.param, isNull);
          expect(param.dto, isNull);
          expect(param.request, isNull);
          expect(param.response, isNull);
          expect(param.featureName, featureName);
          expect(param.moduleName, moduleName);
          expect(param.workspaceName, workspaceName);
          expect(param.workspacePath, workspacePath);
        },
      );

      test('GIVEN all required and optional sequence parameters '
          'WHEN SequenceParam primary constructor is called '
          'THEN stores all custom values accurately', () {
        // Given
        const action = Action.post;
        const usecase = 'task_create_use_case';
        const method = 'create_task';
        const flow = FlowType.stream;
        const dsMode = DsMode.local;
        const isList = true;
        const entity = 'task_entity';
        const taskParam = 'task_create_param';
        const dto = 'task_dto';
        const request = 'task_create_request';
        const response = 'task_response';

        // When
        const param = SequenceParam(
          action: action,
          usecase: usecase,
          method: method,
          flow: flow,
          dsMode: dsMode,
          isList: isList,
          entity: entity,
          param: taskParam,
          dto: dto,
          request: request,
          response: response,
          featureName: 'task',
          moduleName: 'project_management',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );

        // Then
        expect(param.action, action);
        expect(param.usecase, usecase);
        expect(param.method, method);
        expect(param.flow, flow);
        expect(param.dsMode, dsMode);
        expect(param.isList, isTrue);
        expect(param.entity, entity);
        expect(param.param, taskParam);
        expect(param.dto, dto);
        expect(param.request, request);
        expect(param.response, response);
      });
    });

    group('SequenceParam.fromFeature Factory', () {
      const feature = FeatureParam(
        featureName: 'payment',
        moduleName: 'billing',
        workspaceName: 'my_workspace',
        workspacePath: '/projects/my_workspace',
      );

      test(
        'GIVEN a FeatureParam instance and only required sequence arguments '
        'WHEN SequenceParam.fromFeature factory is called '
        'THEN copies feature hierarchy properties and applies default values',
        () {
          // Given
          const action = Action.delete;
          const usecase = 'payment_delete_use_case';
          const method = 'delete_payment';

          // When
          final param = SequenceParam.fromFeature(
            feature: feature,
            action: action,
            usecase: usecase,
            method: method,
          );

          // Then
          expect(param.featureName, feature.featureName);
          expect(param.moduleName, feature.moduleName);
          expect(param.workspaceName, feature.workspaceName);
          expect(param.workspacePath, feature.workspacePath);
          expect(param.action, action);
          expect(param.usecase, usecase);
          expect(param.method, method);
          expect(param.flow, FlowType.asynchronous);
          expect(param.dsMode, DsMode.remote);
          expect(param.isList, isFalse);
          expect(param.entity, isNull);
          expect(param.param, isNull);
          expect(param.dto, isNull);
          expect(param.request, isNull);
          expect(param.response, isNull);
        },
      );

      test(
        'GIVEN a FeatureParam instance and all optional sequence arguments '
        'WHEN SequenceParam.fromFeature factory is called '
        'THEN copies feature hierarchy properties and sets all custom fields accurately',
        () {
          // Given
          const action = Action.put;
          const usecase = 'payment_update_use_case';
          const method = 'update_payment';
          const flow = FlowType.synchronous;
          const dsMode = DsMode.local;
          const isList = true;
          const entity = 'payment_entity';
          const paymentParam = 'payment_update_param';
          const dto = 'payment_dto';
          const request = 'payment_update_request';
          const response = 'payment_response';

          // When
          final param = SequenceParam.fromFeature(
            feature: feature,
            action: action,
            usecase: usecase,
            method: method,
            flow: flow,
            dsMode: dsMode,
            isList: isList,
            entity: entity,
            param: paymentParam,
            dto: dto,
            request: request,
            response: response,
          );

          // Then
          expect(param.featureName, feature.featureName);
          expect(param.moduleName, feature.moduleName);
          expect(param.workspaceName, feature.workspaceName);
          expect(param.workspacePath, feature.workspacePath);
          expect(param.action, action);
          expect(param.usecase, usecase);
          expect(param.method, method);
          expect(param.flow, flow);
          expect(param.dsMode, dsMode);
          expect(param.isList, isTrue);
          expect(param.entity, entity);
          expect(param.param, paymentParam);
          expect(param.dto, dto);
          expect(param.request, request);
          expect(param.response, response);
        },
      );
    });
  });
}
