import 'package:fsda_cli/core/extensions/feature_param_x.dart';
import 'package:fsda_cli/core/extensions/logic_flow_param_x.dart';
import 'package:fsda_cli/core/extensions/module_param_x.dart';
import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_resolver_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/logic_uc_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/logic_service.dart';
import 'package:fsda_cli/infrastructure/templates/logics/logic_template.dart';
import 'package:fsda_cli/infrastructure/templates/logics/state_flow_template.dart';
import 'package:fsda_cli/infrastructure/templates/logics/state_template.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockFileService extends Mock implements FileService {}

class MockImportService extends Mock implements ImportService {}

class MockImportResolverService extends Mock implements ImportResolverService {}

class MockExportService extends Mock implements ExportService {}

class MockLogicUcService extends Mock implements LogicUcService {}

void main() {
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockImportService mockImportService;
  late MockImportResolverService mockImportResolverService;
  late MockExportService mockExportService;
  late MockLogicUcService mockLogicUcService;
  late LogicService logicService;

  const workspacePath = '/projects/my_workspace';

  const sampleLogicParam = LogicParam(
    props: [
      PropModel(
        type: 'TaskStatus',
        name: 'selected_status',
        defaultValue: 'TaskStatus.todo',
        converter: '',
      ),
    ],
    control: StateControl.cubit,
    featureName: 'task',
    moduleName: 'project_management',
    sliceName: 'filter',
    workspaceName: 'my_workspace',
    workspacePath: workspacePath,
  );

  const sampleLogicFlowParam = LogicFlowParam(
    type: LogicFlowType.mutation,
    uc: 'task_create_use_case.dart',
    control: StateControl.cubit,
    featureName: 'task',
    moduleName: 'project_management',
    sliceName: 'create',
    workspaceName: 'my_workspace',
    workspacePath: workspacePath,
  );

  const inspectedUc = LogicUcModel(
    name: 'task_create_use_case',
    path: 'domain/usecases/task_create_use_case.dart',
    type: UcType.returnParamUc,
    repoMethod: 'createTask',
    returnType: 'TaskEntity',
    paramType: 'TaskCreateParam',
  );

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockImportService = MockImportService();
    mockImportResolverService = MockImportResolverService();
    mockExportService = MockExportService();
    mockLogicUcService = MockLogicUcService();

    logicService = LogicService(
      reportService: mockReportService,
      fileService: mockFileService,
      importService: mockImportService,
      importResolverService: mockImportResolverService,
      exportService: mockExportService,
      logicUcService: mockLogicUcService,
    );

    when(
      () => mockFileService.writeAsString(
        path: any(named: 'path'),
        content: any(named: 'content'),
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
      () => mockExportService.inject(
        barrelPath: any(named: 'barrelPath'),
        exportLines: any(named: 'exportLines'),
        checkpoint: any(named: 'checkpoint'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockLogicUcService.inspectUseCase(sampleLogicFlowParam.ucPath),
    ).thenAnswer((_) async => inspectedUc);
  });

  group('LogicService.generate', () {
    test(
      'GIVEN state file does not exist and LogicParam has typesToImport '
      'WHEN generate is called '
      'THEN creates both state and logic files, resolves imports, injects barrel exports, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];
        final expectedState = StateTemplate.build(sampleLogicParam);
        final expectedLogic = LogicTemplate.build(sampleLogicParam);
        final barrelPath = sampleLogicParam.featureBarrelPath;

        when(
          () => mockFileService.exists(expectedState.path),
        ).thenAnswer((_) async => false);

        // When
        await logicService.generate(
          logic: sampleLogicParam,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Creating state file, resolve import and export to feature barrel...',
          'Creating logic file, resolve import and export to feature barrel...',
        ]);

        // Verify state creation, import resolution, & export
        verify(
          () => mockFileService.writeAsString(
            path: expectedState.path,
            content: expectedState.content,
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedState.path),
        ).called(1);
        verify(
          () => mockImportResolverService.resolve(
            rawTypes: expectedState.typesToImport,
            targetFilePath: expectedState.path,
            modulePath: sampleLogicParam.modulePath,
          ),
        ).called(1);
        verify(
          () => mockImportService.injectImport(
            path: expectedState.path,
            imports: any(named: 'imports'),
          ),
        ).called(1);

        final relativeState = p
            .relative(expectedState.path, from: p.dirname(barrelPath))
            .replaceAll(r'\', '/');
        verify(
          () => mockExportService.inject(
            barrelPath: barrelPath,
            exportLines: ["export '$relativeState';"],
            checkpoint: '// logic',
          ),
        ).called(1);

        // Verify logic creation, import resolution, & export
        verify(
          () => mockFileService.writeAsString(
            path: expectedLogic.path,
            content: expectedLogic.content,
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedLogic.path),
        ).called(1);
        verify(
          () => mockImportResolverService.resolve(
            rawTypes: expectedLogic.typesToImport,
            targetFilePath: expectedLogic.path,
            modulePath: sampleLogicParam.modulePath,
          ),
        ).called(1);

        final relativeLogic = p
            .relative(expectedLogic.path, from: p.dirname(barrelPath))
            .replaceAll(r'\', '/');
        verify(
          () => mockExportService.inject(
            barrelPath: barrelPath,
            exportLines: ["export '$relativeLogic';"],
            checkpoint: '// logic',
          ),
        ).called(1);
        verify(() => mockReportService.addInjected(barrelPath)).called(2);
      },
    );

    test(
      'GIVEN state file already exists '
      'WHEN generate is called '
      'THEN skips state file creation and generates only the logic file',
      () async {
        // Given
        final progressLogs = <String>[];
        final expectedState = StateTemplate.build(sampleLogicParam);
        final expectedLogic = LogicTemplate.build(sampleLogicParam);

        when(
          () => mockFileService.exists(expectedState.path),
        ).thenAnswer((_) async => true);

        // When
        await logicService.generate(
          logic: sampleLogicParam,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Creating logic file, resolve import and export to feature barrel...',
        ]);
        verifyNever(
          () => mockFileService.writeAsString(
            path: expectedState.path,
            content: any(named: 'content'),
          ),
        );
        verifyNever(() => mockReportService.addCreated(expectedState.path));
        verify(
          () => mockFileService.writeAsString(
            path: expectedLogic.path,
            content: expectedLogic.content,
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedLogic.path),
        ).called(1);
      },
    );

    test('GIVEN LogicParam with empty props (empty typesToImport) '
        'WHEN generate is called '
        'THEN skips import resolution and import injection', () async {
      // Given
      const emptyPropsLogic = LogicParam(
        props: [],
        control: StateControl.cubit,
        featureName: 'task',
        moduleName: 'project_management',
        sliceName: 'empty_slice',
        workspaceName: 'my_workspace',
        workspacePath: workspacePath,
      );
      final expectedState = StateTemplate.build(emptyPropsLogic);

      when(
        () => mockFileService.exists(expectedState.path),
      ).thenAnswer((_) async => false);
      // When
      await logicService.generate(logic: emptyPropsLogic, onProgress: (_) {});
      // Then
      verifyNever(
        () => mockImportResolverService.resolve(
          rawTypes: any(named: 'rawTypes'),
          targetFilePath: any(named: 'targetFilePath'),
          modulePath: any(named: 'modulePath'),
        ),
      );
      verifyNever(
        () => mockImportService.injectImport(
          path: any(named: 'path'),
          imports: any(named: 'imports'),
        ),
      );
    });
  });
  group('LogicService.generateFlow', () {
    test(
      'GIVEN state flow file does not exist '
      'WHEN generateFlow is called '
      'THEN inspects use case metadata, creates both state flow and logic flow files, resolves imports, injects exports, and reports progress',
      () async {
        // Given
        final progressLogs = [];
        final expectedState = StateFlowTemplate.build(
          logic: sampleLogicFlowParam,
          uc: inspectedUc,
        );
        final expectedLogic = LogicTemplate.buildFlow(
          logic: sampleLogicFlowParam,
          uc: inspectedUc,
        );
        final barrelPath = sampleLogicFlowParam.featureBarrelPath;
        when(
          () => mockFileService.exists(expectedState.path),
        ).thenAnswer((_) async => false);
        // When
        await logicService.generateFlow(
          logic: sampleLogicFlowParam,
          onProgress: progressLogs.add,
        );
        // Then
        expect(progressLogs, [
          'Inspecting use case metadata...',
          'Creating state file, resolve import and export to feature barrel...',
          'Creating logic file, resolve import and export to feature barrel...',
        ]);
        verify(
          () => mockLogicUcService.inspectUseCase(sampleLogicFlowParam.ucPath),
        ).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: expectedState.path,
            content: expectedState.content,
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedState.path),
        ).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: expectedLogic.path,
            content: expectedLogic.content,
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedLogic.path),
        ).called(1);
        verify(() => mockReportService.addInjected(barrelPath)).called(2);
      },
    );
    test(
      'GIVEN state flow file already exists '
      'WHEN generateFlow is called '
      'THEN inspects use case metadata, skips state flow creation, and generates only logic flow file',
      () async {
        // Given
        final expectedState = StateFlowTemplate.build(
          logic: sampleLogicFlowParam,
          uc: inspectedUc,
        );
        final expectedLogic = LogicTemplate.buildFlow(
          logic: sampleLogicFlowParam,
          uc: inspectedUc,
        );
        when(
          () => mockFileService.exists(expectedState.path),
        ).thenAnswer((_) async => true);
        // When
        await logicService.generateFlow(
          logic: sampleLogicFlowParam,
          onProgress: (_) {},
        );
        // Then
        verify(
          () => mockLogicUcService.inspectUseCase(sampleLogicFlowParam.ucPath),
        ).called(1);
        verifyNever(
          () => mockFileService.writeAsString(
            path: expectedState.path,
            content: any(named: 'content'),
          ),
        );
        verify(
          () => mockFileService.writeAsString(
            path: expectedLogic.path,
            content: expectedLogic.content,
          ),
        ).called(1);
      },
    );
  });
}
