import 'package:fsda_cli/core/constants/rules.dart';
import 'package:test/test.dart';

void main() {
  group('Rules', () {
    group('Strict snake_case RegExp Rules', () {
      final snakeCaseRules = <String, RegExp>{
        'appNameRegExp': Rules.appNameRegExp,
        'workspaceRegExp': Rules.workspaceRegExp,
        'moduleRegExp': Rules.moduleRegExp,
        'featureRegExp': Rules.featureRegExp,
        'enumRegExp': Rules.enumRegExp,
        'enumValueRegExp': Rules.enumValueRegExp,
        'modelRegExp': Rules.modelRegExp,
        'propNameRegExp': Rules.propNameRegExp,
        'usecaseRegExp': Rules.usecaseRegExp,
        'methodRegExp': Rules.methodRegExp,
        'cacheKeyRegExp': Rules.cacheKeyRegExp,
        'sliceRegExp': Rules.sliceRegExp,
        'fieldNameRegExp': Rules.fieldNameRegExp,
        'modelTypeRegExp': Rules.modelTypeRegExp,
        'failureNameRegExp': Rules.failureNameRegExp,
        'composeTargetRegExp': Rules.composeTargetRegExp,
      };

      test('GIVEN valid strict snake_case strings '
          'WHEN matched against all snake_case RegExp rules '
          'THEN returns true for every valid input', () {
        // Given
        const validInputs = [
          'task',
          'user_profile',
          'task_create_use_case',
          'item_v2',
          'step_1_done',
        ];

        // When & Then
        snakeCaseRules.forEach((ruleName, regex) {
          for (final input in validInputs) {
            expect(
              regex.hasMatch(input),
              isTrue,
              reason: '$ruleName should match "$input"',
            );
          }
        });
      });

      test('GIVEN invalid non-snake_case strings '
          'WHEN matched against all snake_case RegExp rules '
          'THEN returns false for every invalid input', () {
        // Given
        const invalidInputs = [
          '',
          'Task',
          'userProfile',
          'user-profile',
          'user profile',
          '_leading_underscore',
          'trailing_underscore_',
          'double__underscore',
          '1starts_with_number',
          'user_profile!',
        ];

        // When & Then
        snakeCaseRules.forEach((ruleName, regex) {
          for (final input in invalidInputs) {
            expect(
              regex.hasMatch(input),
              isFalse,
              reason: '$ruleName should not match "$input"',
            );
          }
        });
      });
    });

    group('propConverterRegExp (Strict PascalCase)', () {
      test('GIVEN valid PascalCase converter class names '
          'WHEN matched against propConverterRegExp '
          'THEN returns true', () {
        // Given
        const validConverters = [
          'Converter',
          'TaskStatusConverter',
          'UtcDateTimeConverter',
          'V2Converter',
        ];

        // When & Then
        for (final input in validConverters) {
          expect(
            Rules.propConverterRegExp.hasMatch(input),
            isTrue,
            reason: 'propConverterRegExp should match "$input"',
          );
        }
      });

      test('GIVEN invalid non-PascalCase converter names '
          'WHEN matched against propConverterRegExp '
          'THEN returns false', () {
        // Given
        const invalidConverters = [
          '',
          'taskStatusConverter',
          'task_status_converter',
          'Task_Status_Converter',
          '1Converter',
          'Task-Converter',
          'Task Converter',
        ];

        // When & Then
        for (final input in invalidConverters) {
          expect(
            Rules.propConverterRegExp.hasMatch(input),
            isFalse,
            reason: 'propConverterRegExp should not match "$input"',
          );
        }
      });
    });

    group('orgRegExp (Reverse Domain)', () {
      test('GIVEN valid lowercase reverse-domain strings '
          'WHEN matched against orgRegExp '
          'THEN returns true', () {
        // Given
        const validOrgs = [
          'com.example',
          'id.co.ruviti',
          'com.company2',
          'io.github.user123.app',
        ];

        // When & Then
        for (final input in validOrgs) {
          expect(
            Rules.orgRegExp.hasMatch(input),
            isTrue,
            reason: 'orgRegExp should match "$input"',
          );
        }
      });

      test('GIVEN invalid reverse-domain strings '
          'WHEN matched against orgRegExp '
          'THEN returns false', () {
        // Given
        const invalidOrgs = [
          '',
          'com',
          'Com.Example',
          'com.Example',
          'com.my_company',
          'com.my-company',
          'com.2company',
          '2com.example',
          '.com.example',
          'com.example.',
          'com..example',
        ];

        // When & Then
        for (final input in invalidOrgs) {
          expect(
            Rules.orgRegExp.hasMatch(input),
            isFalse,
            reason: 'orgRegExp should not match "$input"',
          );
        }
      });
    });

    group('Description Constants and Defaults', () {
      test('GIVEN Rules constants '
          'WHEN descriptions and default values are accessed '
          'THEN returns non-empty descriptions and expected orgDefault', () {
        // When & Then
        expect(Rules.orgDefault, 'com.example');
        expect(Rules.appNameDescription, isNotEmpty);
        expect(Rules.orgDescription, isNotEmpty);
        expect(Rules.workspaceDescription, isNotEmpty);
        expect(Rules.moduleDescription, isNotEmpty);
        expect(Rules.featureDescription, isNotEmpty);
        expect(Rules.enumDescription, isNotEmpty);
        expect(Rules.enumValueDescription, isNotEmpty);
        expect(Rules.modelDescription, isNotEmpty);
        expect(Rules.propNameDescription, isNotEmpty);
        expect(Rules.propConverterDescription, isNotEmpty);
        expect(Rules.usecaseDescription, isNotEmpty);
        expect(Rules.methodDescription, isNotEmpty);
        expect(Rules.cacheKeyDescription, isNotEmpty);
        expect(Rules.sliceDescription, isNotEmpty);
        expect(Rules.fieldNameDescription, isNotEmpty);
        expect(Rules.modelTypeDescription, isNotEmpty);
        expect(Rules.failureNameDescription, isNotEmpty);
        expect(Rules.composeTargetDescription, isNotEmpty);
      });
    });
  });
}
