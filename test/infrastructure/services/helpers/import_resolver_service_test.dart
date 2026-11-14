import 'dart:io';

import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_resolver_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockFileService extends Mock implements FileService {}

void main() {
  late ImportResolverService importResolverService;
  late MockFileService mockFileService;

  const targetFilePath =
      '/project/lib/features/auth/presentation/auth_controller.dart';
  const featurePath = '/project/lib/features/auth';

  setUp(() {
    mockFileService = MockFileService();
    importResolverService = ImportResolverService(fileService: mockFileService);
  });

  group('ImportResolverService Tests', () {
    test(
      'resolve should return empty set if target file does not exist',
      () async {
        when(
          () => mockFileService.exists(targetFilePath),
        ).thenAnswer((_) async => false);

        final result = await importResolverService.resolve(
          rawTypes: {'UserEntity'},
          targetFilePath: targetFilePath,
          featurePath: featurePath,
        );

        expect(result, isEmpty);
        verify(() => mockFileService.exists(targetFilePath)).called(1);
      },
    );

    test(
      'resolve should skip core types and types not referenced in target content',
      () async {
        when(
          () => mockFileService.exists(targetFilePath),
        ).thenAnswer((_) async => true);
        when(() => mockFileService.readAsString(targetFilePath)).thenAnswer(
          (_) async => 'class AuthController {}',
        ); // Tidak memuat 'UserEntity'

        final result = await importResolverService.resolve(
          rawTypes: {'String', 'int', 'UserEntity'},
          targetFilePath: targetFilePath,
          featurePath: featurePath,
        );

        expect(result, isEmpty);
      },
    );

    test('resolve should resolve special dart imports correctly', () async {
      when(
        () => mockFileService.exists(targetFilePath),
      ).thenAnswer((_) async => true);
      when(
        () => mockFileService.readAsString(targetFilePath),
      ).thenAnswer((_) async => 'File imageFile;');

      final result = await importResolverService.resolve(
        rawTypes: {'File'},
        targetFilePath: targetFilePath,
        featurePath: featurePath,
      );

      expect(result, contains("import 'dart:io';"));
    });

    test(
      'resolve should resolve app core and l10n imports correctly',
      () async {
        when(
          () => mockFileService.exists(targetFilePath),
        ).thenAnswer((_) async => true);
        when(() => mockFileService.readAsString(targetFilePath)).thenAnswer(
          (_) async => 'NetworkFile netFile; AppLocalizations l10n;',
        );

        final result = await importResolverService.resolve(
          rawTypes: {'NetworkFile', 'AppLocalizations'},
          targetFilePath: targetFilePath,
          featurePath: featurePath,
        );

        expect(result, contains("import 'package:app_core/app_core.dart';"));
        expect(result, contains("import 'package:app_l10n/app_l10n.dart';"));
      },
    );

    test('resolve should find file inside current feature directory', () async {
      when(
        () => mockFileService.exists(targetFilePath),
      ).thenAnswer((_) async => true);
      when(
        () => mockFileService.readAsString(targetFilePath),
      ).thenAnswer((_) async => 'UserEntity user;');

      // Simulasi bahwa berkas entity ditemukan di dalam fitur saat ini
      when(
        () => mockFileService.exists(
          '/project/lib/features/auth/domain/entities/user_entity.dart',
        ),
      ).thenAnswer((_) async => true);

      final result = await importResolverService.resolve(
        rawTypes: {'UserEntity'},
        targetFilePath: targetFilePath,
        featurePath: featurePath,
      );

      expect(result, isNotEmpty);
      expect(result.first, contains('domain/entities/user_entity.dart'));
    });

    test(
      'resolve should check all subdirectories when type has no specific suffix',
      () async {
        // Stub exists agar mengenali targetFilePath dan path kustom secara spesifik
        when(() => mockFileService.exists(any())).thenAnswer((
          invocation,
        ) async {
          final path = invocation.positionalArguments[0] as String;
          if (path == targetFilePath) return true;
          if (path.contains('domain/entities/custom_model.dart')) return true;
          return false;
        });

        when(
          () => mockFileService.readAsString(targetFilePath),
        ).thenAnswer((_) async => 'CustomModel model;');

        final result = await importResolverService.resolve(
          rawTypes: {'CustomModel'},
          targetFilePath: targetFilePath,
          featurePath: featurePath,
        );

        expect(result, isNotEmpty);
        expect(result.first, contains('domain/entities/custom_model.dart'));
      },
    );

    test(
      'resolve should resolve in module generated dir for custom Localizations type',
      () async {
        when(
          () => mockFileService.exists(targetFilePath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(targetFilePath),
        ).thenAnswer((_) async => 'CustomLocalizations loc;');

        // Jalur file generated: /project/lib/generated/custom_localizations.dart
        when(
          () => mockFileService.exists(
            '/project/lib/generated/custom_localizations.dart',
          ),
        ).thenAnswer((_) async => true);

        final result = await importResolverService.resolve(
          rawTypes: {'CustomLocalizations'},
          targetFilePath: targetFilePath,
          featurePath: featurePath,
        );

        expect(result, isNotEmpty);
        expect(result.first, contains('generated/custom_localizations.dart'));
      },
    );

    test(
      'resolve should resolve across module features if not found in current feature',
      () async {
        // Menggunakan direktori sementara nyata untuk menguji penelusuran folder lintas fitur (_resolveAcrossModuleFeatures)
        final tempDir = await Directory.systemTemp.createTemp(
          'import_resolver_test_',
        );
        try {
          final authDir = Directory(p.join(tempDir.path, 'auth'));
          await authDir.create();
          final presentationDir = Directory(
            p.join(authDir.path, 'presentation'),
          );
          await presentationDir.create();

          final targetFile = File(
            p.join(presentationDir.path, 'auth_controller.dart'),
          );
          await targetFile.writeAsString('OtherEntity entity;');

          final otherFeatureDir = Directory(
            p.join(tempDir.path, 'other_feature'),
          );
          await otherFeatureDir.create();
          final entitiesDir = Directory(
            p.join(otherFeatureDir.path, 'domain', 'entities'),
          );
          await entitiesDir.create(recursive: true);

          final entityFile = File(
            p.join(entitiesDir.path, 'other_entity.dart'),
          );
          await entityFile.writeAsString('class OtherEntity {}');

          // Menggunakan FileService asli agar operasi direktori & file sistem nyata berjalan lancar
          final realFileService = FileService();
          final realResolver = ImportResolverService(
            fileService: realFileService,
          );

          final result = await realResolver.resolve(
            rawTypes: {'OtherEntity'},
            targetFilePath: targetFile.path,
            featurePath: authDir.path,
          );

          expect(result, isNotEmpty);
          expect(
            result.first,
            contains('other_feature/domain/entities/other_entity.dart'),
          );
        } finally {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        }
      },
    );
  });
}
