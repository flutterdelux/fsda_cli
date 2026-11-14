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
import 'package:mocktail/mocktail.dart';
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
  late SequenceService sequenceService;
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockArbService mockArbService;
  late MockExportService mockExportService;
  late MockMethodService mockMethodService;
  late MockImportService mockImportService;
  late MockImportResolverService mockImportResolverService;

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
  });

  group('SequenceService Tests', () {
    const sequenceParam = SequenceParam(
      action: Action.post,
      usecase: 'LoginUser',
      usecasePath: '/usecase.dart',
      method: 'login',
      featureName: 'auth',
      featurePath: '/modules/auth/lib/src/features/auth',
      moduleName: 'auth',
      modulePath: '/modules/auth',
      flow: FlowType.asynchronous,
      dsMode: DsMode.remote,
    );

    test('generate and remove sequences should execute successfully', () async {
      when(
        () => mockMethodService.injectToClass(
          path: any(named: 'path'),
          methodCode: any(named: 'methodCode'),
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockImportService.injectImport(
          path: any(named: 'path'),
          imports: any(named: 'imports'),
        ),
      ).thenAnswer((_) async => {});
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
        () => mockArbService.getArbPaths(any()),
      ).thenAnswer((_) async => ['/modules/auth/lib/l10n/app_en.arb']);
      when(
        () => mockArbService.injectEntriesBeforeKey(
          arbPath: any(named: 'arbPath'),
          arbEntries: any(named: 'arbEntries'),
          endKey: any(named: 'endKey'),
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockMethodService.unjectFromClass(
          path: any(named: 'path'),
          methodName: any(named: 'methodName'),
        ),
      ).thenAnswer((_) async => {});
      when(() => mockFileService.exists(any())).thenAnswer((_) async => true);
      when(() => mockFileService.delete(any())).thenAnswer((_) async => {});
      when(
        () => mockExportService.unject(
          barrelPath: any(named: 'barrelPath'),
          exportLines: any(named: 'exportLines'),
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockArbService.unjectEntries(
          arbPath: any(named: 'arbPath'),
          arbEntries: any(named: 'arbEntries'),
        ),
      ).thenAnswer((_) async => {});
      when(() => mockReportService.addCreated(any())).thenReturn(null);
      when(() => mockReportService.addInjected(any())).thenReturn(null);
      when(() => mockReportService.addRemoved(any())).thenReturn(null);
      when(() => mockReportService.addUnjected(any())).thenReturn(null);

      final progressLogs = <String>[];
      await sequenceService.generate(
        sequence: sequenceParam,
        onProgress: (msg) => progressLogs.add(msg),
      );
      expect(progressLogs, isNotEmpty);

      final removeLogs = <String>[];
      await sequenceService.remove(
        sequence: sequenceParam,
        onProgress: (msg) => removeLogs.add(msg),
      );
      expect(removeLogs, isNotEmpty);
    });
  });
}
