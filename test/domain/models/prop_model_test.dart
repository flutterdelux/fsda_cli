import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:test/test.dart';

void main() {
  group('PropModel Tests', () {
    test('should initialize PropModel properties correctly', () {
      const propModel = PropModel(
        type: 'String',
        name: 'username',
        defaultValue: "''",
        converter: 'toString()',
      );

      expect(propModel.type, 'String');
      expect(propModel.name, 'username');
      expect(propModel.defaultValue, "''");
      expect(propModel.converter, 'toString()');
    });
  });
}
