import 'package:fsda_cli/domain/params/local_ds_param.dart';
import 'package:fsda_cli/domain/params/remote_ds_param.dart';
import 'package:fsda_cli/infrastructure/services/data_source_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/data_source_template.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repository_template.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockExportService extends Mock implements ExportService {}

class MockFileService extends Mock implements FileService {}

class MockImportService extends Mock implements ImportService {}

void main() {
  late MockOperationReportService mockReportService;
  late MockExportService mockExportService;
  late MockFileService mockFileService;
  late MockImportService mockImportService;
  late DataSourceService dataSourceService;

  const workspacePath = '/projects/my_workspace';
  final expectedFeaturePath = p.join(
    workspacePath,
    'modules',
    'project_management',
    'lib',
    'src',
    'features',
    'task',
  );
  final expectedBarrelPath = p.join(expectedFeaturePath, 'task_feature.dart');
  final expectedRepoImplPath = p.join(
    expectedFeaturePath,
    'data',
    'repositories',
    'task_repository_impl.dart',
  );

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

    when(
      () => mockFileService.writeAsString(
        path: any(named: 'path'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockExportService.inject(
        barrelPath: any(named: 'barrelPath'),
        exportLines: any(named: 'exportLines'),
        checkpoint: any(named: 'checkpoint'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockImportService.injectImport(
        path: any(named: 'path'),
        imports: any(named: 'imports'),
      ),
    ).thenAnswer((_) async {});
  });

  group('DataSourceService.generateRemoteDataSource', () {
    const remoteParam = RemoteDsParam(
      basePath: '/api/v1/tasks',
      featureName: 'task',
      moduleName: 'project_management',
      workspaceName: 'my_workspace',
      workspacePath: workspacePath,
    );

    final expectedInterfacePath = p.join(
      expectedFeaturePath,
      'data',
      'datasources',
      'task_remote_data_source.dart',
    );
    final expectedImplPath = p.join(
      expectedFeaturePath,
      'data',
      'datasources',
      'task_remote_data_source_impl.dart',
    );

    test(
      'GIVEN valid RemoteDsParam and existing repository implementation '
      'WHEN generateRemoteDataSource is called '
      'THEN creates interface and impl files, exports to barrel, injects into repository impl, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];
        final initialRepoImpl = RepositoryTemplate.implClass('task');

        when(
          () => mockFileService.exists(expectedRepoImplPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(expectedRepoImplPath),
        ).thenAnswer((_) async => initialRepoImpl);

        // When
        await dataSourceService.generateRemoteDataSource(
          remoteDs: remoteParam,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Creating remote data source interface...',
          'Injecting export remote data source interface...',
          'Creating remote data source implementation...',
          'Injecting export remote data source impl...',
          'Injecting remote data source into repository implementation...',
        ]);

        // Verify interface & impl file creation
        verify(
          () => mockFileService.writeAsString(
            path: expectedInterfacePath,
            content: DataSourceTemplate.interfaceClass(
              feature: 'task',
              mode: remoteParam.mode,
            ),
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedInterfacePath),
        ).called(1);

        verify(
          () => mockFileService.writeAsString(
            path: expectedImplPath,
            content: DataSourceTemplate.remoteImplClass(
              feature: 'task',
              basePath: '/api/v1/tasks',
            ),
          ),
        ).called(1);
        verify(() => mockReportService.addCreated(expectedImplPath)).called(1);

        // Verify barrel exports
        verify(
          () => mockExportService.inject(
            barrelPath: expectedBarrelPath,
            exportLines: [
              "export 'data/datasources/task_remote_data_source.dart';",
            ],
            checkpoint: '// data',
          ),
        ).called(1);
        verify(
          () => mockExportService.inject(
            barrelPath: expectedBarrelPath,
            exportLines: [
              "export 'data/datasources/task_remote_data_source_impl.dart';",
            ],
            checkpoint: '// data',
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(expectedBarrelPath),
        ).called(2);

        // Verify repository implementation injection
        final capturedRepoContent =
            verify(
                  () => mockFileService.writeAsString(
                    path: expectedRepoImplPath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;

        expect(
          capturedRepoContent,
          contains('  final TaskRemoteDataSource _remoteDataSource;'),
        );
        expect(
          capturedRepoContent,
          contains('    required TaskRemoteDataSource taskRemoteDataSource,'),
        );
        expect(
          capturedRepoContent,
          contains('       _remoteDataSource = taskRemoteDataSource,'),
        );

        verify(
          () => mockImportService.injectImport(
            path: expectedRepoImplPath,
            imports: {"import '../datasources/task_remote_data_source.dart';"},
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(expectedRepoImplPath),
        ).called(1);
      },
    );

    test(
      'GIVEN repository implementation does not exist '
      'WHEN generateRemoteDataSource is called '
      'THEN creates files and barrel exports without modifying repository implementation',
      () async {
        // Given
        when(
          () => mockFileService.exists(expectedRepoImplPath),
        ).thenAnswer((_) async => false);

        // When
        await dataSourceService.generateRemoteDataSource(
          remoteDs: remoteParam,
          onProgress: (_) {},
        );

        // Then
        verifyNever(() => mockFileService.readAsString(any()));
        verifyNever(
          () => mockImportService.injectImport(
            path: any(named: 'path'),
            imports: any(named: 'imports'),
          ),
        );
        verifyNever(() => mockReportService.addInjected(expectedRepoImplPath));
      },
    );

    test(
      'GIVEN repository implementation already contains TaskRemoteDataSource '
      'WHEN generateRemoteDataSource is called '
      'THEN skips duplicate repository injection',
      () async {
        // Given
        const alreadyInjectedContent = '''
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;
}
''';
        when(
          () => mockFileService.exists(expectedRepoImplPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(expectedRepoImplPath),
        ).thenAnswer((_) async => alreadyInjectedContent);

        // When
        await dataSourceService.generateRemoteDataSource(
          remoteDs: remoteParam,
          onProgress: (_) {},
        );

        // Then
        verifyNever(
          () => mockFileService.writeAsString(
            path: expectedRepoImplPath,
            content: any(named: 'content'),
          ),
        );
        verifyNever(
          () => mockImportService.injectImport(
            path: any(named: 'path'),
            imports: any(named: 'imports'),
          ),
        );
        verifyNever(() => mockReportService.addInjected(expectedRepoImplPath));
      },
    );
  });

  group('DataSourceService.generateLocalDataSource', () {
    const localParam = LocalDsParam(
      cacheKey: 'cached_tasks_key',
      featureName: 'task',
      moduleName: 'project_management',
      workspaceName: 'my_workspace',
      workspacePath: workspacePath,
    );

    final expectedInterfacePath = p.join(
      expectedFeaturePath,
      'data',
      'datasources',
      'task_local_data_source.dart',
    );
    final expectedImplPath = p.join(
      expectedFeaturePath,
      'data',
      'datasources',
      'task_local_data_source_impl.dart',
    );

    test(
      'GIVEN valid LocalDsParam and existing repository implementation '
      'WHEN generateLocalDataSource is called '
      'THEN creates local interface and impl files, exports to barrel, injects into repository impl, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];
        final initialRepoImpl = RepositoryTemplate.implClass('task');
        when(
          () => mockFileService.exists(expectedRepoImplPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(expectedRepoImplPath),
        ).thenAnswer((_) async => initialRepoImpl);
        // When
        await dataSourceService.generateLocalDataSource(
          localDs: localParam,
          onProgress: progressLogs.add,
        );
        // Then
        expect(progressLogs, [
          'Creating local data source interface...',
          'Injecting export local data source interface...',
          'Creating local data source implementation...',
          'Injecting export local data source impl...',
          'Injecting local data source into repository implementation...',
        ]);
        // Verify interface & impl file creation
        verify(
          () => mockFileService.writeAsString(
            path: expectedInterfacePath,
            content: DataSourceTemplate.interfaceClass(
              feature: 'task',
              mode: localParam.mode,
            ),
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedInterfacePath),
        ).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: expectedImplPath,
            content: DataSourceTemplate.localImplClass(
              feature: 'task',
              cacheKey: 'cached_tasks_key',
            ),
          ),
        ).called(1);
        verify(() => mockReportService.addCreated(expectedImplPath)).called(1);
        // Verify barrel exports
        verify(
          () => mockExportService.inject(
            barrelPath: expectedBarrelPath,
            exportLines: [
              "export 'data/datasources/task_local_data_source.dart';",
            ],
            checkpoint: '// data',
          ),
        ).called(1);
        verify(
          () => mockExportService.inject(
            barrelPath: expectedBarrelPath,
            exportLines: [
              "export 'data/datasources/task_local_data_source_impl.dart';",
            ],
            checkpoint: '// data',
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(expectedBarrelPath),
        ).called(2);
        // Verify repository implementation injection
        final capturedRepoContent =
            verify(
                  () => mockFileService.writeAsString(
                    path: expectedRepoImplPath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;
        expect(
          capturedRepoContent,
          contains('  final TaskLocalDataSource _localDataSource;'),
        );
        expect(
          capturedRepoContent,
          contains('    required TaskLocalDataSource taskLocalDataSource,'),
        );
        expect(
          capturedRepoContent,
          contains('       _localDataSource = taskLocalDataSource,'),
        );
        verify(
          () => mockImportService.injectImport(
            path: expectedRepoImplPath,
            imports: {"import '../datasources/task_local_data_source.dart';"},
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(expectedRepoImplPath),
        ).called(1);
      },
    );
  });
}
