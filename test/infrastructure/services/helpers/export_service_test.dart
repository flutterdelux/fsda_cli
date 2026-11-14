import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';

import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockFileService extends Mock implements FileService {}

void main() {
  late ExportService exportService;
  late MockFileService mockFileService;

  const barrelPath = 'lib/features/auth/auth_feature.dart';

  setUp(() {
    mockFileService = MockFileService();
    exportService = ExportService(fileService: mockFileService);
  });

  group('ExportService Tests', () {
    test('inject should do nothing if exportLines is empty', () async {
      await exportService.inject(
        barrelPath: barrelPath,
        exportLines: [],
        checkpoint: 'exports',
      );

      verifyZeroInteractions(mockFileService);
    });

    test('inject should do nothing if file does not exist', () async {
      when(
        () => mockFileService.exists(barrelPath),
      ).thenAnswer((_) async => false);

      await exportService.inject(
        barrelPath: barrelPath,
        exportLines: ["export 'auth.dart';"],
        checkpoint: 'exports',
      );

      verify(() => mockFileService.exists(barrelPath)).called(1);
      verifyNever(() => mockFileService.readAsString(any()));
    });

    test(
      'inject should append formatted export lines after checkpoint when checkpoint exists',
      () async {
        const initialContent = "exports\nlibrary auth;";
        when(
          () => mockFileService.exists(barrelPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(barrelPath),
        ).thenAnswer((_) async => initialContent);
        when(
          () => mockFileService.writeAsString(
            path: barrelPath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        await exportService.inject(
          barrelPath: barrelPath,
          exportLines: ["export 'auth_view.dart';"],
          checkpoint: 'exports',
        );

        verify(
          () => mockFileService.writeAsString(
            path: barrelPath,
            content: "exports\nexport 'auth_view.dart';\nlibrary auth;",
          ),
        ).called(1);
      },
    );

    test(
      'inject should prepend export lines at top if checkpoint does not exist',
      () async {
        const initialContent = "library auth;";
        when(
          () => mockFileService.exists(barrelPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(barrelPath),
        ).thenAnswer((_) async => initialContent);
        when(
          () => mockFileService.writeAsString(
            path: barrelPath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        await exportService.inject(
          barrelPath: barrelPath,
          exportLines: ["export 'auth_view.dart';"],
          checkpoint: 'missing_checkpoint',
        );

        verify(
          () => mockFileService.writeAsString(
            path: barrelPath,
            content: "export 'auth_view.dart';\nlibrary auth;",
          ),
        ).called(1);
      },
    );

    test(
      'inject should filter out lines that already exist to avoid duplication',
      () async {
        const initialContent = "export 'auth_view.dart';\nlibrary auth;";
        when(
          () => mockFileService.exists(barrelPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(barrelPath),
        ).thenAnswer((_) async => initialContent);

        await exportService.inject(
          barrelPath: barrelPath,
          exportLines: ["export 'auth_view.dart';"],
          checkpoint: 'exports',
        );

        verifyNever(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        );
      },
    );

    test('unject should do nothing if exportLines is empty', () async {
      await exportService.unject(barrelPath: barrelPath, exportLines: []);

      verifyZeroInteractions(mockFileService);
    });

    test('unject should do nothing if file does not exist', () async {
      when(
        () => mockFileService.exists(barrelPath),
      ).thenAnswer((_) async => false);

      await exportService.unject(
        barrelPath: barrelPath,
        exportLines: ["export 'auth.dart';"],
      );

      verify(() => mockFileService.exists(barrelPath)).called(1);
      verifyNever(() => mockFileService.readAsString(any()));
    });

    test('unject should remove matching export lines and save file', () async {
      const initialContent =
          "library auth;\nexport 'auth_view.dart';\nexport 'other.dart';";
      when(
        () => mockFileService.exists(barrelPath),
      ).thenAnswer((_) async => true);
      when(
        () => mockFileService.readAsString(barrelPath),
      ).thenAnswer((_) async => initialContent);
      when(
        () => mockFileService.writeAsString(
          path: barrelPath,
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => {});

      await exportService.unject(
        barrelPath: barrelPath,
        exportLines: ["export 'auth_view.dart';"],
      );

      verify(
        () => mockFileService.writeAsString(
          path: barrelPath,
          content: "library auth;\nexport 'other.dart';",
        ),
      ).called(1);
    });

    test(
      'unject should not write file if no target lines were found to remove',
      () async {
        const initialContent = "library auth;\nexport 'other.dart';";
        when(
          () => mockFileService.exists(barrelPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(barrelPath),
        ).thenAnswer((_) async => initialContent);

        await exportService.unject(
          barrelPath: barrelPath,
          exportLines: ["export 'non_existent.dart';"],
        );

        verifyNever(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        );
      },
    );
  });
}
