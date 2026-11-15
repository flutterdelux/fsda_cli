import 'dart:io';
import 'package:fsda_cli/domain/models/config_model.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/config_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/mason_generator_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/process_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/build_runner_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/l10n_service.dart';
import 'package:fsda_cli/infrastructure/services/module_service.dart';
import 'package:mason/mason.dart';
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

class FakeDirectory extends Fake implements Directory {}

class FakeMasonBundle extends Fake implements MasonBundle {}

void main() {
  group('ModuleService', () {
    late MockConfigService mockConfigService;
    late MockProcessService mockProcessService;
    late MockOperationReportService mockReportService;
    late MockDirectoryService mockDirectoryService;
    late MockBuildRunnerService mockBuildRunnerService;
    late MockL10nService mockL10nService;
    late MockMasonGeneratorService mockGeneratorService;
    late ModuleService moduleService;

    setUpAll(() {
      registerFallbackValue(FakeDirectory());
      registerFallbackValue(FakeMasonBundle());
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
    });

    const tModuleParam = ModuleParam(
      name: 'todo',
      path: '/workspace/modules/todo',
    );

    const tConfig = ConfigModel(
      workspaceName: 'workspace',
      workspacePath: '/workspace/',
      cliVersion: "2.0.0-beta.1",
      sdkVersion: "3.0.0",
    );

    test(
      'Given a valid ModuleParam and configuration, '
      'When generate is called successfully, '
      'Then it executes configuration reading, directory creation, bundle generation, dependency installation, build runner, and l10n services in order',
      () async {
        // Arrange (Given)
        final progressMessages = <String>[];

        when(
          () => mockConfigService.loadConfig(),
        ).thenAnswer((_) async => tConfig);
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
        ).thenAnswer((invocation) async {
          final callback =
              invocation.namedArguments[const Symbol('onProgress')]
                  as Function(String);
          callback('Generating module builder...');
        });

        when(
          () => mockL10nService.runL10n(
            any(),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((invocation) async {
          final callback =
              invocation.namedArguments[const Symbol('onProgress')]
                  as Function(String);
          callback('Generating module locatization...');
        });

        // Act (When)
        await moduleService.generate(
          module: tModuleParam,
          onProgress: (msg) => progressMessages.add(msg),
        );

        // Assert (Then)
        expect(progressMessages, contains('Reading FSDA configuration...'));
        expect(progressMessages, contains('Creating module directory...'));
        expect(progressMessages, contains('Copying module bundle...'));
        expect(
          progressMessages,
          contains('Installing package dependencies...'),
        );

        verify(() => mockConfigService.loadConfig()).called(1);
        verify(() => mockDirectoryService.create(tModuleParam.path)).called(1);
        verify(() => mockReportService.addCreated(tModuleParam.path)).called(1);
        verify(
          () => mockGeneratorService.generate(
            bundle: any(named: 'bundle'),
            targetPath: tModuleParam.path,
            vars: {'module': tModuleParam.name, 'dart_sdk': tConfig.sdkVersion},
          ),
        ).called(1);
        verify(
          () => mockProcessService.run('dart', [
            'pub',
            'add',
            'freezed_annotation',
            'json_annotation',
            'bloc',
          ], tModuleParam.path),
        ).called(1);
        verify(
          () => mockProcessService.run('dart', [
            'pub',
            'add',
            '--dev',
            'flutter_lints',
            'build_runner',
            'freezed',
            'json_serializable',
          ], tModuleParam.path),
        ).called(1);
        verify(
          () => mockBuildRunnerService.runBuildRunner(
            tModuleParam.path,
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
        verify(
          () => mockL10nService.runL10n(
            tModuleParam.path,
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
      },
    );

    test('Given an exception occurs during configuration loading, '
        'When generate is called, '
        'Then it throws an Exception and aborts the process', () async {
      // Arrange (Given)
      when(
        () => mockConfigService.loadConfig(),
      ).thenThrow(Exception('Config error'));

      // Act & Assert (When & Then)
      expect(
        () => moduleService.generate(module: tModuleParam, onProgress: (_) {}),
        throwsA(isA<Exception>()),
      );

      verifyNever(() => mockDirectoryService.create(any()));
      verifyNever(
        () => mockGeneratorService.generate(
          bundle: any(named: 'bundle'),
          targetPath: any(named: 'targetPath'),
          vars: any(named: 'vars'),
        ),
      );
    });
  });
}
