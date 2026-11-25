import 'package:fsda_cli/core/constants/app_config.dart';
import 'package:fsda_cli/core/constants/cli_info.dart';
import 'package:fsda_cli/infrastructure/services/helpers/config_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

void main() {
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;
  late ConfigService configService;

  const workspacePath = '/projects/my_workspace';
  final expectedFsdaDirPath = p.join(workspacePath, '.fsda');
  final expectedPlansDirPath = p.join(expectedFsdaDirPath, 'plans');
  final expectedConfigPath = p.join(expectedFsdaDirPath, 'config.yaml');

  setUp(() {
    mockDirectoryService = MockDirectoryService();
    mockFileService = MockFileService();
    configService = ConfigService(
      directoryService: mockDirectoryService,
      fileService: mockFileService,
    );

    when(() => mockDirectoryService.currentPath).thenReturn(workspacePath);
    when(
      () => mockFileService.writeAsString(
        path: any(named: 'path'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});
  });

  group('ConfigService', () {
    group('Path Getters', () {
      test('GIVEN current workspace directory '
          'WHEN fsdaDirPath, plansDirPath, and configPath are accessed '
          'THEN returns paths under .fsda directory', () {
        // When & Then
        expect(configService.fsdaDirPath, expectedFsdaDirPath);
        expect(configService.plansDirPath, expectedPlansDirPath);
        expect(configService.configPath, expectedConfigPath);
      });
    });

    group('fsdaWorkspace', () {
      test(
        'GIVEN .fsda/config.yaml exists in current directory '
        'WHEN fsdaWorkspace is accessed '
        'THEN returns WorkspaceParam with workspaceName and workspacePath',
        () async {
          // Given
          when(
            () => mockFileService.exists(expectedConfigPath),
          ).thenAnswer((_) async => true);

          // When
          final result = await configService.fsdaWorkspace;

          // Then
          expect(result, isNotNull);
          expect(result!.workspaceName, 'my_workspace');
          expect(result.workspacePath, workspacePath);
        },
      );

      test('GIVEN .fsda/config.yaml does not exist in current directory '
          'WHEN fsdaWorkspace is accessed '
          'THEN returns null', () async {
        // Given
        when(
          () => mockFileService.exists(expectedConfigPath),
        ).thenAnswer((_) async => false);

        // When
        final result = await configService.fsdaWorkspace;

        // Then
        expect(result, isNull);
      });
    });

    group('loadConfig', () {
      test(
        'GIVEN .fsda/config.yaml does not exist '
        'WHEN loadConfig is called '
        'THEN throws an Exception indicating not inside an FSDA workspace',
        () async {
          // Given
          when(
            () => mockFileService.exists(expectedConfigPath),
          ).thenAnswer((_) async => false);

          // When & Then
          expect(
            () => configService.loadConfig(),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains(
                  'Not inside an FSDA workspace. File ".fsda/config.yaml" was not found.',
                ),
              ),
            ),
          );
        },
      );

      test('GIVEN valid .fsda/config.yaml with all fields defined '
          'WHEN loadConfig is called '
          'THEN parses and returns complete ConfigModel accurately', () async {
        // Given
        const yamlContent = '''
name: my_workspace
fsda_cli: "1.2.0"
dart_sdk: "^3.8.0"
android:
  min_sdk: 23
  target_sdk: 35
  compile_sdk: 35
packages:
  - app_core
  - app_l10n
  - app_network
''';
        when(
          () => mockFileService.exists(expectedConfigPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(expectedConfigPath),
        ).thenAnswer((_) async => yamlContent);

        // When
        final config = await configService.loadConfig();

        // Then
        expect(config.workspaceName, 'my_workspace');
        expect(config.workspacePath, workspacePath);
        expect(config.cliVersion, '1.2.0');
        expect(config.dartSdk, '^3.8.0');
        expect(config.activePackages, ['app_core', 'app_l10n', 'app_network']);
        expect(config.android.minSdk, 23);
        expect(config.android.targetSdk, 35);
        expect(config.android.compileSdk, 35);
      });

      test(
        'GIVEN minimal or empty .fsda/config.yaml without optional fields '
        'WHEN loadConfig is called '
        'THEN falls back to CliInfo.dartSdk and AppConfig default values',
        () async {
          // Given
          when(
            () => mockFileService.exists(expectedConfigPath),
          ).thenAnswer((_) async => true);
          when(
            () => mockFileService.readAsString(expectedConfigPath),
          ).thenAnswer((_) async => '');

          // When
          final config = await configService.loadConfig();

          // Then
          expect(config.cliVersion, '');
          expect(config.dartSdk, CliInfo.dartSdk);
          expect(config.activePackages, isEmpty);
          expect(config.android.minSdk, AppConfig.androidMinSdk);
          expect(config.android.targetSdk, AppConfig.androidTargetSdk);
          expect(config.android.compileSdk, AppConfig.androidCompileSdk);
        },
      );
    });

    group('addPackages', () {
      test(
        'GIVEN existing packages in .fsda/config.yaml '
        'WHEN addPackages is called with new and duplicate packages '
        'THEN deduplicates, prioritizes mandatoryPackages order, sorts optional packages alphabetically, and writes updated yaml',
        () async {
          // Given
          const initialYaml = '''
name: my_workspace
fsda_cli: "1.0.0"
packages:
  - app_ui
  - zebra_pkg
''';
          when(
            () => mockFileService.exists(expectedConfigPath),
          ).thenAnswer((_) async => true);
          when(
            () => mockFileService.readAsString(expectedConfigPath),
          ).thenAnswer((_) async => initialYaml);

          // When
          await configService.addPackages([
            'alpha_pkg',
            'app_core',
            'app_l10n',
            'zebra_pkg',
          ]);

          // Then
          final captured =
              verify(
                    () => mockFileService.writeAsString(
                      path: expectedConfigPath,
                      content: captureAny(named: 'content'),
                    ),
                  ).captured.single
                  as String;

          final updatedYaml = loadYaml(captured) as YamlMap;
          final updatedPackages = (updatedYaml['packages'] as YamlList)
              .map((e) => e.toString())
              .toList();

          expect(updatedPackages, [
            'app_core',
            'app_l10n',
            'app_ui',
            'alpha_pkg',
            'zebra_pkg',
          ]);
        },
      );
    });

    group('removePackages', () {
      test(
        'GIVEN existing packages in .fsda/config.yaml '
        'WHEN removePackages is called '
        'THEN removes target packages, keeps remaining packages sorted, and writes updated yaml',
        () async {
          // Given
          const initialYaml = '''
name: my_workspace
fsda_cli: "1.0.0"
packages:
  - app_core
  - app_l10n
  - app_ui
  - alpha_pkg
  - zebra_pkg
''';
          when(
            () => mockFileService.exists(expectedConfigPath),
          ).thenAnswer((_) async => true);
          when(
            () => mockFileService.readAsString(expectedConfigPath),
          ).thenAnswer((_) async => initialYaml);

          // When
          await configService.removePackages([
            'app_l10n',
            'alpha_pkg',
            'non_existent',
          ]);

          // Then
          final captured =
              verify(
                    () => mockFileService.writeAsString(
                      path: expectedConfigPath,
                      content: captureAny(named: 'content'),
                    ),
                  ).captured.single
                  as String;

          final updatedYaml = loadYaml(captured) as YamlMap;
          final updatedPackages = (updatedYaml['packages'] as YamlList)
              .map((e) => e.toString())
              .toList();

          expect(updatedPackages, ['app_core', 'app_ui', 'zebra_pkg']);
        },
      );
    });
  });
}
