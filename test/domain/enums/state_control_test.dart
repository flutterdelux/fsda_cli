import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:test/test.dart';

void main() {
  group('StateControl', () {
    group('Enum Values & available Getter', () {
      test('GIVEN all defined StateControl enum constants '
          'WHEN value getter is accessed '
          'THEN returns corresponding lowercase string representation', () {
        // Given & When & Then
        expect(StateControl.values, hasLength(4));
        expect(StateControl.cubit.value, 'cubit');
        expect(StateControl.getx.value, 'getx');
        expect(StateControl.provider.value, 'provider');
        expect(StateControl.riverpod.value, 'riverpod');
      });

      test('GIVEN StateControl enum '
          'WHEN available getter is accessed '
          'THEN returns comma-separated list of all enum values', () {
        // When
        final result = StateControl.available;

        // Then
        expect(result, 'cubit, getx, provider, riverpod');
      });
    });

    group('tryParse', () {
      test('GIVEN valid lowercase strings matching StateControl values '
          'WHEN tryParse is called '
          'THEN returns the corresponding StateControl enum constant', () {
        // Given
        const inputs = {
          'cubit': StateControl.cubit,
          'getx': StateControl.getx,
          'provider': StateControl.provider,
          'riverpod': StateControl.riverpod,
        };

        // When & Then
        inputs.forEach((rawValue, expectedEnum) {
          expect(StateControl.tryParse(rawValue), expectedEnum);
        });
      });

      test('GIVEN null, empty, uppercase, or unknown string '
          'WHEN tryParse is called '
          'THEN returns null', () {
        // Given
        const invalidInputs = [null, '', 'CUBIT', 'bloc', ' cubit '];

        // When & Then
        for (final input in invalidInputs) {
          expect(StateControl.tryParse(input), isNull);
        }
      });
    });

    group('parseFromExtends', () {
      test('GIVEN supported parent class names '
          'WHEN parseFromExtends is called '
          'THEN returns the matching StateControl enum constant', () {
        // Given
        const parentClassCases = {
          'Cubit': StateControl.cubit,
          'GetxController': StateControl.getx,
          'ChangeNotifier': StateControl.provider,
          'Notifier': StateControl.riverpod,
        };

        // When & Then
        parentClassCases.forEach((parentClass, expectedEnum) {
          expect(StateControl.parseFromExtends(parentClass), expectedEnum);
        });
      });

      test('GIVEN unsupported, lowercase, or empty parent class name '
          'WHEN parseFromExtends is called '
          'THEN returns null', () {
        // Given
        const invalidParentClasses = [
          'Bloc',
          'cubit',
          'StateNotifier',
          'StatelessWidget',
          '',
        ];

        // When & Then
        for (final parentClass in invalidParentClasses) {
          expect(StateControl.parseFromExtends(parentClass), isNull);
        }
      });
    });
  });
}
