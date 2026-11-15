import 'package:fsda_cli/domain/models/config_android_model.dart';
import 'package:fsda_cli/domain/models/config_model.dart';
import 'package:fsda_cli/domain/params/app_param.dart';
import 'package:fsda_cli/infrastructure/services/app_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/config_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/mason_generator_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/process_service.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockConfigService extends Mock implements ConfigService {}

class MockProcessService extends Mock implements ProcessService {}

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

class MockMasonGeneratorService extends Mock implements MasonGeneratorService {}

class FakeMasonBundle extends Fake implements MasonBundle {}

void main() {
  group('AppService', () {
    late MockConfigService mockConfigService;
    late MockProcessService mockProcessService;
    late MockOperationReportService mockReportService;
    late MockDirectoryService mockDirectoryService;
    late MockFileService mockFileService;
    late MockMasonGeneratorService mockGeneratorService;
    late AppService appService;

    setUpAll(() {
      registerFallbackValue(FakeMasonBundle());
    });

    setUp(() {
      mockConfigService = MockConfigService();
      mockProcessService = MockProcessService();
      mockReportService = MockOperationReportService();
      mockDirectoryService = MockDirectoryService();
      mockFileService = MockFileService();
      mockGeneratorService = MockMasonGeneratorService();

      appService = AppService(
        configService: mockConfigService,
        processService: mockProcessService,
        reportService: mockReportService,
        directoryService: mockDirectoryService,
        fileService: mockFileService,
        generatorService: mockGeneratorService,
      );
    });

    const tAppParam = AppParam(
      projectName: 'portalapp',
      projectPath: '/workspace/portalapp',
      org: 'com.fdelux',
      appName: 'Portal App',
      orgName: 'Flutter Delux',
    );

    const tAndroidConfig = ConfigAndroidModel(
      minSdk: 21,
      targetSdk: 33,
      compileSdk: 33,
    );

    const tConfig = ConfigModel(
      workspaceName: 'workspace',
      workspacePath: '/workspace/',
      cliVersion: '2.0.0-beta.1',
      sdkVersion: '3.0.0',
      android: tAndroidConfig,
    );

    test(
      'Given a valid AppParam and configuration, '
      'When generateApp is called successfully, '
      'Then it executes flutter create, deletes test dir, generates bundle, updates gradle, and installs dependencies in order',
      () async {
        // Arrange (Given)
        final progressMessages = <String>[];
        final gradlePath = '/workspace/portalapp/android/app/build.gradle.kts';

        when(
          () => mockConfigService.loadConfig(),
        ).thenAnswer((_) async => tConfig);
        when(
          () => mockProcessService.run(any(), any(), any()),
        ).thenAnswer((_) async {});
        when(
          () => mockDirectoryService.exists(any()),
        ).thenAnswer((_) async => true);
        when(() => mockDirectoryService.delete(any())).thenAnswer((_) async {});
        when(
          () => mockGeneratorService.generate(
            bundle: any(named: 'bundle'),
            targetPath: any(named: 'targetPath'),
            vars: any(named: 'vars'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockFileService.exists(gradlePath),
        ).thenAnswer((_) async => true);
        when(() => mockFileService.readAsString(gradlePath)).thenAnswer(
          (_) async => 'compileSdk = 30\nminSdk = 16\ntargetSdk = 30\n',
        );
        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async {});

        // Act (When)
        await appService.generateApp(
          app: tAppParam,
          onProgress: (msg) => progressMessages.add(msg),
        );

        // Assert (Then)
        expect(progressMessages, contains('Reading FSDA configuration...'));
        expect(
          progressMessages,
          contains('Running flutter create for "portalapp"...'),
        );
        expect(
          progressMessages,
          contains('Cleaning up default test directory...'),
        );
        expect(progressMessages, contains('Copying app bundle...'));
        expect(
          progressMessages,
          contains('Configuring Android SDK versions in build.gradle.kts...'),
        );
        expect(
          progressMessages,
          contains('Installing package dependencies...'),
        );

        verify(() => mockConfigService.loadConfig()).called(1);
        verify(
          () => mockProcessService.run('flutter', [
            'create',
            '--org',
            tAppParam.org,
            tAppParam.projectName,
          ], '/workspace'),
        ).called(1);
        verify(
          () => mockReportService.addCreated(tAppParam.projectPath),
        ).called(1);
        verify(
          () => mockDirectoryService.exists('/workspace/portalapp/test'),
        ).called(1);
        verify(
          () => mockDirectoryService.delete('/workspace/portalapp/test'),
        ).called(1);
        verify(
          () => mockReportService.addRemoved('/workspace/portalapp/test'),
        ).called(1);
        verify(
          () => mockGeneratorService.generate(
            bundle: any(named: 'bundle'),
            targetPath: tAppParam.projectPath,
            vars: {
              'app': tAppParam.projectName,
              'app_name': tAppParam.appName,
              'org': tAppParam.org,
              'org_name': tAppParam.orgName,
              'dart_sdk': tConfig.sdkVersion,
              'android_min_sdk': tConfig.android.minSdk,
            },
          ),
        ).called(1);
        verify(() => mockFileService.exists(gradlePath)).called(1);
        verify(() => mockFileService.readAsString(gradlePath)).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: gradlePath,
            content: any(named: 'content'),
          ),
        ).called(1);
        verify(() => mockReportService.addInjected(gradlePath)).called(1);
        verify(
          () => mockProcessService.run('dart', [
            'pub',
            'add',
            'logging',
            'flutter_bloc',
            'provider',
            'get',
            'flutter_riverpod',
            'get_it',
            'go_router',
            'collection',
            'intl',
          ], tAppParam.projectPath),
        ).called(1);

        verify(
          () => mockProcessService.run('dart', [
            'pub',
            'add',
            '--dev',
            'flutter_lints',
            'flutter_launcher_icons',
            'package_rename',
          ], tAppParam.projectPath),
        ).called(1);
      },
    );

    test('Given an exception occurs during configuration loading, '
        'When generateApp is called, '
        'Then it throws an Exception and aborts the process', () async {
      // Arrange (Given)
      when(
        () => mockConfigService.loadConfig(),
      ).thenThrow(Exception('Config error'));

      // Act & Assert (When & Then)
      expect(
        () => appService.generateApp(app: tAppParam, onProgress: (_) {}),
        throwsA(isA<Exception>()),
      );

      verifyNever(() => mockProcessService.run(any(), any(), any()));
    });
  });
}
