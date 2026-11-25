import 'package:fsda_cli/core/extensions/uc_type_x.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:test/test.dart';

void main() {
  group('UcTypeX', () {
    group('hasReturn', () {
      test('GIVEN UcType values with return types '
          'WHEN hasReturn getter is accessed '
          'THEN returns true', () {
        // Given
        const returnTypes = [
          UcType.returnUc,
          UcType.returnSyncUc,
          UcType.returnStreamUc,
          UcType.returnParamUc,
          UcType.returnParamSyncUc,
          UcType.returnParamStreamUc,
        ];

        // When & Then
        for (final type in returnTypes) {
          expect(
            type.hasReturn,
            isTrue,
            reason: '${type.name} should have return',
          );
        }
      });

      test('GIVEN UcType values without return types '
          'WHEN hasReturn getter is accessed '
          'THEN returns false', () {
        // Given
        const nonReturnTypes = [
          UcType.voidUc,
          UcType.voidSyncUc,
          UcType.voidStreamUc,
          UcType.paramUc,
          UcType.paramSyncUc,
          UcType.paramStreamUc,
        ];

        // When & Then
        for (final type in nonReturnTypes) {
          expect(
            type.hasReturn,
            isFalse,
            reason: '${type.name} should not have return',
          );
        }
      });
    });

    group('hasParam', () {
      test('GIVEN UcType values with parameters '
          'WHEN hasParam getter is accessed '
          'THEN returns true', () {
        // Given
        const paramTypes = [
          UcType.paramUc,
          UcType.paramSyncUc,
          UcType.paramStreamUc,
          UcType.returnParamUc,
          UcType.returnParamSyncUc,
          UcType.returnParamStreamUc,
        ];

        // When & Then
        for (final type in paramTypes) {
          expect(
            type.hasParam,
            isTrue,
            reason: '${type.name} should have param',
          );
        }
      });

      test('GIVEN UcType values without parameters '
          'WHEN hasParam getter is accessed '
          'THEN returns false', () {
        // Given
        const nonParamTypes = [
          UcType.voidUc,
          UcType.voidSyncUc,
          UcType.voidStreamUc,
          UcType.returnUc,
          UcType.returnSyncUc,
          UcType.returnStreamUc,
        ];

        // When & Then
        for (final type in nonParamTypes) {
          expect(
            type.hasParam,
            isFalse,
            reason: '${type.name} should not have param',
          );
        }
      });
    });

    group('isAsync', () {
      test('GIVEN asynchronous UcType values '
          'WHEN isAsync getter is accessed '
          'THEN returns true', () {
        // Given
        const asyncTypes = [
          UcType.voidUc,
          UcType.paramUc,
          UcType.returnUc,
          UcType.returnParamUc,
        ];

        // When & Then
        for (final type in asyncTypes) {
          expect(type.isAsync, isTrue, reason: '${type.name} should be async');
        }
      });

      test('GIVEN synchronous and stream UcType values '
          'WHEN isAsync getter is accessed '
          'THEN returns false', () {
        // Given
        const nonAsyncTypes = [
          UcType.voidSyncUc,
          UcType.paramSyncUc,
          UcType.returnSyncUc,
          UcType.returnParamSyncUc,
          UcType.voidStreamUc,
          UcType.paramStreamUc,
          UcType.returnStreamUc,
          UcType.returnParamStreamUc,
        ];

        // When & Then
        for (final type in nonAsyncTypes) {
          expect(
            type.isAsync,
            isFalse,
            reason: '${type.name} should not be async',
          );
        }
      });
    });

    group('isStream', () {
      test('GIVEN stream UcType values '
          'WHEN isStream getter is accessed '
          'THEN returns true', () {
        // Given
        const streamTypes = [
          UcType.voidStreamUc,
          UcType.paramStreamUc,
          UcType.returnStreamUc,
          UcType.returnParamStreamUc,
        ];

        // When & Then
        for (final type in streamTypes) {
          expect(
            type.isStream,
            isTrue,
            reason: '${type.name} should be stream',
          );
        }
      });

      test('GIVEN asynchronous and synchronous UcType values '
          'WHEN isStream getter is accessed '
          'THEN returns false', () {
        // Given
        const nonStreamTypes = [
          UcType.voidUc,
          UcType.paramUc,
          UcType.returnUc,
          UcType.returnParamUc,
          UcType.voidSyncUc,
          UcType.paramSyncUc,
          UcType.returnSyncUc,
          UcType.returnParamSyncUc,
        ];

        // When & Then
        for (final type in nonStreamTypes) {
          expect(
            type.isStream,
            isFalse,
            reason: '${type.name} should not be stream',
          );
        }
      });
    });
  });
}
