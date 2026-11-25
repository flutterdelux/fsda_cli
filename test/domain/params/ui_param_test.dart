import 'package:fsda_cli/domain/enums/input_type.dart';
import 'package:fsda_cli/domain/enums/ui_type.dart';
import 'package:fsda_cli/domain/models/form_field_model.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/domain/params/slice_param.dart';
import 'package:fsda_cli/domain/params/ui_param.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:test/test.dart';

void main() {
  group('UiParam', () {
    final sampleFields = [
      const FormFieldModel(
        fieldName: 'title',
        inputType: InputType.text,
        valueType: 'String',
      ),
      const FormFieldModel(
        fieldName: 'is_urgent',
        inputType: InputType.swich,
        valueType: '',
      ),
    ];

    group('Primary Constructor', () {
      test(
        'GIVEN valid model and slice hierarchy parameters without optional arguments '
        'WHEN UiParam primary constructor is called '
        'THEN sets default values (UiType.standard, null fields, hasInitial false) and extends SliceParam hierarchy',
        () {
          // Given
          const model = 'TaskEntity';
          const slice = 'detail';
          const featureName = 'task';
          const moduleName = 'project_management';
          const workspaceName = 'my_workspace';
          const workspacePath = '/projects/my_workspace';

          // When
          const param = UiParam(
            model: model,
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
          expect(param.type, UiType.standard);
          expect(param.model, model);
          expect(param.fields, isNull);
          expect(param.hasInitial, isFalse);
          expect(param.sliceName, slice);
          expect(param.featureName, featureName);
          expect(param.moduleName, moduleName);
          expect(param.workspaceName, workspaceName);
          expect(param.workspacePath, workspacePath);
        },
      );

      test('GIVEN explicit type, fields, and hasInitial true '
          'WHEN UiParam primary constructor is called '
          'THEN stores all provided arguments accurately', () {
        // Given & When
        final param = UiParam(
          type: UiType.form,
          model: 'TaskCreateParam',
          fields: sampleFields,
          hasInitial: true,
          sliceName: 'create',
          featureName: 'task',
          moduleName: 'project_management',
          workspaceName: 'my_workspace',
          workspacePath: '/projects/my_workspace',
        );

        // Then
        expect(param.type, UiType.form);
        expect(param.model, 'TaskCreateParam');
        expect(param.fields, sampleFields);
        expect(param.hasInitial, isTrue);
      });
    });

    group('UiParam.fromSlice Factory', () {
      const baseSlice = SliceParam(
        sliceName: 'task_list',
        featureName: 'task',
        moduleName: 'project_management',
        workspaceName: 'my_workspace',
        workspacePath: '/projects/my_workspace',
      );

      test(
        'GIVEN a SliceParam instance and model without optional arguments '
        'WHEN UiParam.fromSlice factory is called '
        'THEN copies slice hierarchy properties and applies default values',
        () {
          // When
          final param = UiParam.fromSlice(
            slice: baseSlice,
            model: 'TaskEntity',
          );

          // Then
          expect(param.type, UiType.standard);
          expect(param.model, 'TaskEntity');
          expect(param.fields, isNull);
          expect(param.hasInitial, isFalse);
          expect(param.sliceName, baseSlice.sliceName);
          expect(param.featureName, baseSlice.featureName);
          expect(param.moduleName, baseSlice.moduleName);
          expect(param.workspaceName, baseSlice.workspaceName);
          expect(param.workspacePath, baseSlice.workspacePath);
        },
      );

      test(
        'GIVEN a SliceParam instance and explicit type, fields, and hasInitial '
        'WHEN UiParam.fromSlice factory is called '
        'THEN copies slice hierarchy properties and stores explicit arguments',
        () {
          // When
          final param = UiParam.fromSlice(
            slice: baseSlice,
            type: UiType.form,
            model: 'TaskUpdateParam',
            fields: sampleFields,
            hasInitial: true,
          );

          // Then
          expect(param.type, UiType.form);
          expect(param.model, 'TaskUpdateParam');
          expect(param.fields, sampleFields);
          expect(param.hasInitial, isTrue);
          expect(param.sliceName, baseSlice.sliceName);
          expect(param.featureName, baseSlice.featureName);
          expect(param.moduleName, baseSlice.moduleName);
          expect(param.workspaceName, baseSlice.workspaceName);
          expect(param.workspacePath, baseSlice.workspacePath);
        },
      );
    });
  });
}
