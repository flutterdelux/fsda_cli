import 'package:fsda_cli/domain/models/prop_model.dart'; // Sesuaikan path import dengan project Anda
import 'package:test/test.dart';

void main() {
  group('PropModel', () {
    test('Given valid type, name, defaultValue, and converter, '
        'When PropModel is instantiated, '
        'Then it correctly holds all provided properties', () {
      // Arrange (Given)
      const type = 'String';
      const name = 'title';
      const defaultValue = "''";
      const converter = 'IdConverter';

      // Act (When)
      const propModel = PropModel(
        type: type,
        name: name,
        defaultValue: defaultValue,
        converter: converter,
      );

      // Assert (Then)
      expect(propModel.type, equals(type));
      expect(propModel.name, equals(name));
      expect(propModel.defaultValue, equals(defaultValue));
      expect(propModel.converter, equals(converter));
    });
  });
}
