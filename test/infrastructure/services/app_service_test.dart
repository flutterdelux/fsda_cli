import 'dart:io';

import 'package:fsda_cli/domain/models/config_android_model.dart';
import 'package:fsda_cli/domain/models/config_model.dart';
import 'package:fsda_cli/domain/params/app_param.dart';
import 'package:fsda_cli/infrastructure/services/app_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/config_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
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

void main() {
  late AppService appService;
  late MockConfigService mockConfigService;
  late MockProcessService mockProcessService;
  late MockOperationReportService mockReportService;
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;

  setUp(() {
    mockConfigService = MockConfigService();
    mockProcessService = MockProcessService();
    mockReportService = MockOperationReportService();
    mockDirectoryService = MockDirectoryService();
    mockFileService = MockFileService();

    appService = AppService(
      configService: mockConfigService,
      processService: mockProcessService,
      reportService: mockReportService,
      directoryService: mockDirectoryService,
      fileService: mockFileService,
    );
  });

  group('AppService Tests', () {
    test(
      'generateApp should execute full generation pipeline successfully',
      () async {
        final tempDir = Directory.systemTemp.createTempSync('fsda_test_');
        addTearDown(() => tempDir.deleteSync(recursive: true));

        final projectPath = p.join(tempDir.path, 'my_app');

        final appParam = AppParam(
          projectName: 'my_app',
          appName: 'My App',
          org: 'com.example',
          orgName: 'Example',
          projectPath: projectPath,
        );

        final configModel = const ConfigModel(
          workspaceName: 'my_workspace',
          workspacePath: '/project',
          cliVersion: '1.0.0',
          sdkVersion: '3.0.0',
          android: ConfigAndroidModel(
            minSdk: 21,
            compileSdk: 34,
            targetSdk: 34,
          ),
        );

        when(
          () => mockConfigService.loadConfig(),
        ).thenAnswer((_) async => configModel);
        when(
          () => mockProcessService.run(any(), any(), any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockDirectoryService.exists(any()),
        ).thenAnswer((_) async => true);
        when(
          () => mockDirectoryService.delete(any()),
        ).thenAnswer((_) async => Directory(p.join(projectPath, 'test')));
        when(
          () => mockDirectoryService.dirOf(any()),
        ).thenReturn(Directory(projectPath));

        final gradlePath = p.join(
          projectPath,
          'android',
          'app',
          'build.gradle.kts',
        );

        when(
          () => mockFileService.exists(gradlePath),
        ).thenAnswer((_) async => true);
        when(() => mockFileService.readAsString(gradlePath)).thenAnswer(
          (_) async => 'compileSdk = 30\nminSdk = 19\ntargetSdk = 30',
        );
        when(
          () => mockFileService.writeAsString(
            path: gradlePath,
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        when(() => mockReportService.addCreated(any())).thenReturn(null);
        when(() => mockReportService.addRemoved(any())).thenReturn(null);
        when(() => mockReportService.addInjected(any())).thenReturn(null);

        final progressLogs = <String>[];

        await appService.generateApp(
          app: appParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        expect(progressLogs.first, contains('Reading FSDA configuration'));
        verify(() => mockConfigService.loadConfig()).called(1);
        verify(() => mockProcessService.run('flutter', any(), any())).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: gradlePath,
            content: any(named: 'content'),
          ),
        ).called(1);
      },
    );

    test(
      'generateApp should throw exception when template generation fails',
      () async {
        final appParam = const AppParam(
          projectName: 'my_app',
          appName: 'My App',
          org: 'com.example',
          orgName: 'Example',
          projectPath: '/invalid/path',
        );

        final configModel = const ConfigModel(
          workspaceName: 'my_workspace',
          workspacePath: '/project',
          cliVersion: '1.0.0',
          sdkVersion: '3.0.0',
          android: ConfigAndroidModel(
            minSdk: 21,
            compileSdk: 34,
            targetSdk: 34,
          ),
        );

        when(
          () => mockConfigService.loadConfig(),
        ).thenAnswer((_) async => configModel);
        when(
          () => mockProcessService.run(any(), any(), any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockDirectoryService.exists(any()),
        ).thenAnswer((_) async => true);
        when(
          () => mockDirectoryService.delete(any()),
        ).thenAnswer((_) async => Directory('/invalid/path/test'));
        // Memaksa error pada dirOf agar memicu blok catch di _overwriteAppTemplate
        when(
          () => mockDirectoryService.dirOf(any()),
        ).thenThrow(Exception('Directory error'));

        final progressLogs = <String>[];

        expect(
          () => appService.generateApp(
            app: appParam,
            onProgress: (msg) => progressLogs.add(msg),
          ),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
