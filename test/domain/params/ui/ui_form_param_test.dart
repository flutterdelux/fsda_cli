import 'package:fsda_cli/domain/enums/input_type.dart';
import 'package:fsda_cli/domain/models/form_field_model.dart';
import 'package:fsda_cli/domain/params/ui/ui_form_param.dart';
import 'package:fsda_cli/domain/params/ui/ui_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('UiFormParam', () {
    const tUiGate = UiGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      slice: 'task_form',
      model: 'TaskModel',
    );

    const tFields = [
      FormFieldModel(
        inputType: InputType.text,
        valueType: 'String',
        fieldName: 'title',
      ),
    ];

    test(
      'Given feature details, slice, model, fields, and optional hasInitial flag, '
      'When UiFormParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties, inheriting UI gate parameters and defaulting hasInitial to false when omitted',
      () {
        // Arrange (Given)
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const slice = 'task_form';
        const model = 'TaskModel';

        // Act (When)
        const paramDefault = UiFormParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          slice: slice,
          model: model,
          fields: tFields,
        );

        const paramCustom = UiFormParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          slice: slice,
          model: model,
          fields: tFields,
          hasInitial: true,
        );

        // Assert (Then)
        expect(paramDefault.featureName, equals(featureName));
        expect(paramDefault.featurePath, equals(featurePath));
        expect(paramDefault.moduleName, equals(moduleName));
        expect(paramDefault.modulePath, equals(modulePath));
        expect(paramDefault.slice, equals(slice));
        expect(paramDefault.model, equals(model));
        expect(paramDefault.fields, equals(tFields));
        expect(paramDefault.hasInitial, isFalse);

        expect(paramCustom.hasInitial, isTrue);
      },
    );

    test(
      'Given a UiGateParam instance, fields, and optional hasInitial flag, '
      'When UiFormParam.fromUiGate factory is called, '
      'Then it correctly maps all properties from the UI gate and sets fields and hasInitial',
      () {
        // Act (When)
        final paramDefault = UiFormParam.fromUiGate(
          ui: tUiGate,
          fields: tFields,
        );

        final paramCustom = UiFormParam.fromUiGate(
          ui: tUiGate,
          fields: tFields,
          hasInitial: true,
        );

        // Assert (Then)
        expect(paramDefault.featureName, equals(tUiGate.featureName));
        expect(paramDefault.featurePath, equals(tUiGate.featurePath));
        expect(paramDefault.moduleName, equals(tUiGate.moduleName));
        expect(paramDefault.modulePath, equals(tUiGate.modulePath));
        expect(paramDefault.slice, equals(tUiGate.slice));
        expect(paramDefault.model, equals(tUiGate.model));
        expect(paramDefault.fields, equals(tFields));
        expect(paramDefault.hasInitial, isFalse);

        expect(paramCustom.hasInitial, isTrue);
      },
    );
  });
}
