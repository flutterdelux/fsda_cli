import 'package:fsda_cli/domain/enums/input_type.dart'; // Sesuaikan path import dengan project Anda
import 'package:fsda_cli/domain/models/form_field_model.dart';
import 'package:test/test.dart';

void main() {
  group('FormFieldModel', () {
    test('Given valid input type, value type, field name, and default value, '
        'When FormFieldModel is instantiated, '
        'Then it correctly holds all provided properties', () {
      // Arrange (Given)
      const inputType = InputType.text;
      const valueType = 'String';
      const fieldName = 'email';
      const defaultValue = 'example@email.com';

      // Act (When)
      const model = FormFieldModel(
        inputType: inputType,
        valueType: valueType,
        fieldName: fieldName,
        defaultValue: defaultValue,
      );

      // Assert (Then)
      expect(model.inputType, equals(inputType));
      expect(model.valueType, equals(valueType));
      expect(model.fieldName, equals(fieldName));
      expect(model.defaultValue, equals(defaultValue));
    });

    test('Given FormFieldModel instantiated without optional defaultValue, '
        'When checking properties, '
        'Then defaultValue should be null', () {
      // Arrange & Act (Given & When)
      const model = FormFieldModel(
        inputType: InputType.number,
        valueType: 'int',
        fieldName: 'age',
      );

      // Assert (Then)
      expect(model.inputType, equals(InputType.number));
      expect(model.valueType, equals('int'));
      expect(model.fieldName, equals('age'));
      expect(model.defaultValue, isNull);
    });
  });
}
