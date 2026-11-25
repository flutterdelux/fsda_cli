import 'package:fsda_cli/domain/enums/input_type.dart';
import 'package:test/test.dart';

void main() {
  group('InputType', () {
    group('Enum Values & code Property', () {
      test('GIVEN all 10 defined InputType enum constants '
          'WHEN code getter is accessed '
          'THEN returns corresponding snake_case string code', () {
        // Given & When & Then
        expect(InputType.values, hasLength(10));
        expect(InputType.dropdownEnum.code, 'dropdown_enum');
        expect(InputType.dropdown.code, 'dropdown');
        expect(InputType.image.code, 'image');
        expect(InputType.number.code, 'number');
        expect(InputType.password.code, 'password');
        expect(InputType.qty.code, 'qty');
        expect(InputType.selector.code, 'selector');
        expect(InputType.swich.code, 'switch');
        expect(InputType.textArea.code, 'text_area');
        expect(InputType.text.code, 'text');
      });
    });

    group('tryParse', () {
      test('GIVEN valid snake_case string codes matching InputType constants '
          'WHEN tryParse is called '
          'THEN returns the corresponding InputType enum constant', () {
        // Given
        const inputs = {
          'dropdown_enum': InputType.dropdownEnum,
          'dropdown': InputType.dropdown,
          'image': InputType.image,
          'number': InputType.number,
          'password': InputType.password,
          'qty': InputType.qty,
          'selector': InputType.selector,
          'switch': InputType.swich,
          'text_area': InputType.textArea,
          'text': InputType.text,
        };

        // When & Then
        inputs.forEach((rawCode, expectedEnum) {
          expect(InputType.tryParse(rawCode), expectedEnum);
        });
      });

      test('GIVEN unknown, camelCase, uppercase, or empty string '
          'WHEN tryParse is called '
          'THEN returns null', () {
        // Given
        const invalidInputs = [
          '',
          'dropdownEnum',
          'selectorList',
          'textArea',
          'swich',
          'TEXT',
          ' text ',
          'unknown_input',
        ];

        // When & Then
        for (final input in invalidInputs) {
          expect(InputType.tryParse(input), isNull);
        }
      });
    });

    group('available', () {
      test('GIVEN InputType enum '
          'WHEN available getter is accessed '
          'THEN returns comma-separated list of all valid codes', () {
        // When & Then
        expect(
          InputType.available,
          'dropdown_enum, dropdown, image, number, password, qty, selector, switch, text_area, text',
        );
      });
    });
  });
}
