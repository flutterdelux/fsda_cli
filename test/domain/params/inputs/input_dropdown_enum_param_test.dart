import 'package:fsda_cli/domain/params/inputs/input_dropdown_enum_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('InputDropdownEnumParam', () {
    const tInputGate = InputGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      field: 'status',
    );

    test(
      'Given feature details, field, and type, '
      'When InputDropdownEnumParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited input gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const field = 'status';
        const type = 'TaskStatus';

        // Act (When)
        const param = InputDropdownEnumParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          field: field,
          type: type,
        );

        // Assert (Then)
        expect(param.featureName, equals(featureName));
        expect(param.featurePath, equals(featurePath));
        expect(param.moduleName, equals(moduleName));
        expect(param.modulePath, equals(modulePath));
        expect(param.field, equals(field));
        expect(param.type, equals(type));
      },
    );

    test(
      'Given an InputGateParam instance and enum type, '
      'When InputDropdownEnumParam.fromInputGate factory is called, '
      'Then it correctly maps all properties from the input gate and sets the type',
      () {
        // Arrange (Given)
        const enumType = 'PriorityEnum';

        // Act (When)
        final param = InputDropdownEnumParam.fromInputGate(
          inputGate: tInputGate,
          enumType: enumType,
        );

        // Assert (Then)
        expect(param.featureName, equals(tInputGate.featureName));
        expect(param.featurePath, equals(tInputGate.featurePath));
        expect(param.moduleName, equals(tInputGate.moduleName));
        expect(param.modulePath, equals(tInputGate.modulePath));
        expect(param.field, equals(tInputGate.field));
        expect(param.type, equals(enumType));
      },
    );
  });
}
