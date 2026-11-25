import 'package:fsda_cli/domain/enums/plan_type.dart';
import 'package:test/test.dart';

void main() {
  group('PlanType', () {
    group('Enum Values', () {
      test('GIVEN all defined PlanType enum constants '
          'WHEN values and value property are accessed '
          'THEN returns expected string identifiers in declaration order', () {
        // When & Then
        expect(PlanType.values, [
          PlanType.module,
          PlanType.feature,
          PlanType.app,
        ]);
        expect(PlanType.module.value, 'module');
        expect(PlanType.feature.value, 'feature');
        expect(PlanType.app.value, 'app');
      });
    });

    group('tryParse', () {
      test('GIVEN valid PlanType string values '
          'WHEN tryParse is called '
          'THEN returns the corresponding PlanType enum constant', () {
        // Given
        const inputs = <String, PlanType>{
          'module': PlanType.module,
          'feature': PlanType.feature,
          'app': PlanType.app,
        };

        // When & Then
        inputs.forEach((rawValue, expectedEnum) {
          expect(PlanType.tryParse(rawValue), expectedEnum);
        });
      });

      test('GIVEN unknown, uppercase, or empty string values '
          'WHEN tryParse is called '
          'THEN returns null', () {
        // Given
        const invalidInputs = [
          '',
          'MODULE',
          'FEATURE',
          'APP',
          ' module ',
          'workspace',
          'unknown',
        ];

        // When & Then
        for (final input in invalidInputs) {
          expect(PlanType.tryParse(input), isNull);
        }
      });
    });

    group('available', () {
      test('GIVEN PlanType enum '
          'WHEN available getter is accessed '
          'THEN returns comma-separated list of all valid values', () {
        // When & Then
        expect(PlanType.available, 'module, feature, app');
      });
    });
  });
}
