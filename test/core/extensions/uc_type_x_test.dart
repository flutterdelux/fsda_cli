import 'package:fsda_cli/core/extensions/uc_type_x.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:test/test.dart';

void main() {
  group('UcType & UcTypeX Tests', () {
    test('should return correct UcType from fromValue method', () {
      expect(UcType.fromValue('VoidUseCase'), UcType.voidUc);
      expect(UcType.fromValue('ParamUseCase'), UcType.paramUc);
      expect(UcType.fromValue('ReturnStreamUseCase'), UcType.returnStreamUc);
      expect(
        UcType.fromValue('ReturnParamSyncUseCase'),
        UcType.returnParamSyncUc,
      );
      expect(UcType.fromValue('InvalidUseCase'), isNull);
    });

    test('should evaluate hasReturn flag correctly for UcType', () {
      expect(UcType.returnUc.hasReturn, isTrue);
      expect(UcType.returnParamUc.hasReturn, isTrue);
      expect(UcType.returnStreamUc.hasReturn, isTrue);
      expect(UcType.returnParamStreamUc.hasReturn, isTrue);
      expect(UcType.returnSyncUc.hasReturn, isTrue);
      expect(UcType.returnParamSyncUc.hasReturn, isTrue);

      expect(UcType.voidUc.hasReturn, isFalse);
      expect(UcType.paramUc.hasReturn, isFalse);
      expect(UcType.voidStreamUc.hasReturn, isFalse);
      expect(UcType.paramStreamUc.hasReturn, isFalse);
    });

    test('should evaluate hasParam flag correctly for UcType', () {
      expect(UcType.paramUc.hasParam, isTrue);
      expect(UcType.returnParamUc.hasParam, isTrue);
      expect(UcType.paramSyncUc.hasParam, isTrue);
      expect(UcType.returnParamSyncUc.hasParam, isTrue);
      expect(UcType.paramStreamUc.hasParam, isTrue);
      expect(UcType.returnParamStreamUc.hasParam, isTrue);

      expect(UcType.voidUc.hasParam, isFalse);
      expect(UcType.returnUc.hasParam, isFalse);
      expect(UcType.voidSyncUc.hasParam, isFalse);
      expect(UcType.returnSyncUc.hasParam, isFalse);
    });

    test('should evaluate isAsync flag correctly for UcType', () {
      expect(UcType.voidUc.isAsync, isTrue);
      expect(UcType.paramUc.isAsync, isTrue);
      expect(UcType.returnUc.isAsync, isTrue);
      expect(UcType.returnParamUc.isAsync, isTrue);

      expect(UcType.voidSyncUc.isAsync, isFalse);
      expect(UcType.returnStreamUc.isAsync, isFalse);
    });

    test('should evaluate isStream flag correctly for UcType', () {
      expect(UcType.voidStreamUc.isStream, isTrue);
      expect(UcType.paramStreamUc.isStream, isTrue);
      expect(UcType.returnStreamUc.isStream, isTrue);
      expect(UcType.returnParamStreamUc.isStream, isTrue);

      expect(UcType.voidUc.isStream, isFalse);
      expect(UcType.paramSyncUc.isStream, isFalse);
    });
  });
}
