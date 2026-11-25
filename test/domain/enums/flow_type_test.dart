import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:test/test.dart';

void main() {
  group('FlowType', () {
    group('Enum Values', () {
      test('GIVEN all defined FlowType enum constants '
          'WHEN values and value property are accessed '
          'THEN returns expected string identifiers in declaration order', () {
        // When & Then
        expect(FlowType.values, [
          FlowType.synchronous,
          FlowType.asynchronous,
          FlowType.stream,
        ]);
        expect(FlowType.synchronous.value, 'sync');
        expect(FlowType.asynchronous.value, 'async');
        expect(FlowType.stream.value, 'stream');
      });
    });

    group('tryParse', () {
      test('GIVEN valid FlowType string values '
          'WHEN tryParse is called '
          'THEN returns the corresponding FlowType enum constant', () {
        // Given
        const inputs = {
          'sync': FlowType.synchronous,
          'async': FlowType.asynchronous,
          'stream': FlowType.stream,
        };

        // When & Then
        inputs.forEach((rawValue, expectedEnum) {
          expect(FlowType.tryParse(rawValue), expectedEnum);
        });
      });

      test('GIVEN unknown, full-name, uppercase, or empty string values '
          'WHEN tryParse is called '
          'THEN returns null', () {
        // Given
        const invalidInputs = [
          'unknown',
          '',
          'synchronous',
          'asynchronous',
          'SYNC',
          ' async ',
        ];

        // When & Then
        for (final input in invalidInputs) {
          expect(FlowType.tryParse(input), isNull);
        }
      });
    });

    group('available', () {
      test('GIVEN FlowType enum '
          'WHEN available getter is accessed '
          'THEN returns comma-separated list of all valid values', () {
        // When & Then
        expect(FlowType.available, 'sync, async, stream');
      });
    });
  });
}
