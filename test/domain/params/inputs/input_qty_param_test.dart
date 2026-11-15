import 'package:fsda_cli/domain/params/inputs/input_gate_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_qty_param.dart';
import 'package:test/test.dart';

void main() {
  group('InputQtyParam', () {
    const tInputGate = InputGateParam(
      featureName: 'cart',
      featurePath: '/workspace/modules/shop/lib/src/features/cart',
      moduleName: 'shop',
      modulePath: '/workspace/modules/shop',
      field: 'quantity',
    );

    test(
      'Given feature details and field, '
      'When InputQtyParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited input gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'cart';
        const featurePath = '/workspace/modules/shop/lib/src/features/cart';
        const moduleName = 'shop';
        const modulePath = '/workspace/modules/shop';
        const field = 'quantity';

        // Act (When)
        const param = InputQtyParam(
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
        'When InputQtyParam.fromInputGate factory is called, '
        'Then it correctly maps all properties from the input gate', () {
      // Act (When)
      final param = InputQtyParam.fromInputGate(inputGate: tInputGate);

      // Assert (Then)
      expect(param.featureName, equals(tInputGate.featureName));
      expect(param.featurePath, equals(tInputGate.featurePath));
      expect(param.moduleName, equals(tInputGate.moduleName));
      expect(param.modulePath, equals(tInputGate.modulePath));
      expect(param.field, equals(tInputGate.field));
    });
  });
}
