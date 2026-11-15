import 'package:fsda_cli/domain/params/inputs/input_gate_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_password_param.dart';
import 'package:test/test.dart';

void main() {
  group('InputPasswordParam', () {
    const tInputGate = InputGateParam(
      featureName: 'auth',
      featurePath: '/workspace/modules/authentication/lib/src/features/auth',
      moduleName: 'authentication',
      modulePath: '/workspace/modules/authentication',
      field: 'password',
    );

    test(
      'Given feature details and field, '
      'When InputPasswordParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited input gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'auth';
        const featurePath =
            '/workspace/modules/authentication/lib/src/features/auth';
        const moduleName = 'authentication';
        const modulePath = '/workspace/modules/authentication';
        const field = 'password';

        // Act (When)
        const param = InputPasswordParam(
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
        'When InputPasswordParam.fromInputGate factory is called, '
        'Then it correctly maps all properties from the input gate', () {
      // Act (When)
      final param = InputPasswordParam.fromInputGate(inputGate: tInputGate);

      // Assert (Then)
      expect(param.featureName, equals(tInputGate.featureName));
      expect(param.featurePath, equals(tInputGate.featurePath));
      expect(param.moduleName, equals(tInputGate.moduleName));
      expect(param.modulePath, equals(tInputGate.modulePath));
      expect(param.field, equals(tInputGate.field));
    });
  });
}
