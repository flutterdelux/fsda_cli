import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:test/test.dart';

void main() {
  group('UcType', () {
    group('Enum Values', () {
      test('GIVEN all 12 defined UcType enum constants '
          'WHEN value getter is accessed '
          'THEN returns corresponding PascalCase UseCase class name', () {
        // Given & When & Then
        expect(UcType.values, hasLength(12));
        expect(UcType.voidUc.value, 'VoidUseCase');
        expect(UcType.paramUc.value, 'ParamUseCase');
        expect(UcType.returnUc.value, 'ReturnUseCase');
        expect(UcType.returnParamUc.value, 'ReturnParamUseCase');
        expect(UcType.voidSyncUc.value, 'VoidSyncUseCase');
        expect(UcType.paramSyncUc.value, 'ParamSyncUseCase');
        expect(UcType.returnSyncUc.value, 'ReturnSyncUseCase');
        expect(UcType.returnParamSyncUc.value, 'ReturnParamSyncUseCase');
        expect(UcType.voidStreamUc.value, 'VoidStreamUseCase');
        expect(UcType.paramStreamUc.value, 'ParamStreamUseCase');
        expect(UcType.returnStreamUc.value, 'ReturnStreamUseCase');
        expect(UcType.returnParamStreamUc.value, 'ReturnParamStreamUseCase');
      });
    });

    group('tryParse', () {
      test(
        'GIVEN valid PascalCase UseCase class names matching UcType constants '
        'WHEN tryParse is called '
        'THEN returns the corresponding UcType enum constant',
        () {
          // Given
          const inputs = {
            'VoidUseCase': UcType.voidUc,
            'ParamUseCase': UcType.paramUc,
            'ReturnUseCase': UcType.returnUc,
            'ReturnParamUseCase': UcType.returnParamUc,
            'VoidSyncUseCase': UcType.voidSyncUc,
            'ParamSyncUseCase': UcType.paramSyncUc,
            'ReturnSyncUseCase': UcType.returnSyncUc,
            'ReturnParamSyncUseCase': UcType.returnParamSyncUc,
            'VoidStreamUseCase': UcType.voidStreamUc,
            'ParamStreamUseCase': UcType.paramStreamUc,
            'ReturnStreamUseCase': UcType.returnStreamUc,
            'ReturnParamStreamUseCase': UcType.returnParamStreamUc,
          };

          // When & Then
          inputs.forEach((rawValue, expectedEnum) {
            expect(UcType.tryParse(rawValue), expectedEnum);
          });
        },
      );

      test('GIVEN unknown, lowercase, camelCase, or empty string '
          'WHEN tryParse is called '
          'THEN returns null', () {
        // Given
        const invalidInputs = [
          '',
          'voidUseCase',
          'void_use_case',
          'VOIDUSECASE',
          'UseCase',
          ' VoidUseCase ',
          'UnknownUseCase',
        ];

        // When & Then
        for (final input in invalidInputs) {
          expect(UcType.tryParse(input), isNull);
        }
      });
    });
  });
}
