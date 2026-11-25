import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:test/test.dart';

void main() {
  group('LogicFlowType', () {
    group('Enum Values', () {
      test('GIVEN all defined LogicFlowType enum constants '
          'WHEN value getter is accessed '
          'THEN returns corresponding short string representation', () {
        // Given & When & Then
        expect(LogicFlowType.values, hasLength(3));
        expect(LogicFlowType.mutation.value, 'm');
        expect(LogicFlowType.retrieval.value, 'r');
        expect(LogicFlowType.pagination.value, 'pag');
      });
    });

    group('tryParse', () {
      test('GIVEN valid short string values matching LogicFlowType constants '
          'WHEN tryParse is called '
          'THEN returns the corresponding LogicFlowType enum constant', () {
        // Given
        const inputs = {
          'm': LogicFlowType.mutation,
          'r': LogicFlowType.retrieval,
          'pag': LogicFlowType.pagination,
        };

        // When & Then
        inputs.forEach((rawValue, expectedEnum) {
          expect(LogicFlowType.tryParse(rawValue), expectedEnum);
        });
      });

      test('GIVEN unknown, full-name, uppercase, or empty string '
          'WHEN tryParse is called '
          'THEN returns null', () {
        // Given
        const invalidInputs = [
          '',
          'mutation',
          'retrieval',
          'pagination',
          'M',
          'PAG',
          ' m ',
          'unknown',
        ];

        // When & Then
        for (final input in invalidInputs) {
          expect(LogicFlowType.tryParse(input), isNull);
        }
      });
    });

    group('available', () {
      test('GIVEN LogicFlowType enum '
          'WHEN available getter is accessed '
          'THEN returns comma-separated list of all valid values', () {
        // When & Then
        expect(LogicFlowType.available, 'm, r, pag');
      });
    });
  });
}
