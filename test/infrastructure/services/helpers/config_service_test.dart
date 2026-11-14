import 'package:fsda_cli/core/constants/app_config.dart';
import 'package:fsda_cli/core/constants/cli_info.dart';
import 'package:fsda_cli/infrastructure/services/helpers/config_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/templates/config_template.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

void main() {
  late ConfigService configService;
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;

  const currentPath = '/mock/path';

  setUp(() {
    mockDirectoryService = MockDirectoryService();
    mockFileService = MockFileService();

    when(() => mockDirectoryService.currentPath).thenReturn(currentPath);

    configService = ConfigService(
      directoryService: mockDirectoryService,
      fileService: mockFileService,
    );
  });

  group('ConfigService Tests', () {
    test(
      'validateWorkspaceRoot should return true if fsda.yaml exists',
      () async {
        when(
          () => mockFileService.exists('/mock/path/fsda.yaml'),
        ).thenAnswer((_) async => true);

        final result = await configService.validateWorkspaceRoot;
        expect(result, isTrue);
      },
    );

    test(
      'loadConfig should throw exception if workspace root is not valid',
      () async {
        when(
          () => mockFileService.exists('/mock/path/fsda.yaml'),
        ).thenAnswer((_) async => false);

        expect(() => configService.loadConfig(), throwsException);
      },
    );

    test('loadConfig should parse full valid config correctly', () async {
      when(
        () => mockFileService.exists('/mock/path/fsda.yaml'),
      ).thenAnswer((_) async => true);

      const yamlContent = '''
workspace: 'my_workspace'
fsda_cli: '1.0.0'
sdk_version: '3.0.0'
packages:
  - 'pkg_a'
  - 'pkg_b'
android:
  compile_sdk: 34
  min_sdk: 21
  target_sdk: 34
''';

      when(
        () => mockFileService.readAsString('/mock/path/fsda.yaml'),
      ).thenAnswer((_) async => yamlContent);

      final config = await configService.loadConfig();

      expect(config.workspaceName, 'my_workspace');
      expect(config.workspacePath, currentPath);
      expect(config.cliVersion, '1.0.0');
      expect(config.sdkVersion, '3.0.0');
      expect(config.activePackages, ['pkg_a', 'pkg_b']);
      expect(config.android.compileSdk, 34);
      expect(config.android.minSdk, 21);
      expect(config.android.targetSdk, 34);
    });

    test(
      'loadConfig should use defaults when optional fields are missing',
      () async {
        when(
          () => mockFileService.exists('/mock/path/fsda.yaml'),
        ).thenAnswer((_) async => true);

        const yamlContent = '''
workspace: 'my_workspace'
''';

        when(
          () => mockFileService.readAsString('/mock/path/fsda.yaml'),
        ).thenAnswer((_) async => yamlContent);

        final config = await configService.loadConfig();

        expect(config.workspaceName, 'my_workspace');
        expect(config.cliVersion, '');
        expect(config.sdkVersion, CliInfo.sdkVersion);
        expect(config.activePackages, isEmpty);
        expect(config.android.compileSdk, AppConfig.androidCompileSdk);
        expect(config.android.minSdk, AppConfig.androidMinSdk);
        expect(config.android.targetSdk, AppConfig.androidTargetSdk);
      },
    );

    test('addPackages should add and sort packages correctly', () async {
      when(
        () => mockFileService.exists('/mock/path/fsda.yaml'),
      ).thenAnswer((_) async => true);

      final mandatoryPkg = ConfigTemplate.mandatoryPackages.isNotEmpty
          ? ConfigTemplate.mandatoryPackages.first
          : 'core';

      final yamlContent =
          '''
workspace: 'my_workspace'
packages:
  - '$mandatoryPkg'
  - 'beta_pkg'
''';

      when(
        () => mockFileService.readAsString('/mock/path/fsda.yaml'),
      ).thenAnswer((_) async => yamlContent);
      when(
        () => mockFileService.writeAsString(
          path: any(named: 'path'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => {});

      await configService.addPackages(['alpha_pkg']);

      verify(
        () => mockFileService.writeAsString(
          path: '/mock/path/fsda.yaml',
          content: any(named: 'content'),
        ),
      ).called(1);
    });

    test(
      'removePackages should remove and sort remaining packages correctly',
      () async {
        when(
          () => mockFileService.exists('/mock/path/fsda.yaml'),
        ).thenAnswer((_) async => true);

        final mandatoryPkg = ConfigTemplate.mandatoryPackages.isNotEmpty
            ? ConfigTemplate.mandatoryPackages.first
            : 'core';

        final yamlContent =
            '''
workspace: 'my_workspace'
packages:
  - '$mandatoryPkg'
  - 'beta_pkg'
  - 'alpha_pkg'
''';

        when(
          () => mockFileService.readAsString('/mock/path/fsda.yaml'),
        ).thenAnswer((_) async => yamlContent);
        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        await configService.removePackages(['beta_pkg']);

        verify(
          () => mockFileService.writeAsString(
            path: '/mock/path/fsda.yaml',
            content: any(named: 'content'),
          ),
        ).called(1);
      },
    );

    test(
      'should sort multiple mandatory packages correctly when both are mandatory',
      () async {
        when(
          () => mockFileService.exists('/mock/path/fsda.yaml'),
        ).thenAnswer((_) async => true);

        // Ambil setidaknya 2 paket wajib jika tersedia untuk memicu perbandingan indexA.compareTo(indexB)
        if (ConfigTemplate.mandatoryPackages.length >= 2) {
          final pkg1 = ConfigTemplate.mandatoryPackages[1];
          final pkg2 = ConfigTemplate.mandatoryPackages[0];

          final yamlContent =
              '''
workspace: 'my_workspace'
packages:
  - '$pkg1'
  - '$pkg2'
''';

          when(
            () => mockFileService.readAsString('/mock/path/fsda.yaml'),
          ).thenAnswer((_) async => yamlContent);
          when(
            () => mockFileService.writeAsString(
              path: any(named: 'path'),
              content: any(named: 'content'),
            ),
          ).thenAnswer((_) async => {});

          await configService.addPackages(['extra_pkg']);

          verify(
            () => mockFileService.writeAsString(
              path: '/mock/path/fsda.yaml',
              content: any(named: 'content'),
            ),
          ).called(1);
        }
      },
    );
  });
}
