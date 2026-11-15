import 'package:fsda_cli/infrastructure/services/helpers/file_finder_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_resolver_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockFileService extends Mock implements FileService {}

class MockFileFinderService extends Mock implements FileFinderService {}

void main() {
  late MockFileService mockFileService;
  late MockFileFinderService mockFileFinderService;
  late ImportResolverService importResolverService;

  const modulePath = '/workspace/modules/todo';
  const targetFilePath =
      '/workspace/modules/todo/lib/src/features/task/presentation/task_page.dart';

  setUp(() {
    mockFileService = MockFileService();
    mockFileFinderService = MockFileFinderService();
    importResolverService = ImportResolverService(
      fileService: mockFileService,
      fileFinderService: mockFileFinderService,
    );
  });

  group('ImportResolverService', () {
    test('returns empty set if target file does not exist', () async {
      when(
        () => mockFileService.exists(targetFilePath),
      ).thenAnswer((_) async => false);

      final result = await importResolverService.resolve(
        rawTypes: {'String', 'TaskDto'},
        targetFilePath: targetFilePath,
        modulePath: modulePath,
      );

      expect(result, isEmpty);
      verify(() => mockFileService.exists(targetFilePath)).called(1);
      verifyNever(() => mockFileService.readAsString(any()));
    });

    test('ignores empty types and Dart core types', () async {
      when(
        () => mockFileService.exists(targetFilePath),
      ).thenAnswer((_) async => true);
      when(
        () => mockFileService.readAsString(targetFilePath),
      ).thenAnswer((_) async => 'String int bool TaskDto');

      when(
        () => mockFileFinderService.findFile(
          rawRef: 'TaskDto',
          modulePath: modulePath,
        ),
      ).thenAnswer((_) async => null);

      final result = await importResolverService.resolve(
        rawTypes: {'', 'String', 'int', 'bool', 'TaskDto'},
        targetFilePath: targetFilePath,
        modulePath: modulePath,
      );

      expect(result, isEmpty);
      verify(
        () => mockFileFinderService.findFile(
          rawRef: 'TaskDto',
          modulePath: modulePath,
        ),
      ).called(1);
    });

    test(
      'skips resolution if type is not contained in target file content',
      () async {
        when(
          () => mockFileService.exists(targetFilePath),
        ).thenAnswer((_) async => true);
        when(() => mockFileService.readAsString(targetFilePath)).thenAnswer(
          (_) async => 'class TaskPage {}',
        ); // Tidak ada kata 'TaskDto'

        final result = await importResolverService.resolve(
          rawTypes: {'TaskDto'},
          targetFilePath: targetFilePath,
          modulePath: modulePath,
        );

        expect(result, isEmpty);
        verifyNever(
          () => mockFileFinderService.findFile(
            rawRef: 'TaskDto',
            modulePath: modulePath,
          ),
        );
      },
    );

    test('resolves Dart special imports correctly', () async {
      when(
        () => mockFileService.exists(targetFilePath),
      ).thenAnswer((_) async => true);
      when(
        () => mockFileService.readAsString(targetFilePath),
      ).thenAnswer((_) async => 'Uint8List fileData;');

      final result = await importResolverService.resolve(
        rawTypes: {'Uint8List'},
        targetFilePath: targetFilePath,
        modulePath: modulePath,
      );

      expect(result, equals({"import 'dart:typed_data';"}));
      verifyNever(
        () => mockFileFinderService.findFile(
          rawRef: any(named: 'rawRef'),
          modulePath: any(named: 'modulePath'),
        ),
      );
    });

    test('resolves App core types imports correctly', () async {
      when(
        () => mockFileService.exists(targetFilePath),
      ).thenAnswer((_) async => true);
      when(
        () => mockFileService.readAsString(targetFilePath),
      ).thenAnswer((_) async => 'AsyncResult<void> result;');

      final result = await importResolverService.resolve(
        rawTypes: {'AsyncResult'},
        targetFilePath: targetFilePath,
        modulePath: modulePath,
      );

      expect(result, equals({"import 'package:app_core/app_core.dart';"}));
    });

    test('resolves App l10n types imports correctly', () async {
      when(
        () => mockFileService.exists(targetFilePath),
      ).thenAnswer((_) async => true);
      when(
        () => mockFileService.readAsString(targetFilePath),
      ).thenAnswer((_) async => 'AppLocalizations.of(context)');

      final result = await importResolverService.resolve(
        rawTypes: {'AppLocalizations'},
        targetFilePath: targetFilePath,
        modulePath: modulePath,
      );

      expect(result, equals({"import 'package:app_l10n/app_l10n.dart';"}));
    });

    test('cleans generic wrappers and nullability flags from raw types', () async {
      when(
        () => mockFileService.exists(targetFilePath),
      ).thenAnswer((_) async => true);
      when(
        () => mockFileService.readAsString(targetFilePath),
      ).thenAnswer((_) async => 'List<TaskDto>? items;');

      final foundPath =
          '/workspace/modules/todo/lib/src/features/task/data/dtos/task_dto.dart';
      when(
        () => mockFileFinderService.findFile(
          rawRef: 'TaskDto',
          modulePath: modulePath,
        ),
      ).thenAnswer((_) async => foundPath);

      final result = await importResolverService.resolve(
        rawTypes: {'List<TaskDto>?'},
        targetFilePath: targetFilePath,
        modulePath: modulePath,
      );

      // Memastikan finder dipanggil dengan 'TaskDto' yang sudah dibersihkan dari 'List<>?'
      verify(
        () => mockFileFinderService.findFile(
          rawRef: 'TaskDto',
          modulePath: modulePath,
        ),
      ).called(1);

      // Memastikan relative path dihitung dengan benar terhadap targetFilePath
      final expectedRelativePath = p.relative(
        foundPath,
        from: p.dirname(targetFilePath),
      );
      expect(result, equals({"import '$expectedRelativePath';"}));
    });

    test(
      'adds relative import when FileFinderService successfully finds a file',
      () async {
        when(
          () => mockFileService.exists(targetFilePath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(targetFilePath),
        ).thenAnswer((_) async => 'TaskEntity entity;');

        const foundPath =
            '/workspace/modules/todo/lib/src/features/task/domain/entities/task_entity.dart';
        when(
          () => mockFileFinderService.findFile(
            rawRef: 'TaskEntity',
            modulePath: modulePath,
          ),
        ).thenAnswer((_) async => foundPath);

        final result = await importResolverService.resolve(
          rawTypes: {'TaskEntity'},
          targetFilePath: targetFilePath,
          modulePath: modulePath,
        );

        final expectedRelativePath = p
            .relative(foundPath, from: p.dirname(targetFilePath))
            .replaceAll(r'\', '/');

        expect(result, equals({"import '$expectedRelativePath';"}));
      },
    );

    test('does not add import if FileFinderService returns null', () async {
      when(
        () => mockFileService.exists(targetFilePath),
      ).thenAnswer((_) async => true);
      when(
        () => mockFileService.readAsString(targetFilePath),
      ).thenAnswer((_) async => 'UnknownModel model;');

      when(
        () => mockFileFinderService.findFile(
          rawRef: 'UnknownModel',
          modulePath: modulePath,
        ),
      ).thenAnswer((_) async => null);

      final result = await importResolverService.resolve(
        rawTypes: {'UnknownModel'},
        targetFilePath: targetFilePath,
        modulePath: modulePath,
      );

      expect(result, isEmpty);
    });
  });
}
