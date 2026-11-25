import 'package:fsda_cli/domain/enums/compose_type.dart';
import 'package:test/test.dart';

void main() {
  group('ComposeType', () {
    group('Enum Values', () {
      test('GIVEN all defined ComposeType enum constants '
          'WHEN values and value property are accessed '
          'THEN returns expected string identifiers in declaration order', () {
        // When & Then
        expect(ComposeType.values, [
          ComposeType.mutation,
          ComposeType.retrieval,
          ComposeType.pagination,
          ComposeType.form,
        ]);
        expect(ComposeType.mutation.value, 'm');
        expect(ComposeType.retrieval.value, 'r');
        expect(ComposeType.pagination.value, 'pag');
        expect(ComposeType.form.value, 'form');
      });
    });

    group('tryParse', () {
      test('GIVEN valid ComposeType string values '
          'WHEN tryParse is called '
          'THEN returns the corresponding ComposeType enum constant', () {
        // Given
        const inputs = <String, ComposeType>{
          'm': ComposeType.mutation,
          'r': ComposeType.retrieval,
          'pag': ComposeType.pagination,
          'form': ComposeType.form,
        };

        // When & Then
        inputs.forEach((rawValue, expectedEnum) {
          expect(ComposeType.tryParse(rawValue), expectedEnum);
        });
      });

      test('GIVEN unknown, full-name, uppercase, or empty string values '
          'WHEN tryParse is called '
          'THEN returns null', () {
        // Given
        const invalidInputs = [
          '',
          'mutation',
          'retrieval',
          'pagination',
          'M',
          'FORM',
          ' m ',
          'unknown',
        ];

        // When & Then
        for (final input in invalidInputs) {
          expect(ComposeType.tryParse(input), isNull);
        }
      });
    });

    group('available', () {
      test('GIVEN ComposeType enum '
          'WHEN available getter is accessed '
          'THEN returns comma-separated list of all valid values', () {
        // When & Then
        expect(ComposeType.available, 'm, r, pag, form');
      });
    });
  });
}
