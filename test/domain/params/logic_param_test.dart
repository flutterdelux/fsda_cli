import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/slice_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('LogicParam', () {
    const sampleProps = [
      PropModel(
        type: 'bool',
        name: 'is_loading',
        defaultValue: 'false',
        converter: '',
      ),
      PropModel(
        type: 'String',
        name: 'error_message',
        defaultValue: '""',
        converter: '',
      ),
    ];

    group('Primary Constructor', () {
      test(
        'GIVEN valid props and slice hierarchy parameters without specifying control '
        'WHEN LogicParam primary constructor is called '
        'THEN sets control to StateControl.cubit by default and extends SliceGateParam hierarchy',
        () {
          // Given
          const slice = 'task_list';
          const featureName = 'task';
          const moduleName = 'project_management';
          const workspaceName = 'my_workspace';
          const workspacePath = '/projects/my_workspace';

          // When
          const param = LogicParam(
            props: sampleProps,
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
          expect(param.props, sampleProps);
          expect(param.control, StateControl.cubit);
          expect(param.sliceName, slice);
          expect(param.featureName, featureName);
          expect(param.moduleName, moduleName);
          expect(param.workspaceName, workspaceName);
          expect(param.workspacePath, workspacePath);
        },
      );

      test('GIVEN control explicitly set to StateControl.riverpod '
          'WHEN LogicParam primary constructor is called '
          'THEN stores control as StateControl.riverpod accurately', () {
        // Given & When
        const param = LogicParam(
          props: sampleProps,
          control: StateControl.riverpod,
          sliceName: 'task_form',
          featureName: 'task',
          moduleName: 'project_management',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );

        // Then
        expect(param.props, sampleProps);
        expect(param.control, StateControl.riverpod);
      });
    });

    group('LogicParam.fromSliceGate Factory', () {
      const sliceGate = SliceParam(
        sliceName: 'checkout_summary',
        featureName: 'payment',
        moduleName: 'billing',
        workspaceName: 'my_workspace',
        workspacePath: '/projects/my_workspace',
      );

      test(
        'GIVEN a SliceGateParam instance and props without specifying control '
        'WHEN LogicParam.fromSliceGate factory is called '
        'THEN copies slice hierarchy properties and defaults control to StateControl.cubit',
        () {
          // When
          final param = LogicParam.fromSliceGate(
            slice: sliceGate,
            props: sampleProps,
            control: .cubit,
          );

          // Then
          expect(param.props, sampleProps);
          expect(param.control, StateControl.cubit);
          expect(param.sliceName, sliceGate.sliceName);
          expect(param.featureName, sliceGate.featureName);
          expect(param.moduleName, sliceGate.moduleName);
          expect(param.workspaceName, sliceGate.workspaceName);
          expect(param.workspacePath, sliceGate.workspacePath);
        },
      );

      test(
        'GIVEN a SliceGateParam instance, props, and explicit StateControl.getx '
        'WHEN LogicParam.fromSliceGate factory is called '
        'THEN copies slice hierarchy properties and sets control to StateControl.getx',
        () {
          // When
          final param = LogicParam.fromSliceGate(
            slice: sliceGate,
            props: sampleProps,
            control: StateControl.getx,
          );

          // Then
          expect(param.props, sampleProps);
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
