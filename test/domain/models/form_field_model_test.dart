import 'package:fsda_cli/domain/enums/input_type.dart';
import 'package:fsda_cli/domain/models/form_field_model.dart';
import 'package:test/test.dart';

void main() {
  group('FormFieldModel', () {
    test(
      'GIVEN only required parameters without defaultValue '
      'WHEN FormFieldModel constructor is called '
      'THEN stores required properties accurately and defaults defaultValue to null',
      () {
        // Given
        const inputType = InputType.text;
        const valueType = 'String';
        const fieldName = 'full_name';

        // When
        const model = FormFieldModel(
          inputType: inputType,
          valueType: valueType,
          fieldName: fieldName,
        );

        // Then
        expect(model.inputType, inputType);
        expect(model.valueType, valueType);
        expect(model.fieldName, fieldName);
        expect(model.defaultValue, isNull);
      },
    );

    test('GIVEN all required and optional parameters including defaultValue '
        'WHEN FormFieldModel constructor is called '
        'THEN stores all property values accurately', () {
      // Given
      const inputType = InputType.number;
      const valueType = 'int';
      const fieldName = 'quantity';
      const defaultValue = '1';

      // When
      const model = FormFieldModel(
        inputType: inputType,
        valueType: valueType,
        fieldName: fieldName,
        defaultValue: defaultValue,
      );

      // Then
      expect(model.inputType, inputType);
      expect(model.valueType, valueType);
      expect(model.fieldName, fieldName);
      expect(model.defaultValue, defaultValue);
    });
  });
}
