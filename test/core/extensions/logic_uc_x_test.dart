import 'package:fsda_cli/core/extensions/logic_uc_x.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:test/test.dart';

void main() {
  group('LogicUcX Tests', () {
    test('should format uc name casing correctly', () {
      const model = LogicUcModel(
        name: 'get_user_profile',
        path: 'domain/usecases/get_user_profile_uc.dart',
        type: UcType.returnUc,
        method: 'execute',
      );

      expect(model.ucSnake, 'get_user_profile');
      expect(model.ucCamel, 'getUserProfile');
      expect(model.ucPascal, 'GetUserProfile');
    });

    test(
      'should format returnType casing correctly when returnType is provided',
      () {
        const model = LogicUcModel(
          name: 'get_user',
          path: 'path',
          type: UcType.returnUc,
          method: 'execute',
          returnType: 'user_entity',
        );

        expect(model.returnSnake, 'user_entity');
        expect(model.returnCamel, 'userEntity');
        expect(model.returnPascal, 'UserEntity');
      },
    );

    test(
      'should return null for returnType casing when returnType is null',
      () {
        const model = LogicUcModel(
          name: 'void_uc',
          path: 'path',
          type: UcType.paramUc,
          method: 'execute',
          returnType: null,
        );

        expect(model.returnSnake, isNull);
        expect(model.returnCamel, isNull);
        expect(model.returnPascal, isNull);
      },
    );

    test(
      'should format paramType casing correctly when paramType is provided',
      () {
        const model = LogicUcModel(
          name: 'update_user',
          path: 'path',
          type: UcType.paramUc,
          method: 'execute',
          paramType: 'update_user_param',
        );

        expect(model.paramSnake, 'update_user_param');
        expect(model.paramCamel, 'updateUserParam');
        expect(model.paramPascal, 'UpdateUserParam');
      },
    );

    test('should return null for paramType casing when paramType is null', () {
      const model = LogicUcModel(
        name: 'simple_uc',
        path: 'path',
        type: UcType.returnUc,
        method: 'execute',
        paramType: null,
      );

      expect(model.paramSnake, isNull);
      expect(model.paramCamel, isNull);
      expect(model.paramPascal, isNull);
    });
  });
}
