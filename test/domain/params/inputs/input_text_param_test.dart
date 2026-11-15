import 'package:fsda_cli/domain/params/inputs/input_gate_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_text_param.dart';
import 'package:test/test.dart';

void main() {
  group('InputTextParam', () {
    const tInputGate = InputGateParam(
      featureName: 'profile',
      featurePath: '/workspace/modules/user/lib/src/features/profile',
      moduleName: 'user',
      modulePath: '/workspace/modules/user',
      field: 'first_name',
    );

    test(
      'Given feature details and field, '
      'When InputTextParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited input gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'profile';
        const featurePath = '/workspace/modules/user/lib/src/features/profile';
        const moduleName = 'user';
        const modulePath = '/workspace/modules/user';
        const field = 'first_name';

        // Act (When)
        const param = InputTextParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          field: field,
        );

        // Assert (Then)
        expect(param.featureName, equals(featureName));
        expect(param.featurePath, equals(featurePath));
        expect(param.moduleName, equals(moduleName));
        expect(param.modulePath, equals(modulePath));
        expect(param.field, equals(field));
      },
    );

    test('Given an InputGateParam instance, '
        'When InputTextParam.fromInputGate factory is called, '
        'Then it correctly maps all properties from the input gate', () {
      // Act (When)
      final param = InputTextParam.fromInputGate(inputGate: tInputGate);

      // Assert (Then)
      expect(param.featureName, equals(tInputGate.featureName));
      expect(param.featurePath, equals(tInputGate.featurePath));
      expect(param.moduleName, equals(tInputGate.moduleName));
      expect(param.modulePath, equals(tInputGate.modulePath));
      expect(param.field, equals(tInputGate.field));
    });
  });
}
