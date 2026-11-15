import 'package:fsda_cli/domain/params/inputs/input_dropdown_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('InputDropdownParam', () {
    const tInputGate = InputGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      field: 'category',
    );

    test(
      'Given feature details, field, and type, '
      'When InputDropdownParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited input gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const field = 'category';
        const type = 'CategoryType';

        // Act (When)
        const param = InputDropdownParam(
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
      'Given an InputGateParam instance and type name, '
      'When InputDropdownParam.fromInputGate factory is called, '
      'Then it correctly maps all properties from the input gate and sets the type',
      () {
        // Arrange (Given)
        const typeName = 'RoleType';

        // Act (When)
        final param = InputDropdownParam.fromInputGate(
          inputGate: tInputGate,
          typeName: typeName,
        );

        // Assert (Then)
        expect(param.featureName, equals(tInputGate.featureName));
        expect(param.featurePath, equals(tInputGate.featurePath));
        expect(param.moduleName, equals(tInputGate.moduleName));
        expect(param.modulePath, equals(tInputGate.modulePath));
        expect(param.field, equals(tInputGate.field));
        expect(param.type, equals(typeName));
      },
    );
  });
}
