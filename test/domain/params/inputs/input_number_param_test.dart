import 'package:fsda_cli/domain/params/inputs/input_gate_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_number_param.dart';
import 'package:test/test.dart';

void main() {
  group('InputNumberParam', () {
    const tInputGate = InputGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      field: 'age',
    );

    test(
      'Given feature details, field, and type, '
      'When InputNumberParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited input gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const field = 'age';
        const type = 'double';

        // Act (When)
        const param = InputNumberParam(
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
      'Given an InputGateParam instance and optional type, '
      'When InputNumberParam.fromInputGate factory is called, '
      'Then it correctly maps all properties from the input gate and sets the type, defaulting to "int" when omitted',
      () {
        // Act (When)
        final paramDefault = InputNumberParam.fromInputGate(
          inputGate: tInputGate,
        );
        final paramCustom = InputNumberParam.fromInputGate(
          inputGate: tInputGate,
          type: 'double',
        );

        // Assert (Then)
        expect(paramDefault.featureName, equals(tInputGate.featureName));
        expect(paramDefault.featurePath, equals(tInputGate.featurePath));
        expect(paramDefault.moduleName, equals(tInputGate.moduleName));
        expect(paramDefault.modulePath, equals(tInputGate.modulePath));
        expect(paramDefault.field, equals(tInputGate.field));
        expect(paramDefault.type, equals('int'));

        expect(paramCustom.type, equals('double'));
      },
    );
  });
}
