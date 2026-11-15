import 'package:fsda_cli/core/extensions/feature_gate_param_x.dart';
import 'package:fsda_cli/domain/enums/input_type.dart';
import 'package:fsda_cli/domain/models/form_field_model.dart';
import 'package:fsda_cli/domain/params/ui/ui_form_param.dart';
import 'package:fsda_cli/domain/params/ui/ui_lsh_param.dart';
import 'package:fsda_cli/domain/params/ui/ui_lsv_param.dart';
import 'package:fsda_cli/domain/params/ui/ui_pag_param.dart';
import 'package:fsda_cli/domain/params/ui/ui_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_finder_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_resolver_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/ui_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockFileService extends Mock implements FileService {}

class MockArbService extends Mock implements ArbService {}

class MockFileFinderService extends Mock implements FileFinderService {}

class MockImportResolverService extends Mock implements ImportResolverService {}

class MockImportService extends Mock implements ImportService {}

class MockExportService extends Mock implements ExportService {}

void main() {
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockArbService mockArbService;
  late MockFileFinderService mockFileFinderService;
  late MockImportResolverService mockImportResolverService;
  late MockImportService mockImportService;
  late MockExportService mockExportService;
  late UiService uiService;

  const tModulePath = '/workspace/modules/todo';
  const tFeaturePath = '/workspace/modules/todo/lib/src/features/task';

  void setupDefaultStubs() {
    when(
      () => mockFileFinderService.findFile(
        rawRef: any(named: 'rawRef'),
        modulePath: any(named: 'modulePath'),
      ),
    ).thenAnswer((_) async => '$tFeaturePath/data/dtos/task_dto.dart');

    when(() => mockFileService.exists(any())).thenAnswer((_) async => true);
    when(() => mockFileService.readAsString(any())).thenAnswer(
      (_) async => 'class TaskDto { final String? id; TaskDto({this.id}); }',
    );

    when(
      () => mockFileService.writeAsString(
        path: any(named: 'path'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockReportService.addCreated(any())).thenReturn(null);
    when(() => mockReportService.addInjected(any())).thenReturn(null);

    when(
      () => mockImportResolverService.resolve(
        rawTypes: any(named: 'rawTypes'),
        targetFilePath: any(named: 'targetFilePath'),
        modulePath: any(named: 'modulePath'),
      ),
    ).thenAnswer((_) async => {'import "some_path.dart";'});

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
      () => mockArbService.getArbPaths(any()),
    ).thenAnswer((_) async => ['$tModulePath/lib/src/l10n/app_en.arb']);

    when(
      () => mockArbService.injectEntriesBeforeKey(
        arbPath: any(named: 'arbPath'),
        endKey: any(named: 'endKey'),
        arbEntries: any(named: 'arbEntries'),
      ),
    ).thenAnswer((_) async {});
  }

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockArbService = MockArbService();
    mockFileFinderService = MockFileFinderService();
    mockImportResolverService = MockImportResolverService();
    mockImportService = MockImportService();
    mockExportService = MockExportService();

    uiService = UiService(
      reportService: mockReportService,
      fileService: mockFileService,
      arbService: mockArbService,
      fileFinderService: mockFileFinderService,
      importResolverService: mockImportResolverService,
      importService: mockImportService,
      exportService: mockExportService,
    );

    setupDefaultStubs();
  });

  group('UiService - generate', () {
    const tUiParam = UiParam(
      moduleName: 'todo',
      modulePath: tModulePath,
      featureName: 'task',
      featurePath: tFeaturePath,
      slice: 'task_view',
      model: 'TaskDto',
    );

    test(
      'Given a valid UiParam, '
      'When generate is called, '
      'Then it inspects props, generates widget variants, injects exports, and adds ARB entries',
      () async {
        // Arrange (Given)
        final progressLogs = <String>[];

        // Act (When)
        await uiService.generate(
          ui: tUiParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        // Assert (Then)
        expect(progressLogs, contains('Inspecting model props...'));
        expect(progressLogs, contains('Generating widget variants...'));
        expect(progressLogs, contains('Injecting export widget variants...'));
        expect(progressLogs, contains('Injecting localization entries...'));

        verify(
          () => mockExportService.inject(
            barrelPath: tUiParam.featureBarrelPath,
            exportLines: any(named: 'exportLines'),
            checkpoint: '// ui',
          ),
        ).called(1);
        verify(() => mockArbService.getArbPaths(tModulePath)).called(1);
      },
    );
  });

  group('UiService - generateLsv', () {
    const tUiLsvParam = UiLsvParam(
      moduleName: 'todo',
      modulePath: tModulePath,
      featureName: 'task',
      featurePath: tFeaturePath,
      slice: 'task_lsv',
      model: 'TaskDto',
    );

    test(
      'Given a valid UiLsvParam, '
      'When generateLsv is called, '
      'Then it inspects props, generates ListView variants, injects exports, and adds ARB entries',
      () async {
        // Arrange (Given)
        final progressLogs = <String>[];

        // Act (When)
        await uiService.generateLsv(
          ui: tUiLsvParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        // Assert (Then)
        expect(progressLogs, contains('Inspecting model props...'));
        expect(
          progressLogs,
          contains('Generating ListView widget variants...'),
        );
        verify(
          () => mockExportService.inject(
            barrelPath: tUiLsvParam.featureBarrelPath,
            exportLines: any(named: 'exportLines'),
            checkpoint: '// ui',
          ),
        ).called(1);
      },
    );
  });

  group('UiService - generateLsh', () {
    const tUiLshParam = UiLshParam(
      moduleName: 'todo',
      modulePath: tModulePath,
      featureName: 'task',
      featurePath: tFeaturePath,
      slice: 'task_lsh',
      model: 'TaskDto',
    );

    test(
      'Given a valid UiLshParam, '
      'When generateLsh is called, '
      'Then it inspects props, generates Horizontal ListView variants, injects exports, and adds ARB entries',
      () async {
        // Arrange (Given)
        final progressLogs = <String>[];

        // Act (When)
        await uiService.generateLsh(
          ui: tUiLshParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        // Assert (Then)
        expect(progressLogs, contains('Inspecting model props...'));
        expect(
          progressLogs,
          contains('Generating Horizontal ListView widget variants...'),
        );
        verify(
          () => mockExportService.inject(
            barrelPath: tUiLshParam.featureBarrelPath,
            exportLines: any(named: 'exportLines'),
            checkpoint: '// ui',
          ),
        ).called(1);
      },
    );
  });

  group('UiService - generatePag', () {
    const tUiPagParam = UiPagParam(
      moduleName: 'todo',
      modulePath: tModulePath,
      featureName: 'task',
      featurePath: tFeaturePath,
      slice: 'task_pag',
      model: 'TaskDto',
    );

    test(
      'Given a valid UiPagParam, '
      'When generatePag is called, '
      'Then it inspects props, generates Paginated ListView variants, injects exports, and adds ARB entries',
      () async {
        // Arrange (Given)
        final progressLogs = <String>[];

        // Act (When)
        await uiService.generatePag(
          ui: tUiPagParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        // Assert (Then)
        expect(progressLogs, contains('Inspecting model props...'));
        expect(
          progressLogs,
          contains('Generating Paginated ListView widget variants...'),
        );
        verify(
          () => mockExportService.inject(
            barrelPath: tUiPagParam.featureBarrelPath,
            exportLines: any(named: 'exportLines'),
            checkpoint: '// ui',
          ),
        ).called(1);
      },
    );
  });

  group('UiService - generateForm', () {
    const tUiFormParam = UiFormParam(
      moduleName: 'todo',
      modulePath: tModulePath,
      featureName: 'task',
      featurePath: tFeaturePath,
      slice: 'task_form',
      model: 'TaskDto',
      fields: [
        FormFieldModel(
          inputType: InputType.text,
          valueType: 'String',
          fieldName: 'title',
        ),
      ],
    );

    test(
      'Given a valid UiFormParam, '
      'When generateForm is called, '
      'Then it inspects props, generates UI Form widget, injects exports, and adds ARB entries',
      () async {
        // Arrange (Given)
        final progressLogs = <String>[];

        // Act (When)
        await uiService.generateForm(
          ui: tUiFormParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        // Assert (Then)
        expect(progressLogs, contains('Inspecting model props...'));
        expect(progressLogs, contains('Generating UI Form widget...'));
        verify(
          () => mockExportService.inject(
            barrelPath: tUiFormParam.featureBarrelPath,
            exportLines: any(named: 'exportLines'),
            checkpoint: '// ui',
          ),
        ).called(1);
      },
    );
  });
}
