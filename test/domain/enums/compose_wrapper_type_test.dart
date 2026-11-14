import 'package:fsda_cli/domain/enums/compose_wrapper_type.dart';
import 'package:test/test.dart';

void main() {
  group('ComposeWrapperType Tests', () {
    test(
      'tryParse should return correct ComposeWrapperType for valid string',
      () {
        expect(ComposeWrapperType.tryParse('page'), ComposeWrapperType.page);
        expect(
          ComposeWrapperType.tryParse('section'),
          ComposeWrapperType.section,
        );
        expect(ComposeWrapperType.tryParse('sheet'), ComposeWrapperType.sheet);
        expect(
          ComposeWrapperType.tryParse('dialog'),
          ComposeWrapperType.dialog,
        );
      },
    );

    test('tryParse should return null for invalid, empty, or null string', () {
      expect(ComposeWrapperType.tryParse('unknown'), isNull);
      expect(ComposeWrapperType.tryParse(''), isNull);
      expect(ComposeWrapperType.tryParse(null), isNull);
      expect(
        ComposeWrapperType.tryParse('PAGE'),
        isNull,
      ); // Memastikan bersifat case-sensitive
    });
  });
}
