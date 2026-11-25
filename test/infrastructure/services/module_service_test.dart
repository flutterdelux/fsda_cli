import 'package:fsda_cli/core/extensions/module_param_x.dart';
import 'package:fsda_cli/domain/models/config_android_model.dart';
import 'package:fsda_cli/domain/models/config_model.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/infrastructure/bundles/module_bundle.dart';
import 'package:fsda_cli/infrastructure/services/helpers/config_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/mason_generator_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/process_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/build_runner_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/l10n_service.dart';
import 'package:fsda_cli/infrastructure/services/module_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockConfigService extends Mock implements ConfigService {}

class MockProcessService extends Mock implements ProcessService {}

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class MockBuildRunnerService extends Mock implements BuildRunnerService {}

class MockL10nService extends Mock implements L10nService {}

class MockMasonGeneratorService extends Mock implements MasonGeneratorService {}

void main() {
  late MockConfigService mockConfigService;
  late MockProcessService mockProcessService;
  late MockOperationReportService mockReportService;
  late MockDirectoryService mockDirectoryService;
  late MockBuildRunnerService mockBuildRunnerService;
  late MockL10nService mockL10nService;
  late MockMasonGeneratorService mockGeneratorService;
  late ModuleService moduleService;

  const sampleModule = ModuleParam(
    moduleName: 'project_management',
    workspaceName: 'my_workspace',
    workspacePath: '/projects/my_workspace',
  );

  const sampleConfig = ConfigModel(
    workspaceName: 'my_workspace',
    workspacePath: '/projects/my_workspace',
    cliVersion: '1.0.0',
    dartSdk: '^3.8.0',
    android: ConfigAndroidModel(minSdk: 23, targetSdk: 35, compileSdk: 35),
  );

  final expectedModulePath = sampleModule.modulePath;

  setUpAll(() {
    registerFallbackValue(moduleBundle);
  });

  setUp(() {
    mockConfigService = MockConfigService();
    mockProcessService = MockProcessService();
    mockReportService = MockOperationReportService();
    mockDirectoryService = MockDirectoryService();
    mockBuildRunnerService = MockBuildRunnerService();
    mockL10nService = MockL10nService();
    mockGeneratorService = MockMasonGeneratorService();

    moduleService = ModuleService(
      configService: mockConfigService,
      processService: mockProcessService,
      reportService: mockReportService,
      directoryService: mockDirectoryService,
      buildRunnerService: mockBuildRunnerService,
      l10nService: mockL10nService,
      masonGeneratorService: mockGeneratorService,
    );

    when(
      () => mockConfigService.loadConfig(),
    ).thenAnswer((_) async => sampleConfig);
    when(() => mockDirectoryService.create(any())).thenAnswer((_) async {});
    when(
      () => mockGeneratorService.generate(
        bundle: any(named: 'bundle'),
        targetPath: any(named: 'targetPath'),
        vars: any(named: 'vars'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockProcessService.run(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockBuildRunnerService.runBuildRunner(
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async {});
    when(
      () =>
          mockL10nService.runL10n(any(), onProgress: any(named: 'onProgress')),
    ).thenAnswer((_) async {});
  });

  group('ModuleService.generate', () {
    test(
      'GIVEN valid ModuleParam and FSDA configuration '
      'WHEN generate is called '
      'THEN creates module directory, generates Mason bundle, installs dependencies, runs build_runner and l10n, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];

        // When
        await moduleService.generate(
          module: sampleModule,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Reading FSDA configuration...',
          'Creating module directory...',
          'Copying module bundle...',
          'Installing package dependencies...',
          'Generating module builder...',
          'Generating module locatization...',
        ]);

        // 1. Verify config load
        verify(() => mockConfigService.loadConfig()).called(1);

        // 2. Verify module directory creation & report
        verify(() => mockDirectoryService.create(expectedModulePath)).called(1);
        verify(
          () => mockReportService.addCreated(expectedModulePath),
        ).called(1);

        // 3. Verify Mason bundle generation
        verify(
          () => mockGeneratorService.generate(
            bundle: moduleBundle,
            targetPath: expectedModulePath,
            vars: {'module': 'project_management', 'dart_sdk': '^3.8.0'},
          ),
        ).called(1);

        // 4. Verify dependencies & dev_dependencies installation
        verify(
          () => mockProcessService.run('dart', [
            'pub',
            'add',
            'freezed_annotation:"^3.1.0"',
            'json_annotation:"^4.12.0"',
            'bloc',
          ], expectedModulePath),
        ).called(1);
        verify(
          () => mockProcessService.run('dart', [
            'pub',
            'add',
            'dev:flutter_lints',
            'dev:build_runner:"^2.15.1"',
            'dev:freezed:"^3.2.5"',
            'dev:json_serializable:"^6.14.1"',
          ], expectedModulePath),
        ).called(1);

        // 5. Verify build_runner & l10n execution
        verify(
          () => mockBuildRunnerService.runBuildRunner(
            expectedModulePath,
            onProgress: progressLogs.add,
          ),
        ).called(1);
        verify(
          () => mockL10nService.runL10n(
            expectedModulePath,
            onProgress: progressLogs.add,
          ),
        ).called(1);
      },
    );
  });
}
