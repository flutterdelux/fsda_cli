import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:test/test.dart';

void main() {
  group('DsMode', () {
    group('Enum Values', () {
      test('GIVEN all defined DsMode enum constants '
          'WHEN values and value property are accessed '
          'THEN returns expected string identifiers in declaration order', () {
        // When & Then
        expect(DsMode.values, [DsMode.local, DsMode.remote]);
        expect(DsMode.local.value, 'local');
        expect(DsMode.remote.value, 'remote');
      });
    });

    group('tryParse', () {
      test('GIVEN valid DsMode string values '
          'WHEN tryParse is called '
          'THEN returns the corresponding DsMode enum constant', () {
        // Given
        const inputs = {'local': DsMode.local, 'remote': DsMode.remote};

        // When & Then
        inputs.forEach((rawValue, expectedEnum) {
          expect(DsMode.tryParse(rawValue), expectedEnum);
        });
      });

      test('GIVEN unknown, uppercase, or empty string values '
          'WHEN tryParse is called '
          'THEN returns null', () {
        // Given
        const invalidInputs = ['unknown', '', 'LOCAL', 'REMOTE', ' local '];

        // When & Then
        for (final input in invalidInputs) {
          expect(DsMode.tryParse(input), isNull);
        }
      });
    });

    group('available', () {
      test('GIVEN DsMode enum '
          'WHEN available getter is accessed '
          'THEN returns comma-separated list of all valid values', () {
        // When & Then
        expect(DsMode.available, 'local, remote');
      });
    });
  });
}
