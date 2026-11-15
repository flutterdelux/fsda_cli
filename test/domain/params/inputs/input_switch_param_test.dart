import 'package:fsda_cli/domain/params/inputs/input_gate_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_switch_param.dart';
import 'package:test/test.dart';

void main() {
  group('InputSwitchParam', () {
    const tInputGate = InputGateParam(
      featureName: 'settings',
      featurePath: '/workspace/modules/app_settings/lib/src/features/settings',
      moduleName: 'app_settings',
      modulePath: '/workspace/modules/app_settings',
      field: 'isDarkMode',
    );

    test(
      'Given feature details and field, '
      'When InputSwitchParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited input gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'settings';
        const featurePath =
            '/workspace/modules/app_settings/lib/src/features/settings';
        const moduleName = 'app_settings';
        const modulePath = '/workspace/modules/app_settings';
        const field = 'isDarkMode';

        // Act (When)
        const param = InputSwitchParam(
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
        'When InputSwitchParam.fromInputGate factory is called, '
        'Then it correctly maps all properties from the input gate', () {
      // Act (When)
      final param = InputSwitchParam.fromInputGate(inputGate: tInputGate);

      // Assert (Then)
      expect(param.featureName, equals(tInputGate.featureName));
      expect(param.featurePath, equals(tInputGate.featurePath));
      expect(param.moduleName, equals(tInputGate.moduleName));
      expect(param.modulePath, equals(tInputGate.modulePath));
      expect(param.field, equals(tInputGate.field));
    });
  });
}
