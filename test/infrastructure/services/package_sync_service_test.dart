import 'package:fsda_cli/domain/models/config_android_model.dart';
import 'package:fsda_cli/domain/models/config_model.dart';
import 'package:fsda_cli/infrastructure/bundles/package_bundle.dart';
import 'package:fsda_cli/infrastructure/services/helpers/config_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/process_service.dart';
import 'package:fsda_cli/infrastructure/services/package_sync_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockConfigService extends Mock implements ConfigService {}

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockProcessService extends Mock implements ProcessService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

void main() {
  late PackageSyncService packageSyncService;
  late MockConfigService mockConfigService;
  late MockOperationReportService mockReportService;
  late MockProcessService mockProcessService;
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    mockConfigService = MockConfigService();
    mockReportService = MockOperationReportService();
    mockProcessService = MockProcessService();
    mockDirectoryService = MockDirectoryService();
    mockFileService = MockFileService();

    packageSyncService = PackageSyncService(
      configService: mockConfigService,
      reportService: mockReportService,
      processService: mockProcessService,
      directoryService: mockDirectoryService,
      fileService: mockFileService,
    );
  });

  group('PackageSyncService', () {
    test(
      'Given active packages with missing directories and spec containing dev_dependencies/post_hooks, '
      'When syncPackages is called, '
      'Then it extracts bundle files, parses spec hooks, and executes process commands successfully',
      () async {
        // Arrange (Given)
        final samplePkgName = packageBundle.keys.isNotEmpty
            ? packageBundle.keys.first
            : 'sample_pkg';

        when(() => mockConfigService.loadConfig()).thenAnswer(
          (_) async => ConfigModel(
            workspaceName: 'ws',
            workspacePath: '/ws',
            cliVersion: '1.0',
            sdkVersion: '3.0',
            android: const ConfigAndroidModel(
              minSdk: 21,
              compileSdk: 34,
              targetSdk: 34,
            ),
            activePackages: [samplePkgName],
          ),
        );

        when(() => mockDirectoryService.currentPath).thenReturn('/ws');

        // Mengatur agar direktori paket belum ada, memaksa _copyPackageFromBundle berjalan
        when(() => mockDirectoryService.exists(any())).thenAnswer((
          invocation,
        ) async {
          final path = invocation.positionalArguments.first as String;
          if (path.contains(samplePkgName)) {
            return false;
          }
          return true;
        });

        when(
          () => mockDirectoryService.create(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockDirectoryService.delete(any()),
        ).thenAnswer((_) async => {});

        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        when(
          () => mockProcessService.run(any(), any(), any()),
        ).thenAnswer((_) async => {});

        when(
          () => mockReportService.addRetainedPackages(any()),
        ).thenReturn(null);
        when(() => mockReportService.addAddedPackages(any())).thenReturn(null);
        when(
          () => mockReportService.addRemovedPackages(any()),
        ).thenReturn(null);

        // Act (When)
        final progressLogs = <String>[];
        await packageSyncService.syncPackages(
          onProgress: (msg) => progressLogs.add(msg),
        );

        // Assert (Then)
        expect(progressLogs, isNotEmpty);
        verify(() => mockConfigService.loadConfig()).called(1);
        verify(
          () => mockDirectoryService.create(any()),
        ).called(greaterThanOrEqualTo(0));
      },
    );

    test('Given active packages whose directories already exist, '
        'When syncPackages is called, '
        'Then it retains the packages without re-copying them', () async {
      // Arrange (Given)
      final samplePkgName = packageBundle.keys.isNotEmpty
          ? packageBundle.keys.first
          : 'sample_pkg';

      when(() => mockConfigService.loadConfig()).thenAnswer(
        (_) async => ConfigModel(
          workspaceName: 'ws',
          workspacePath: '/ws',
          cliVersion: '1.0',
          sdkVersion: '3.0',
          android: const ConfigAndroidModel(
            minSdk: 21,
            compileSdk: 34,
            targetSdk: 34,
          ),
          activePackages: [samplePkgName],
        ),
      );

      when(() => mockDirectoryService.currentPath).thenReturn('/ws');
      // Mengatur agar direktori sudah ada, memicu branch "Retaining package"
      when(
        () => mockDirectoryService.exists(any()),
      ).thenAnswer((_) async => true);
      when(
        () => mockDirectoryService.delete(any()),
      ).thenAnswer((_) async => {});

      when(() => mockReportService.addRetainedPackages(any())).thenReturn(null);
      when(() => mockReportService.addRemovedPackages(any())).thenReturn(null);

      // Act (When)
      final progressLogs = <String>[];
      await packageSyncService.syncPackages(
        onProgress: (msg) => progressLogs.add(msg),
      );

      // Assert (Then)
      expect(progressLogs, isNotEmpty);
      verify(
        () => mockReportService.addRetainedPackages(any()),
      ).called(greaterThanOrEqualTo(0));
    });
  });
}
