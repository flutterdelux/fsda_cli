import 'package:fsda_cli/domain/params/ui/ui_form_param.dart';
import 'package:fsda_cli/domain/params/ui/ui_lsh_param.dart';
import 'package:fsda_cli/domain/params/ui/ui_lsv_param.dart';
import 'package:fsda_cli/domain/params/ui/ui_pag_param.dart';
import 'package:fsda_cli/domain/params/ui/ui_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
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

class MockImportResolverService extends Mock implements ImportResolverService {}

class MockImportService extends Mock implements ImportService {}

class MockExportService extends Mock implements ExportService {}

void main() {
  late UiService uiService;
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockArbService mockArbService;
  late MockImportResolverService mockImportResolverService;
  late MockImportService mockImportService;
  late MockExportService mockExportService;

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockArbService = MockArbService();
    mockImportResolverService = MockImportResolverService();
    mockImportService = MockImportService();
    mockExportService = MockExportService();

    uiService = UiService(
      reportService: mockReportService,
      fileService: mockFileService,
      arbService: mockArbService,
      importResolverService: mockImportResolverService,
      importService: mockImportService,
      exportService: mockExportService,
    );
  });

  group('UiService Tests', () {
    const uiParam = UiParam(
      featureName: 'auth',
      featurePath: '/modules/auth/lib/src/features/auth',
      moduleName: 'auth',
      modulePath: '/modules/auth',
      slice: 'auth_ui',
      model: 'content',
    );

    const uiLsvParam = UiLsvParam(
      featureName: 'auth',
      featurePath: '/modules/auth/lib/src/features/auth',
      moduleName: 'auth',
      modulePath: '/modules/auth',
      slice: 'auth_lsv',
      model: 'lsv',
    );

    const uiLshParam = UiLshParam(
      featureName: 'auth',
      featurePath: '/modules/auth/lib/src/features/auth',
      moduleName: 'auth',
      modulePath: '/modules/auth',
      slice: 'auth_lsh',
      model: 'lsh',
    );

    const uiPagParam = UiPagParam(
      featureName: 'auth',
      featurePath: '/modules/auth/lib/src/features/auth',
      moduleName: 'auth',
      modulePath: '/modules/auth',
      slice: 'auth_pag',
      model: 'pag',
    );

    const uiFormParam = UiFormParam(
      featureName: 'auth',
      featurePath: '/modules/auth/lib/src/features/auth',
      moduleName: 'auth',
      modulePath: '/modules/auth',
      slice: 'auth_form',
      model: 'form',
      fields: [],
    );

    void setupCommonMocks() {
      when(
        () => mockFileService.writeAsString(
          path: any(named: 'path'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockImportResolverService.resolve(
          rawTypes: any(named: 'rawTypes'),
          targetFilePath: any(named: 'targetFilePath'),
          featurePath: any(named: 'featurePath'),
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockImportService.injectImport(
          path: any(named: 'path'),
          imports: any(named: 'imports'),
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
        () => mockArbService.getArbPaths(any()),
      ).thenAnswer((_) async => ['/modules/auth/lib/l10n/app_en.arb']);
      when(
        () => mockArbService.injectEntriesBeforeKey(
          arbPath: any(named: 'arbPath'),
          endKey: any(named: 'endKey'),
          arbEntries: any(named: 'arbEntries'),
        ),
      ).thenAnswer((_) async => {});
      when(() => mockReportService.addCreated(any())).thenReturn(null);
      when(() => mockReportService.addInjected(any())).thenReturn(null);
    }

    test('generate should execute successfully', () async {
      setupCommonMocks();
      final logs = <String>[];
      await uiService.generate(ui: uiParam, onProgress: (msg) => logs.add(msg));
      expect(logs, isNotEmpty);
      verify(
        () => mockFileService.writeAsString(
          path: any(named: 'path'),
          content: any(named: 'content'),
        ),
      ).called(greaterThan(0));
    });

    test('generateLsv should execute successfully', () async {
      setupCommonMocks();
      final logs = <String>[];
      await uiService.generateLsv(
        ui: uiLsvParam,
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });

    test('generateLsh should execute successfully', () async {
      setupCommonMocks();
      final logs = <String>[];
      await uiService.generateLsh(
        ui: uiLshParam,
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });

    test('generatePag should execute successfully', () async {
      setupCommonMocks();
      final logs = <String>[];
      await uiService.generatePag(
        ui: uiPagParam,
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });

    test('generateForm should execute successfully', () async {
      setupCommonMocks();
      final logs = <String>[];
      await uiService.generateForm(
        ui: uiFormParam,
        onProgress: (msg) => logs.add(msg),
      );
      expect(logs, isNotEmpty);
    });
  });
}
