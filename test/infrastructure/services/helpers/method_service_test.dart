import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/method_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFileService extends Mock implements FileService {}

void main() {
  late MethodService methodService;
  late MockFileService mockFileService;

  const filePath =
      '/project/lib/features/auth/presentation/auth_controller.dart';

  setUp(() {
    mockFileService = MockFileService();
    methodService = MethodService(fileService: mockFileService);
  });

  group('MethodService Tests', () {
    test('hasMethod should return false if file does not exist', () async {
      when(
        () => mockFileService.exists(filePath),
      ).thenAnswer((_) async => false);

      final result = await methodService.hasMethod(
        path: filePath,
        methodName: 'getUser',
      );

      expect(result, isFalse);
      verify(() => mockFileService.exists(filePath)).called(1);
    });

    test('hasMethod should return true if method exists in file', () async {
      when(
        () => mockFileService.exists(filePath),
      ).thenAnswer((_) async => true);
      const fileContent = '''
class AuthController {
  void getUser() {}
}
''';
      when(
        () => mockFileService.readAsString(filePath),
      ).thenAnswer((_) async => fileContent);

      final result = await methodService.hasMethod(
        path: filePath,
        methodName: 'get_user', // Menguji konversi snake_case ke camelCase
      );

      expect(result, isTrue);
    });

    test(
      'hasMethod should return false if method does not exist in file',
      () async {
        when(
          () => mockFileService.exists(filePath),
        ).thenAnswer((_) async => true);
        const fileContent = '''
class AuthController {
  void login() {}
}
''';
        when(
          () => mockFileService.readAsString(filePath),
        ).thenAnswer((_) async => fileContent);

        final result = await methodService.hasMethod(
          path: filePath,
          methodName: 'logout',
        );

        expect(result, isFalse);
      },
    );

    test('injectToClass should do nothing if file does not exist', () async {
      when(
        () => mockFileService.exists(filePath),
      ).thenAnswer((_) async => false);

      await methodService.injectToClass(
        path: filePath,
        methodCode: 'void newMethod() {}',
      );

      verify(() => mockFileService.exists(filePath)).called(1);
      verifyNever(
        () => mockFileService.writeAsString(
          path: any(named: 'path'),
          content: any(named: 'content'),
        ),
      );
    });

    test(
      'injectToClass should insert method code inside class body correctly',
      () async {
        when(
          () => mockFileService.exists(filePath),
        ).thenAnswer((_) async => true);
        const fileContent = '''
class AuthController {
  void login() {}
}
''';
        when(
          () => mockFileService.readAsString(filePath),
        ).thenAnswer((_) async => fileContent);
        when(
          () => mockFileService.writeAsString(
            path: filePath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        await methodService.injectToClass(
          path: filePath,
          methodCode: '  void logout() {}',
        );

        verify(
          () => mockFileService.writeAsString(
            path: filePath,
            content: any(
              named: 'content',
              that: predicate<String>(
                (content) =>
                    content.contains('void login() {}') &&
                    content.contains('void logout() {}'),
              ),
            ),
          ),
        ).called(1);
      },
    );

    test('unjectFromClass should do nothing if file does not exist', () async {
      when(
        () => mockFileService.exists(filePath),
      ).thenAnswer((_) async => false);

      await methodService.unjectFromClass(path: filePath, methodName: 'logout');

      verify(() => mockFileService.exists(filePath)).called(1);
      verifyNever(
        () => mockFileService.writeAsString(
          path: any(named: 'path'),
          content: any(named: 'content'),
        ),
      );
    });

    test(
      'unjectFromClass should remove method declaration from class successfully',
      () async {
        when(
          () => mockFileService.exists(filePath),
        ).thenAnswer((_) async => true);
        const fileContent = '''
class AuthController {
  void login() {}

  void logout() {}
}
''';
        when(
          () => mockFileService.readAsString(filePath),
        ).thenAnswer((_) async => fileContent);
        when(
          () => mockFileService.writeAsString(
            path: filePath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        await methodService.unjectFromClass(
          path: filePath,
          methodName: 'logout',
        );

        verify(
          () => mockFileService.writeAsString(
            path: filePath,
            content: any(
              named: 'content',
              that: predicate<String>(
                (content) =>
                    content.contains('void login() {}') &&
                    !content.contains('void logout() {}'),
              ),
            ),
          ),
        ).called(1);
      },
    );
  });
}
