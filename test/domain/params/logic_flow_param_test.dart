import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/slice_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('LogicFlowParam', () {
    const sampleUc = 'task_list_get_use_case';

    group('Primary Constructor', () {
      test(
        'GIVEN valid type, uc, and slice hierarchy parameters without specifying control '
        'WHEN LogicFlowParam primary constructor is called '
        'THEN sets control to StateControl.cubit by default and extends SliceGateParam hierarchy',
        () {
          // Given
          const type = LogicFlowType.retrieval;
          const slice = 'task_list';
          const featureName = 'task';
          const moduleName = 'project_management';
          const workspaceName = 'my_workspace';
          const workspacePath = '/projects/my_workspace';

          // When
          const param = LogicFlowParam(
            type: type,
            uc: sampleUc,
            sliceName: slice,
            featureName: featureName,
            moduleName: moduleName,
            workspaceName: workspaceName,
            workspacePath: workspacePath,
          );

          // Then
          expect(param, isA<SliceParam>());
          expect(param, isA<FeatureParam>());
          expect(param, isA<ModuleParam>());
          expect(param, isA<WorkspaceParam>());
          expect(param.type, type);
          expect(param.uc, sampleUc);
          expect(param.control, StateControl.cubit);
          expect(param.sliceName, slice);
          expect(param.featureName, featureName);
          expect(param.moduleName, moduleName);
          expect(param.workspaceName, workspaceName);
          expect(param.workspacePath, workspacePath);
        },
      );

      test('GIVEN control explicitly set to StateControl.riverpod '
          'WHEN LogicFlowParam primary constructor is called '
          'THEN stores control as StateControl.riverpod accurately', () {
        // Given & When
        const param = LogicFlowParam(
          type: LogicFlowType.mutation,
          uc: sampleUc,
          control: StateControl.riverpod,
          sliceName: 'task_form',
          featureName: 'task',
          moduleName: 'project_management',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );

        // Then
        expect(param.type, LogicFlowType.mutation);
        expect(param.uc, sampleUc);
        expect(param.control, StateControl.riverpod);
      });
    });

    group('LogicFlowParam.fromSlice Factory', () {
      const sliceGate = SliceParam(
        sliceName: 'checkout_summary',
        featureName: 'payment',
        moduleName: 'billing',
        workspaceName: 'my_workspace',
        workspacePath: '/projects/my_workspace',
      );

      test(
        'GIVEN a SliceGateParam instance, type, uc, and StateControl.cubit '
        'WHEN LogicFlowParam.fromSlice factory is called '
        'THEN copies slice hierarchy properties and sets control to StateControl.cubit',
        () {
          // When
          final param = LogicFlowParam.fromSlice(
            slice: sliceGate,
            type: LogicFlowType.pagination,
            uc: sampleUc,
            control: StateControl.cubit,
          );

          // Then
          expect(param.type, LogicFlowType.pagination);
          expect(param.uc, sampleUc);
          expect(param.control, StateControl.cubit);
          expect(param.sliceName, sliceGate.sliceName);
          expect(param.featureName, sliceGate.featureName);
          expect(param.moduleName, sliceGate.moduleName);
          expect(param.workspaceName, sliceGate.workspaceName);
          expect(param.workspacePath, sliceGate.workspacePath);
        },
      );

      test(
        'GIVEN a SliceGateParam instance, type, uc, and explicit StateControl.getx '
        'WHEN LogicFlowParam.fromSlice factory is called '
        'THEN copies slice hierarchy properties and sets control to StateControl.getx',
        () {
          // When
          final param = LogicFlowParam.fromSlice(
            slice: sliceGate,
            type: LogicFlowType.mutation,
            uc: sampleUc,
            control: StateControl.getx,
          );

          // Then
          expect(param.type, LogicFlowType.mutation);
          expect(param.uc, sampleUc);
          expect(param.control, StateControl.getx);
          expect(param.sliceName, sliceGate.sliceName);
          expect(param.featureName, sliceGate.featureName);
          expect(param.moduleName, sliceGate.moduleName);
          expect(param.workspaceName, sliceGate.workspaceName);
          expect(param.workspacePath, sliceGate.workspacePath);
        },
      );
    });
  });
}
