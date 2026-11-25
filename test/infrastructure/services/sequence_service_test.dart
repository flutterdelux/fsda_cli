import 'package:fsda_cli/core/extensions/feature_param_x.dart';
import 'package:fsda_cli/core/extensions/flow_type_x.dart';
import 'package:fsda_cli/core/extensions/module_param_x.dart';
import 'package:fsda_cli/core/extensions/sequence_param_x.dart';
import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_resolver_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/method_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/sequence_service.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/data_source_template.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/local_ds_body_template.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/remote_ds_body_template.dart';
import 'package:fsda_cli/infrastructure/templates/feature_template.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repo_body_template.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repository_template.dart';
import 'package:fsda_cli/infrastructure/templates/use_case_template.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockFileService extends Mock implements FileService {}

class MockArbService extends Mock implements ArbService {}

class MockExportService extends Mock implements ExportService {}

class MockMethodService extends Mock implements MethodService {}

class MockImportService extends Mock implements ImportService {}

class MockImportResolverService extends Mock implements ImportResolverService {}

void main() {
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockArbService mockArbService;
  late MockExportService mockExportService;
  late MockMethodService mockMethodService;
  late MockImportService mockImportService;
  late MockImportResolverService mockImportResolverService;
  late SequenceService sequenceService;

  const workspacePath = '/projects/my_workspace';
  const moduleName = 'project_management';
  const featureName = 'task';

  const remoteSequence = SequenceParam(
    action: Action.post,
    usecase: 'task_create_use_case',
    method: 'create_task',
    flow: FlowType.asynchronous,
    dsMode: DsMode.remote,
    entity: 'task_entity',
    dto: 'task_dto',
    param: 'task_create_param',
    request: 'task_create_request',
    response: 'task_response',
    featureName: featureName,
    moduleName: moduleName,
    workspaceName: 'my_workspace',
    workspacePath: workspacePath,
  );

  const localSequence = SequenceParam(
    action: Action.get,
    usecase: 'task_cached_get_use_case',
    method: 'get_cached_task',
    flow: FlowType.synchronous,
    dsMode: DsMode.local,
    entity: 'task_entity',
    dto: 'task_dto',
    featureName: featureName,
    moduleName: moduleName,
    workspaceName: 'my_workspace',
    workspacePath: workspacePath,
  );

  final expectedModulePath = remoteSequence.modulePath;
  final arbPaths = [
    p.join(expectedModulePath, 'lib', 'l10n', 'app_en.arb'),
    p.join(expectedModulePath, 'lib', 'l10n', 'app_id.arb'),
  ];

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockArbService = MockArbService();
    mockExportService = MockExportService();
    mockMethodService = MockMethodService();
    mockImportService = MockImportService();
    mockImportResolverService = MockImportResolverService();

    sequenceService = SequenceService(
      reportService: mockReportService,
      fileService: mockFileService,
      arbService: mockArbService,
      exportService: mockExportService,
      methodService: mockMethodService,
      importService: mockImportService,
      importResolverService: mockImportResolverService,
    );

    when(
      () => mockMethodService.injectToClass(
        path: any(named: 'path'),
        methodCode: any(named: 'methodCode'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockMethodService.unjectFromClass(
        path: any(named: 'path'),
        methodName: any(named: 'methodName'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockImportResolverService.resolve(
        rawTypes: any(named: 'rawTypes'),
        targetFilePath: any(named: 'targetFilePath'),
        modulePath: any(named: 'modulePath'),
      ),
    ).thenAnswer((_) async => {"import 'package:app_core/app_core.dart';"});
    when(
      () => mockImportService.injectImport(
        path: any(named: 'path'),
        imports: any(named: 'imports'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockFileService.writeAsString(
        path: any(named: 'path'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockFileService.delete(any())).thenAnswer((_) async {});
    when(
      () => mockExportService.inject(
        barrelPath: any(named: 'barrelPath'),
        exportLines: any(named: 'exportLines'),
        checkpoint: any(named: 'checkpoint'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockExportService.unject(
        barrelPath: any(named: 'barrelPath'),
        exportLines: any(named: 'exportLines'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockArbService.getArbPaths(expectedModulePath),
    ).thenAnswer((_) async => arbPaths);
    when(
      () => mockArbService.injectEntriesBeforeKey(
        arbPath: any(named: 'arbPath'),
        arbEntries: any(named: 'arbEntries'),
        endKey: any(named: 'endKey'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockArbService.unjectEntries(
        arbPath: any(named: 'arbPath'),
        arbEntries: any(named: 'arbEntries'),
      ),
    ).thenAnswer((_) async {});
  });

  group('SequenceService.generate', () {
    test(
      'GIVEN valid remote SequenceParam '
      'WHEN generate is called '
      'THEN injects methods & imports across datasource, repository, creates use case, exports barrel, injects ARB, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];

        // When
        await sequenceService.generate(
          sequence: remoteSequence,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Injecting method to datasource interface...',
          'Injecting import model to datasource interface...',
          'Injecting method to datasource implementation...',
          'Injecting import model to datasource implementation...',
          'Injecting method to repository interface...',
          'Injecting import model to repository interface...',
          'Injecting method to repository implementation...',
          'Injecting import model to repository implementation...',
          'Creating use case and injecting export to feature barrel...',
          'Injecting import to use case...',
          'Injecting use case localization...',
        ]);

        // 1. DataSource Interface
        verify(
          () => mockMethodService.injectToClass(
            path: remoteSequence.dsInterfacePath,
            methodCode: DataSourceTemplate.interfaceMethod(remoteSequence),
          ),
        ).called(1);
        verify(
          () => mockImportResolverService.resolve(
            rawTypes: {
              'TaskDto',
              'TaskCreateRequest',
              ?remoteSequence.flow.returnType,
            },
            targetFilePath: remoteSequence.dsInterfacePath,
            modulePath: expectedModulePath,
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(remoteSequence.dsInterfacePath),
        ).called(2);

        // 2. DataSource Implementation (Remote)
        verify(
          () => mockMethodService.injectToClass(
            path: remoteSequence.dsImplPath,
            methodCode: DataSourceTemplate.implMethod(
              sequence: remoteSequence,
              body: RemoteDsBodyTemplate.build(remoteSequence),
            ),
          ),
        ).called(1);
        verify(
          () => mockImportResolverService.resolve(
            rawTypes: {
              'TaskDto',
              'TaskCreateRequest',
              'TaskResponse',
              ?remoteSequence.flow.returnType,
              'ProjectManagementException',
            },
            targetFilePath: remoteSequence.dsImplPath,
            modulePath: expectedModulePath,
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(remoteSequence.dsImplPath),
        ).called(2);

        // 3. Repository Interface
        verify(
          () => mockMethodService.injectToClass(
            path: remoteSequence.repoInterfacePath,
            methodCode: RepositoryTemplate.interfaceMethod(remoteSequence),
          ),
        ).called(1);
        verify(
          () => mockImportResolverService.resolve(
            rawTypes: {
              'TaskEntity',
              'TaskCreateParam',
              remoteSequence.flow.resultType,
            },
            targetFilePath: remoteSequence.repoInterfacePath,
            modulePath: expectedModulePath,
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(remoteSequence.repoInterfacePath),
        ).called(2);
        // 4. Repository Implementation
        verify(
          () => mockMethodService.injectToClass(
            path: remoteSequence.repoImplPath,
            methodCode: RepositoryTemplate.implMethod(
              sequence: remoteSequence,
              body: RepoBodyTemplate.build(remoteSequence),
            ),
          ),
        ).called(1);
        verify(
          () => mockImportResolverService.resolve(
            rawTypes: {
              'TaskEntity',
              'TaskCreateParam',
              'TaskDto',
              'TaskCreateRequest',
              remoteSequence.flow.resultType,
            },
            targetFilePath: remoteSequence.repoImplPath,
            modulePath: expectedModulePath,
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(remoteSequence.repoImplPath),
        ).called(2);
        // 5. UseCase creation, export, & import
        verify(
          () => mockFileService.writeAsString(
            path: remoteSequence.ucPath,
            content: UseCaseTemplate.build(sequence: remoteSequence),
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(remoteSequence.ucPath),
        ).called(1);
        verify(
          () => mockExportService.inject(
            barrelPath: remoteSequence.featureBarrelPath,
            exportLines: [
              "export 'domain/usecases/task_create_use_case.dart';",
            ],
            checkpoint: '// domain',
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(remoteSequence.featureBarrelPath),
        ).called(1);
        verify(
          () => mockImportResolverService.resolve(
            rawTypes: {'TaskEntity', 'TaskCreateParam'},
            targetFilePath: remoteSequence.ucPath,
            modulePath: expectedModulePath,
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(remoteSequence.ucPath),
        ).called(1);
        // 6. ARB localization entries
        final expectedArbEntries = UseCaseTemplate.buildArbEntries(
          remoteSequence,
        );
        final expectedEndKey = FeatureTemplate.endDividerArbKey(featureName);
        for (final arbPath in arbPaths) {
          verify(
            () => mockArbService.injectEntriesBeforeKey(
              arbPath: arbPath,
              arbEntries: expectedArbEntries,
              endKey: expectedEndKey,
            ),
          ).called(1);
        }
      },
    );
    test(
      'GIVEN local SequenceParam with DsMode.local '
      'WHEN generate is called '
      'THEN uses LocalDsBodyTemplate for datasource implementation',
      () async {
        // When
        await sequenceService.generate(
          sequence: localSequence,
          onProgress: (_) {},
        );
        // Then
        verify(
          () => mockMethodService.injectToClass(
            path: localSequence.dsImplPath,
            methodCode: DataSourceTemplate.implMethod(
              sequence: localSequence,
              body: LocalDsBodyTemplate.build(localSequence),
            ),
          ),
        ).called(1);
      },
    );
  });
  group('SequenceService.remove', () {
    test(
      'GIVEN valid SequenceParam and existing use case file '
      'WHEN remove is called '
      'THEN unjects methods from datasource & repository, deletes use case file, unjects barrel export and ARB entries',
      () async {
        // Given
        final progressLogs = [];
        when(
          () => mockFileService.exists(remoteSequence.ucPath),
        ).thenAnswer((_) async => true);
        // When
        await sequenceService.remove(
          sequence: remoteSequence,
          onProgress: progressLogs.add,
        );
        // Then
        expect(progressLogs, [
          'Unjecting method from datasource interface...',
          'Unjecting method from datasource implementation...',
          'Unjecting method from repository interface...',
          'Unjecting method from repository implementation...',
          'Removing use case file and unjecting barrel export...',
          'Unjecting localization entries...',
        ]);
        // Verify unject methods
        for (final targetPath in [
          remoteSequence.dsInterfacePath,
          remoteSequence.dsImplPath,
          remoteSequence.repoInterfacePath,
          remoteSequence.repoImplPath,
        ]) {
          verify(
            () => mockMethodService.unjectFromClass(
              path: targetPath,
              methodName: 'create_task',
            ),
          ).called(1);
          verify(() => mockReportService.addUnjected(targetPath)).called(1);
        }
        // Verify use case removal & barrel unjection
        verify(() => mockFileService.delete(remoteSequence.ucPath)).called(1);
        verify(
          () => mockReportService.addRemoved(remoteSequence.ucPath),
        ).called(1);
        verify(
          () => mockExportService.unject(
            barrelPath: remoteSequence.featureBarrelPath,
            exportLines: [
              "export 'domain/usecases/task_create_use_case.dart';",
            ],
          ),
        ).called(1);
        verify(
          () => mockReportService.addUnjected(remoteSequence.featureBarrelPath),
        ).called(1);
        // Verify ARB unjection
        final expectedArbEntries = UseCaseTemplate.buildArbEntries(
          remoteSequence,
        );
        for (final arbPath in arbPaths) {
          verify(
            () => mockArbService.unjectEntries(
              arbPath: arbPath,
              arbEntries: expectedArbEntries,
            ),
          ).called(1);
          verify(() => mockReportService.addUnjected(arbPath)).called(1);
        }
      },
    );
    test(
      'GIVEN use case file does not exist '
      'WHEN remove is called '
      'THEN skips deleting use case file while still unjecting methods, barrel export, and ARB entries',
      () async {
        // Given
        when(
          () => mockFileService.exists(remoteSequence.ucPath),
        ).thenAnswer((_) async => false);
        // When
        await sequenceService.remove(
          sequence: remoteSequence,
          onProgress: (_) {},
        );
        // Then
        verifyNever(() => mockFileService.delete(remoteSequence.ucPath));
        verifyNever(() => mockReportService.addRemoved(remoteSequence.ucPath));
        verify(
          () => mockExportService.unject(
            barrelPath: remoteSequence.featureBarrelPath,
            exportLines: [
              "export 'domain/usecases/task_create_use_case.dart';",
            ],
          ),
        ).called(1);
      },
    );
  });
}
