import 'package:fsda_cli/domain/enums/model_type.dart';
import 'package:test/test.dart';

void main() {
  group('ModelType', () {
    group('Enum Values', () {
      test('GIVEN all defined ModelType enum constants '
          'WHEN suffix getter is accessed '
          'THEN returns corresponding lowercase string representation', () {
        // Given & When & Then
        expect(ModelType.values, hasLength(5));
        expect(ModelType.entity.suffix, 'entity');
        expect(ModelType.param.suffix, 'param');
        expect(ModelType.dto.suffix, 'dto');
        expect(ModelType.request.suffix, 'request');
        expect(ModelType.response.suffix, 'response');
      });
    });

    group('tryParse', () {
      test('GIVEN valid lowercase string values matching ModelType constants '
          'WHEN tryParse is called '
          'THEN returns the corresponding ModelType enum constant', () {
        // Given
        const inputs = {
          'entity': ModelType.entity,
          'param': ModelType.param,
          'dto': ModelType.dto,
          'request': ModelType.request,
          'response': ModelType.response,
        };

        // When & Then
        inputs.forEach((rawValue, expectedEnum) {
          expect(ModelType.tryParse(rawValue), expectedEnum);
        });
      });

      test('GIVEN an unknown, uppercase, or empty string '
          'WHEN tryParse is called '
          'THEN returns null', () {
        // Given
        const invalidInputs = ['unknown', 'ENTITY', 'Dto', ' entity ', ''];

        // When & Then
        for (final input in invalidInputs) {
          expect(ModelType.tryParse(input), isNull);
        }
      });
    });

    group('available', () {
      test('GIVEN ModelType enum '
          'WHEN available getter is accessed '
          'THEN returns comma-separated list of all valid suffixes', () {
        // When & Then
        expect(ModelType.available, 'entity, param, dto, request, response');
      });
    });
  });
}
