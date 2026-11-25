import 'package:fsda_cli/domain/models/config_android_model.dart';
import 'package:fsda_cli/domain/models/config_model.dart';
import 'package:fsda_cli/domain/params/gen_app_param.dart';
import 'package:fsda_cli/infrastructure/bundles/app_bundle.dart';
import 'package:fsda_cli/infrastructure/services/app_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/config_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/mason_generator_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/process_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockConfigService extends Mock implements ConfigService {}

class MockProcessService extends Mock implements ProcessService {}

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

class MockMasonGeneratorService extends Mock implements MasonGeneratorService {}

void main() {
  late MockConfigService mockConfigService;
  late MockProcessService mockProcessService;
  late MockOperationReportService mockReportService;
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;
  late MockMasonGeneratorService mockGeneratorService;
  late AppService appService;

  const sampleParam = GenAppParam(
    appName: 'portal_app',
    appTitle: 'Portal App',
    org: 'com.fdelux',
    orgName: 'Flutter Delux',
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

  final expectedAppPath = p.join(
    '/projects/my_workspace',
    'apps',
    'portal_app',
  );
  final expectedTestPath = p.join(expectedAppPath, 'test');
  final expectedGradlePath = p.join(
    expectedAppPath,
    'android',
    'app',
    'build.gradle.kts',
  );

  setUpAll(() {
    registerFallbackValue(appBundle);
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

    when(
      () => mockConfigService.loadConfig(),
    ).thenAnswer((_) async => sampleConfig);
    when(
      () => mockProcessService.run(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockGeneratorService.generate(
        bundle: any(named: 'bundle'),
        targetPath: any(named: 'targetPath'),
        vars: any(named: 'vars'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockFileService.writeAsString(
        path: any(named: 'path'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});
  });

  group('AppService.generateApp', () {
    test(
      'GIVEN valid GenAppParam with existing test directory and build.gradle.kts '
      'WHEN generateApp is called '
      'THEN executes full generation workflow, updates Android SDKs, installs dependencies, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];
        const initialGradleContent = '''
android {
    compileSdk = flutter.compileSdkVersion
    defaultConfig {
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
    }
}
''';

        when(
          () => mockDirectoryService.exists(expectedTestPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockDirectoryService.delete(expectedTestPath),
        ).thenAnswer((_) async {});
        when(
          () => mockFileService.exists(expectedGradlePath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(expectedGradlePath),
        ).thenAnswer((_) async => initialGradleContent);

        // When
        await appService.generate(
          genApp: sampleParam,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Reading FSDA configuration...',
          'Running flutter create for "portal_app"...',
          'Cleaning up default test directory...',
          'Copying app bundle...',
          'Configuring Android SDK versions in build.gradle.kts...',
          'Installing package dependencies...',
        ]);

        // Verify flutter create & report
        verify(
          () => mockProcessService.run('flutter', [
            'create',
            '--org',
            'com.fdelux',
            'portal_app',
          ], p.dirname(expectedAppPath)),
        ).called(1);
        verify(() => mockReportService.addCreated(expectedAppPath)).called(1);

        // Verify test directory cleanup & report
        verify(() => mockDirectoryService.delete(expectedTestPath)).called(1);
        verify(() => mockReportService.addRemoved(expectedTestPath)).called(1);

        // Verify Mason bundle generation
        verify(
          () => mockGeneratorService.generate(
            bundle: appBundle,
            targetPath: expectedAppPath,
            vars: {
              'app': 'portal_app',
              'project_id': 'portalapp',
              'app_title': 'Portal App',
              'org': 'com.fdelux',
              'org_name': 'Flutter Delux',
              'dart_sdk': '^3.8.0',
              'android_min_sdk': 23,
            },
          ),
        ).called(1);

        // Verify build.gradle.kts update & report
        final capturedGradle =
            verify(
                  () => mockFileService.writeAsString(
                    path: expectedGradlePath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;

        expect(capturedGradle, contains('compileSdk = 35'));
        expect(capturedGradle, contains('minSdk = 23'));
        expect(capturedGradle, contains('targetSdk = 35'));
        verify(
          () => mockReportService.addInjected(expectedGradlePath),
        ).called(1);

        // Verify pub add calls
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
          ], expectedAppPath),
        ).called(1);
        verify(
          () => mockProcessService.run('dart', [
            'pub',
            'add',
            '--dev',
            'flutter_lints',
            'flutter_launcher_icons',
            'package_rename',
          ], expectedAppPath),
        ).called(1);
      },
    );

    test(
      'GIVEN test directory and build.gradle.kts do not exist '
      'WHEN generateApp is called '
      'THEN skips test deletion and gradle modification without throwing',
      () async {
        // Given
        when(
          () => mockDirectoryService.exists(expectedTestPath),
        ).thenAnswer((_) async => false);
        when(
          () => mockFileService.exists(expectedGradlePath),
        ).thenAnswer((_) async => false);

        // When
        await appService.generate(genApp: sampleParam, onProgress: (_) {});

        // Then
        verifyNever(() => mockDirectoryService.delete(any()));
        verifyNever(() => mockReportService.addRemoved(any()));
        verifyNever(() => mockFileService.readAsString(any()));
        verifyNever(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        );
        verifyNever(() => mockReportService.addInjected(any()));
      },
    );
  });
}
