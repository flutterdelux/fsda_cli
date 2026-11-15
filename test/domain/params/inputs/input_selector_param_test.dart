import 'package:fsda_cli/domain/params/inputs/input_gate_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_selector_param.dart';
import 'package:test/test.dart';

void main() {
  group('InputSelectorParam', () {
    const tInputGate = InputGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      field: 'assignee',
    );

    test(
      'Given feature details, field, valueType, and optional isList, '
      'When InputSelectorParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties, inheriting input gate parameters and defaulting isList to false',
      () {
        // Arrange (Given)
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const field = 'assignee';
        const valueType = 'User';

        // Act (When)
        const paramDefault = InputSelectorParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          field: field,
          valueType: valueType,
        );

        const paramCustom = InputSelectorParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          field: field,
          valueType: valueType,
          isList: true,
        );

        // Assert (Then)
        expect(paramDefault.featureName, equals(featureName));
        expect(paramDefault.featurePath, equals(featurePath));
        expect(paramDefault.moduleName, equals(moduleName));
        expect(paramDefault.modulePath, equals(modulePath));
        expect(paramDefault.field, equals(field));
        expect(paramDefault.valueType, equals(valueType));
        expect(paramDefault.isList, isFalse);

        expect(paramCustom.isList, isTrue);
      },
    );

    test(
      'Given an InputGateParam instance, valueType, and optional isList, '
      'When InputSelectorParam.fromInputGate factory is called, '
      'Then it correctly maps all properties from the input gate and sets valueType and isList',
      () {
        // Act (When)
        final paramDefault = InputSelectorParam.fromInputGate(
          inputGate: tInputGate,
          valueType: 'User',
        );

        final paramCustom = InputSelectorParam.fromInputGate(
          inputGate: tInputGate,
          valueType: 'User',
          isList: true,
        );

        // Assert (Then)
        expect(paramDefault.featureName, equals(tInputGate.featureName));
        expect(paramDefault.featurePath, equals(tInputGate.featurePath));
        expect(paramDefault.moduleName, equals(tInputGate.moduleName));
        expect(paramDefault.modulePath, equals(tInputGate.modulePath));
        expect(paramDefault.field, equals(tInputGate.field));
        expect(paramDefault.valueType, equals('User'));
        expect(paramDefault.isList, isFalse);

        expect(paramCustom.isList, isTrue);
      },
    );
  });
}
