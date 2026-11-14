import 'dart:io';

import 'package:fsda_cli/domain/models/config_android_model.dart';
import 'package:fsda_cli/domain/models/config_model.dart';
import 'package:fsda_cli/domain/params/module_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/config_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/process_service.dart';
import 'package:fsda_cli/infrastructure/services/module_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockConfigService extends Mock implements ConfigService {}

class MockProcessService extends Mock implements ProcessService {}

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockDirectoryService extends Mock implements DirectoryService {}

void main() {
  late ModuleService moduleService;
  late MockConfigService mockConfigService;
  late MockProcessService mockProcessService;
  late MockOperationReportService mockReportService;
  late MockDirectoryService mockDirectoryService;

  setUp(() {
    mockConfigService = MockConfigService();
    mockProcessService = MockProcessService();
    mockReportService = MockOperationReportService();
    mockDirectoryService = MockDirectoryService();

    moduleService = ModuleService(
      configService: mockConfigService,
      processService: mockProcessService,
      reportService: mockReportService,
      directoryService: mockDirectoryService,
    );
  });

  group('ModuleService Tests', () {
    test(
      'generate module executes successfully including bundle generation and process run',
      () async {
        final tempDir = Directory.systemTemp.createTempSync(
          'fsda_module_test_',
        );
        addTearDown(() => tempDir.deleteSync(recursive: true));

        final modulePath = p.join(tempDir.path, 'modules', 'auth');
        final moduleParam = ModuleParam(name: 'auth', path: modulePath);
        const configModel = ConfigModel(
          workspaceName: 'ws',
          workspacePath: '/ws',
          cliVersion: '1.0',
          sdkVersion: '3.0',
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
          () => mockDirectoryService.create(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockDirectoryService.dirOf(any()),
        ).thenReturn(Directory(modulePath));
        when(
          () => mockProcessService.run(any(), any(), any()),
        ).thenAnswer((_) async => {});
        when(() => mockReportService.addCreated(any())).thenReturn(null);

        final progressLogs = <String>[];
        await moduleService.generate(
          module: moduleParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        verify(() => mockConfigService.loadConfig()).called(1);
        verify(
          () => mockProcessService.run('dart', any(), modulePath),
        ).called(2);
      },
    );

    test(
      'generate throws exception when bundle generation fails (covering catch block)',
      () async {
        final moduleParam = const ModuleParam(
          name: 'auth',
          path: '/modules/auth',
        );
        const configModel = ConfigModel(
          workspaceName: 'ws',
          workspacePath: '/ws',
          cliVersion: '1.0',
          sdkVersion: '3.0',
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
          () => mockDirectoryService.create(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockDirectoryService.dirOf(any()),
        ).thenThrow(Exception('Bundle generation failed'));

        expect(
          () => moduleService.generate(module: moduleParam, onProgress: (_) {}),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
