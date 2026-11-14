import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFileService extends Mock implements FileService {}

void main() {
  late ImportService importService;
  late MockFileService mockFileService;

  const filePath =
      '/project/lib/features/auth/presentation/auth_controller.dart';

  setUp(() {
    mockFileService = MockFileService();
    importService = ImportService(fileService: mockFileService);
  });

  group('ImportService Tests', () {
    test('injectImport should do nothing if imports set is empty', () async {
      await importService.injectImport(path: filePath, imports: {});

      verifyZeroInteractions(mockFileService);
    });

    test(
      'injectImport should throw Exception if file does not exist',
      () async {
        when(
          () => mockFileService.exists(filePath),
        ).thenAnswer((_) async => false);

        expect(
          () => importService.injectImport(
            path: filePath,
            imports: {"import 'package:flutter/material.dart';"},
          ),
          throwsException,
        );

        verify(() => mockFileService.exists(filePath)).called(1);
      },
    );

    test(
      'injectImport should prepend imports at the top if file has no existing imports',
      () async {
        when(
          () => mockFileService.exists(filePath),
        ).thenAnswer((_) async => true);
        const initialContent = "class AuthController {}";
        when(
          () => mockFileService.readAsString(filePath),
        ).thenAnswer((_) async => initialContent);
        when(
          () => mockFileService.writeAsString(
            path: filePath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        await importService.injectImport(
          path: filePath,
          imports: {"import 'package:flutter/material.dart';"},
        );

        verify(
          () => mockFileService.writeAsString(
            path: filePath,
            content: any(
              named: 'content',
              that: predicate<String>(
                (content) =>
                    content.contains(
                      "import 'package:flutter/material.dart';",
                    ) &&
                    content.contains("class AuthController {}"),
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'injectImport should replace existing import block with combined and sorted imports',
      () async {
        when(
          () => mockFileService.exists(filePath),
        ).thenAnswer((_) async => true);
        const initialContent =
            "import 'package:flutter/material.dart';\n\nclass AuthController {}";
        when(
          () => mockFileService.readAsString(filePath),
        ).thenAnswer((_) async => initialContent);
        when(
          () => mockFileService.writeAsString(
            path: filePath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        await importService.injectImport(
          path: filePath,
          imports: {"import 'package:fsda_cli/core/utils/import_util.dart';"},
        );

        verify(
          () => mockFileService.writeAsString(
            path: filePath,
            content: any(
              named: 'content',
              that: predicate<String>(
                (content) =>
                    content.contains(
                      "import 'package:flutter/material.dart';",
                    ) &&
                    content.contains(
                      "import 'package:fsda_cli/core/utils/import_util.dart';",
                    ) &&
                    content.contains("class AuthController {}"),
              ),
            ),
          ),
        ).called(1);
      },
    );
  });
}
