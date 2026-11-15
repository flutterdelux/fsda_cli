import 'dart:io';

import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_finder_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockFileService extends Mock implements FileService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class FakeFileSystemEntity extends Mock implements FileSystemEntity {
  @override
  String get path => '';
}

void main() {
  late MockFileService mockFileService;
  late MockDirectoryService mockDirectoryService;
  late FileFinderService fileFinderService;

  const modulePath = '/workspace/modules/todo';

  setUp(() {
    mockFileService = MockFileService();
    mockDirectoryService = MockDirectoryService();
    fileFinderService = FileFinderService(
      fileService: mockFileService,
      directoryService: mockDirectoryService,
    );

    // Default stubbing: return false for any unchecked file existence
    when(() => mockFileService.exists(any())).thenAnswer((_) async => false);
    // Default stubbing: return empty list for feature directories
    when(
      () => mockDirectoryService.listPaths(
        dirPath: any(named: 'dirPath'),
        where: any(named: 'where'),
      ),
    ).thenAnswer((_) async => []);
  });

  group('FileFinderService', () {
    group('Localizations resolution', () {
      test(
        'returns generated path when rawRef ends with Localizations and file exists',
        () async {
          final expectedPath = p.join(
            modulePath,
            'lib',
            'src',
            'generated',
            'todo_localizations.dart',
          );

          when(
            () => mockFileService.exists(expectedPath),
          ).thenAnswer((_) async => true);

          final result = await fileFinderService.findFile(
            rawRef: 'TodoLocalizations',
            modulePath: modulePath,
          );

          expect(result, equals(expectedPath));
          verify(() => mockFileService.exists(expectedPath)).called(1);
          verifyNever(
            () => mockDirectoryService.listPaths(
              dirPath: any(named: 'dirPath'),
              where: any(named: 'where'),
            ),
          );
        },
      );

      test(
        'falls back to feature directories if Localizations file is not in generated folder',
        () async {
          final generatedPath = p.join(
            modulePath,
            'lib',
            'src',
            'generated',
            'custom_localizations.dart',
          );
          final featurePath = p.join(
            modulePath,
            'lib',
            'src',
            'features',
            'auth',
          );
          final fallbackPath = p.join(
            featurePath,
            'domain/entities',
            'custom_localizations.dart',
          );

          when(
            () => mockFileService.exists(generatedPath),
          ).thenAnswer((_) async => false);
          when(
            () => mockDirectoryService.listPaths(
              dirPath: p.join(modulePath, 'lib', 'src', 'features'),
              where: any(named: 'where'),
            ),
          ).thenAnswer((_) async => [featurePath]);
          when(
            () => mockFileService.exists(fallbackPath),
          ).thenAnswer((_) async => true);

          final result = await fileFinderService.findFile(
            rawRef: 'CustomLocalizations',
            modulePath: modulePath,
          );

          expect(result, equals(fallbackPath));
        },
      );
    });

    group('Exception resolution', () {
      test(
        'returns shared error path when rawRef ends with Exception and file exists',
        () async {
          final expectedPath = p.join(
            modulePath,
            'lib',
            'src',
            'shared',
            'data',
            'errors',
            'task_not_found_exception.dart',
          );

          when(
            () => mockFileService.exists(expectedPath),
          ).thenAnswer((_) async => true);

          final result = await fileFinderService.findFile(
            rawRef: 'TaskNotFoundException',
            modulePath: modulePath,
          );

          expect(result, equals(expectedPath));
          verify(() => mockFileService.exists(expectedPath)).called(1);
          verifyNever(
            () => mockDirectoryService.listPaths(
              dirPath: any(named: 'dirPath'),
              where: any(named: 'where'),
            ),
          );
        },
      );

      test(
        'falls back to feature directories if Exception file is not in shared errors folder',
        () async {
          final sharedPath = p.join(
            modulePath,
            'lib',
            'src',
            'shared',
            'data',
            'errors',
            'local_task_exception.dart',
          );
          final featurePath = p.join(
            modulePath,
            'lib',
            'src',
            'features',
            'task',
          );
          final fallbackPath = p.join(
            featurePath,
            'domain/usecases',
            'local_task_exception.dart',
          );

          when(
            () => mockFileService.exists(sharedPath),
          ).thenAnswer((_) async => false);
          when(
            () => mockDirectoryService.listPaths(
              dirPath: p.join(modulePath, 'lib', 'src', 'features'),
              where: any(named: 'where'),
            ),
          ).thenAnswer((_) async => [featurePath]);
          when(
            () => mockFileService.exists(fallbackPath),
          ).thenAnswer((_) async => true);

          final result = await fileFinderService.findFile(
            rawRef: 'LocalTaskException',
            modulePath: modulePath,
          );

          expect(result, equals(fallbackPath));
        },
      );
    });

    group('Feature subdirectories resolution', () {
      test(
        'finds file in the first matching feature and subdirectory',
        () async {
          final authFeaturePath = p.join(
            modulePath,
            'lib',
            'src',
            'features',
            'auth',
          );
          final taskFeaturePath = p.join(
            modulePath,
            'lib',
            'src',
            'features',
            'task',
          );
          final expectedPath = p.join(
            taskFeaturePath,
            'domain/entities',
            'task_entity.dart',
          );

          when(
            () => mockDirectoryService.listPaths(
              dirPath: p.join(modulePath, 'lib', 'src', 'features'),
              where: any(named: 'where'),
            ),
          ).thenAnswer((_) async => [authFeaturePath, taskFeaturePath]);

          when(
            () => mockFileService.exists(expectedPath),
          ).thenAnswer((_) async => true);

          final result = await fileFinderService.findFile(
            rawRef: 'TaskEntity',
            modulePath: modulePath,
          );

          expect(result, equals(expectedPath));
        },
      );

      test(
        'searches across all supported subDirs (dtos, params, usecases, etc.)',
        () async {
          final taskFeaturePath = p.join(
            modulePath,
            'lib',
            'src',
            'features',
            'task',
          );
          final expectedParamPath = p.join(
            taskFeaturePath,
            'domain/params',
            'create_task_param.dart',
          );

          when(
            () => mockDirectoryService.listPaths(
              dirPath: p.join(modulePath, 'lib', 'src', 'features'),
              where: any(named: 'where'),
            ),
          ).thenAnswer((_) async => [taskFeaturePath]);

          when(
            () => mockFileService.exists(expectedParamPath),
          ).thenAnswer((_) async => true);

          final result = await fileFinderService.findFile(
            rawRef: 'CreateTaskParam',
            modulePath: modulePath,
          );

          expect(result, equals(expectedParamPath));
        },
      );

      test('returns null when file does not exist in any directory', () async {
        final taskFeaturePath = p.join(
          modulePath,
          'lib',
          'src',
          'features',
          'task',
        );

        when(
          () => mockDirectoryService.listPaths(
            dirPath: p.join(modulePath, 'lib', 'src', 'features'),
            where: any(named: 'where'),
          ),
        ).thenAnswer((_) async => [taskFeaturePath]);

        final result = await fileFinderService.findFile(
          rawRef: 'UnknownModel',
          modulePath: modulePath,
        );

        expect(result, isNull);
      });
    });

    test(
      'Given a file reference and feature directories, '
      'When findFile is called, '
      'Then it passes the correct where filter to directoryService and finds the file successfully',
      () async {
        // Arrange (Given)
        final featurePath = p.join(
          modulePath,
          'lib',
          'src',
          'features',
          'task',
        );
        final expectedPath = p.join(
          featurePath,
          'domain/entities',
          'task_entity.dart',
        );

        when(
          () => mockDirectoryService.listPaths(
            dirPath: any(named: 'dirPath'),
            where: any(named: 'where'),
          ),
        ).thenAnswer((invocation) async {
          // Mengeksekusi fungsi 'where' yang dikirimkan untuk memastikan cabang filter tereksekusi
          final whereFn =
              invocation.namedArguments[const Symbol('where')]
                  as bool Function(FakeFileSystemEntity, bool);
          whereFn(FakeFileSystemEntity(), false);
          whereFn(FakeFileSystemEntity(), true);

          return [featurePath];
        });

        when(
          () => mockFileService.exists(expectedPath),
        ).thenAnswer((_) async => true);

        // Act (When)
        final result = await fileFinderService.findFile(
          rawRef: 'TaskEntity',
          modulePath: modulePath,
        );

        // Assert (Then)
        expect(result, equals(expectedPath));
        verify(
          () => mockDirectoryService.listPaths(
            dirPath: p.join(modulePath, 'lib', 'src', 'features'),
            where: any(named: 'where'),
          ),
        ).called(1);
      },
    );
  });
}
