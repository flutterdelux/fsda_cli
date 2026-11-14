import 'package:fsda_cli/domain/enums/input_type.dart';
import 'package:test/test.dart';

void main() {
  group('InputType Tests', () {
    test('tryParse should return correct InputType for valid code', () {
      expect(InputType.tryParse('dropdown_enum'), InputType.dropdownEnum);
      expect(InputType.tryParse('dropdown'), InputType.dropdown);
      expect(InputType.tryParse('image'), InputType.image);
      expect(InputType.tryParse('number'), InputType.number);
      expect(InputType.tryParse('password'), InputType.password);
      expect(InputType.tryParse('qty'), InputType.qty);
      expect(InputType.tryParse('selector_list'), InputType.selectorList);
      expect(InputType.tryParse('selector'), InputType.selector);
      expect(InputType.tryParse('switch'), InputType.swich);
      expect(InputType.tryParse('text_area'), InputType.textArea);
      expect(InputType.tryParse('text'), InputType.text);
    });

    test('tryParse should return null for invalid code', () {
      expect(InputType.tryParse('invalid'), isNull);
    });
  });
}
