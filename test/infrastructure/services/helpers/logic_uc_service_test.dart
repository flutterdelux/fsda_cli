import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/logic_uc_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFileService extends Mock implements FileService {}

void main() {
  late LogicUcService logicUcService;
  late MockFileService mockFileService;

  const usecasePath =
      '/project/lib/features/auth/domain/usecases/get_user_use_case.dart';

  setUp(() {
    mockFileService = MockFileService();
    logicUcService = LogicUcService(fileService: mockFileService);
  });

  group('LogicUcService Tests', () {
    test(
      'inspectUseCase should throw Exception if use case file does not exist',
      () async {
        when(
          () => mockFileService.exists(usecasePath),
        ).thenAnswer((_) async => false);

        expect(
          () => logicUcService.inspectUseCase(
            usecaseName: 'GetUserUseCase',
            usecasePath: usecasePath,
          ),
          throwsException,
        );

        verify(() => mockFileService.exists(usecasePath)).called(1);
      },
    );

    test(
      'inspectUseCase should throw Exception if UcType cannot be detected',
      () async {
        when(
          () => mockFileService.exists(usecasePath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(usecasePath),
        ).thenAnswer((_) async => 'class InvalidUseCase {}');

        expect(
          () => logicUcService.inspectUseCase(
            usecaseName: 'InvalidUseCase',
            usecasePath: usecasePath,
          ),
          throwsException,
        );
      },
    );

    test(
      'inspectUseCase should parse and return LogicUcModel correctly for ReturnParamUseCase',
      () async {
        when(
          () => mockFileService.exists(usecasePath),
        ).thenAnswer((_) async => true);

        const fileContent = '''
import 'package:fsda_cli/core/usecases/usecase.dart';

class GetUserUseCase extends ReturnParamUseCase<UserEntity, UserParam> {
  final AuthRepository _repository;

  GetUserUseCase(this._repository);

  Future<UserEntity> call(UserParam param) async {
    return await _repository.fetchUser(param);
  }
}
''';

        when(
          () => mockFileService.readAsString(usecasePath),
        ).thenAnswer((_) async => fileContent);

        final model = await logicUcService.inspectUseCase(
          usecaseName: 'GetUserUseCase',
          usecasePath: usecasePath,
        );

        expect(model.name, 'GetUserUseCase');
        expect(model.path, usecasePath);
        expect(model.method, 'fetchUser');
        expect(model.returnType, 'UserEntity');
        expect(model.paramType, 'UserParam');
      },
    );

    test(
      'inspectUseCase should parse ParamUseCase correctly (single generic type with Param)',
      () async {
        when(
          () => mockFileService.exists(usecasePath),
        ).thenAnswer((_) async => true);

        const fileContent = '''
class UpdateUserUseCase extends ParamUseCase<UserParam> {
  final AuthRepository _repository;

  UpdateUserUseCase(this._repository);

  Future<void> call(UserParam param) async {
    await _repository.updateUser(param);
  }
}
''';

        when(
          () => mockFileService.readAsString(usecasePath),
        ).thenAnswer((_) async => fileContent);

        final model = await logicUcService.inspectUseCase(
          usecaseName: 'UpdateUserUseCase',
          usecasePath: usecasePath,
        );

        expect(model.name, 'UpdateUserUseCase');
        expect(model.paramType, 'UserParam');
        expect(model.returnType, isNull);
        expect(model.method, 'updateUser');
      },
    );

    test(
      'inspectUseCase should parse ReturnUseCase correctly (single generic type without Param)',
      () async {
        when(
          () => mockFileService.exists(usecasePath),
        ).thenAnswer((_) async => true);

        const fileContent = '''
class GetSettingsUseCase extends ReturnUseCase<SettingsEntity> {
  final SettingsRepository _repository;

  GetSettingsUseCase(this._repository);

  Future<SettingsEntity> call() async {
    return await _repository.getSettings();
  }
}
''';

        when(
          () => mockFileService.readAsString(usecasePath),
        ).thenAnswer((_) async => fileContent);

        final model = await logicUcService.inspectUseCase(
          usecaseName: 'GetSettingsUseCase',
          usecasePath: usecasePath,
        );

        expect(model.name, 'GetSettingsUseCase');
        expect(model.returnType, 'SettingsEntity');
        expect(model.paramType, isNull);
        expect(model.method, 'getSettings');
      },
    );
  });
}
