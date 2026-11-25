import 'package:fsda_cli/domain/enums/ui_type.dart';
import 'package:test/test.dart';

void main() {
  group('UiType', () {
    test('GIVEN all UiType enum values '
        'WHEN value property is accessed '
        'THEN returns expected string identifiers in declaration order', () {
      // When & Then
      expect(UiType.values, [
        UiType.standard,
        UiType.form,
        UiType.lsh,
        UiType.lsv,
        UiType.pag,
      ]);
      expect(UiType.standard.value, 'standard');
      expect(UiType.form.value, 'form');
      expect(UiType.lsh.value, 'lsh');
      expect(UiType.lsv.value, 'lsv');
      expect(UiType.pag.value, 'pag');
    });

    group('tryParse', () {
      test('GIVEN valid UiType string values '
          'WHEN tryParse is called '
          'THEN returns the corresponding UiType enum member', () {
        // Given
        const cases = <String, UiType>{
          'standard': UiType.standard,
          'form': UiType.form,
          'lsh': UiType.lsh,
          'lsv': UiType.lsv,
          'pag': UiType.pag,
        };

        // When & Then
        cases.forEach((rawValue, expected) {
          expect(UiType.tryParse(rawValue), expected);
        });
      });

      test('GIVEN invalid, uppercase, or empty string values '
          'WHEN tryParse is called '
          'THEN returns null', () {
        // Given
        const invalidValues = ['', 'STANDARD', 'list', 'grid', 'unknown'];

        // When & Then
        for (final rawValue in invalidValues) {
          expect(UiType.tryParse(rawValue), isNull);
        }
      });
    });

    group('available', () {
      test('GIVEN UiType enum '
          'WHEN available getter is accessed '
          'THEN returns comma-separated list of all valid values', () {
        // When & Then
        expect(UiType.available, 'standard, form, lsh, lsv, pag');
      });
    });
  });
}
