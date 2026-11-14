import 'package:fsda_cli/domain/params/local_ds_param.dart';
import 'package:fsda_cli/domain/params/remote_ds_param.dart';
import 'package:fsda_cli/infrastructure/services/data_source_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockExportService extends Mock implements ExportService {}

class MockFileService extends Mock implements FileService {}

class MockImportService extends Mock implements ImportService {}

void main() {
  late DataSourceService dataSourceService;
  late MockOperationReportService mockReportService;
  late MockExportService mockExportService;
  late MockFileService mockFileService;
  late MockImportService mockImportService;

  setUp(() {
    mockReportService = MockOperationReportService();
    mockExportService = MockExportService();
    mockFileService = MockFileService();
    mockImportService = MockImportService();

    dataSourceService = DataSourceService(
      reportService: mockReportService,
      exportService: mockExportService,
      fileService: mockFileService,
      importService: mockImportService,
    );
  });

  group('DataSourceService Tests', () {
    test(
      'generateRemoteDataSource should execute full remote data source pipeline successfully',
      () async {
        const remoteDsParam = RemoteDsParam(
          moduleName: 'auth',
          modulePath: '/modules/auth',
          featureName: 'auth',
          featurePath: '/modules/auth/lib/src/features/auth',
          basePath: '/api',
        );

        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockExportService.inject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
            checkpoint: any(named: 'checkpoint'),
          ),
        ).thenAnswer((_) async => {});
        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);
        when(() => mockFileService.readAsString(any())).thenAnswer(
          (_) async => '''
class AuthRepositoryImpl {
  // [_FIELD]
  // [_PARAM]
  // [_INIT]
}
''',
        );
        when(
          () => mockImportService.injectImport(
            path: any(named: 'path'),
            imports: any(named: 'imports'),
          ),
        ).thenAnswer((_) async => {});
        when(() => mockReportService.addCreated(any())).thenReturn(null);
        when(() => mockReportService.addInjected(any())).thenReturn(null);

        final progressLogs = <String>[];

        await dataSourceService.generateRemoteDataSource(
          remoteDs: remoteDsParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        expect(
          progressLogs.first,
          contains('Creating remote data source interface'),
        );

        verify(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).called(3);
        verify(
          () => mockExportService.inject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
            checkpoint: any(named: 'checkpoint'),
          ),
        ).called(2);
        verify(() => mockReportService.addCreated(any())).called(2);
        verify(() => mockReportService.addInjected(any())).called(3);
      },
    );

    test(
      'generateLocalDataSource should execute full local data source pipeline when repository impl exists',
      () async {
        const localDsParam = LocalDsParam(
          moduleName: 'core',
          modulePath: '/apps/myapp/core',
          featureName: 'auth',
          featurePath: '/apps/myapp/core/auth',
          cacheKey: 'auth_key',
        );

        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockExportService.inject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
            checkpoint: any(named: 'checkpoint'),
          ),
        ).thenAnswer((_) async => {});
        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);
        when(() => mockFileService.readAsString(any())).thenAnswer(
          (_) async =>
              'class AuthRepositoryImpl {\n  // [DS_FIELD]\n  // [DS_PARAM]\n  // [DS_INIT]\n}',
        );
        when(
          () => mockImportService.injectImport(
            path: any(named: 'path'),
            imports: any(named: 'imports'),
          ),
        ).thenAnswer((_) async => {});
        when(() => mockReportService.addCreated(any())).thenReturn(null);
        when(() => mockReportService.addInjected(any())).thenReturn(null);

        final progressLogs = <String>[];

        await dataSourceService.generateLocalDataSource(
          localDs: localDsParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        expect(
          progressLogs.first,
          contains('Creating local data source interface'),
        );

        verify(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).called(3);
        verify(
          () => mockExportService.inject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
            checkpoint: any(named: 'checkpoint'),
          ),
        ).called(2);
        verify(() => mockReportService.addCreated(any())).called(2);
        verify(() => mockReportService.addInjected(any())).called(3);
      },
    );

    test(
      'generateLocalDataSource should skip repository injection when repository impl does not exist',
      () async {
        const localDsParam = LocalDsParam(
          moduleName: 'core',
          modulePath: '/apps/myapp/core',
          featureName: 'auth',
          featurePath: '/apps/myapp/core/auth',
          cacheKey: 'auth_key',
        );
        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockExportService.inject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
            checkpoint: any(named: 'checkpoint'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockFileService.exists(any()),
        ).thenAnswer((_) async => false);
        when(() => mockReportService.addCreated(any())).thenReturn(null);
        when(() => mockReportService.addInjected(any())).thenReturn(null);

        final progressLogs = <String>[];

        await dataSourceService.generateLocalDataSource(
          localDs: localDsParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);

        verify(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).called(2);
        verify(
          () => mockExportService.inject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
            checkpoint: any(named: 'checkpoint'),
          ),
        ).called(2);
        verify(() => mockReportService.addCreated(any())).called(2);
        verify(() => mockReportService.addInjected(any())).called(2);
      },
    );
  });
}
