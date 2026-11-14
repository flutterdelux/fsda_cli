import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:test/test.dart';

void main() {
  group('UcType Tests', () {
    test('fromValue should return correct UcType for valid string', () {
      expect(UcType.fromValue('VoidUseCase'), UcType.voidUc);
      expect(UcType.fromValue('ParamUseCase'), UcType.paramUc);
      expect(UcType.fromValue('ReturnUseCase'), UcType.returnUc);
      expect(UcType.fromValue('ReturnParamUseCase'), UcType.returnParamUc);
      expect(UcType.fromValue('VoidSyncUseCase'), UcType.voidSyncUc);
      expect(UcType.fromValue('ParamSyncUseCase'), UcType.paramSyncUc);
      expect(UcType.fromValue('ReturnSyncUseCase'), UcType.returnSyncUc);
      expect(
        UcType.fromValue('ReturnParamSyncUseCase'),
        UcType.returnParamSyncUc,
      );
      expect(UcType.fromValue('VoidStreamUseCase'), UcType.voidStreamUc);
      expect(UcType.fromValue('ParamStreamUseCase'), UcType.paramStreamUc);
      expect(UcType.fromValue('ReturnStreamUseCase'), UcType.returnStreamUc);
      expect(
        UcType.fromValue('ReturnParamStreamUseCase'),
        UcType.returnParamStreamUc,
      );
    });

    test('fromValue should return null for invalid string', () {
      expect(UcType.fromValue('unknown'), isNull);
    });
  });
}
