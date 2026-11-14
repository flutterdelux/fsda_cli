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
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/logic_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockFileService extends Mock implements FileService {}

class MockImportService extends Mock implements ImportService {}

class MockImportResolverService extends Mock implements ImportResolverService {}

class MockExportService extends Mock implements ExportService {}

void main() {
  late LogicService logicService;
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockImportService mockImportService;
  late MockImportResolverService mockImportResolverService;
  late MockExportService mockExportService;

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockImportService = MockImportService();
    mockImportResolverService = MockImportResolverService();
    mockExportService = MockExportService();

    logicService = LogicService(
      reportService: mockReportService,
      fileService: mockFileService,
      importService: mockImportService,
      importResolverService: mockImportResolverService,
      exportService: mockExportService,
    );
  });

  group('LogicService Tests', () {
    void setupCommonMocks() {
      when(() => mockFileService.exists(any())).thenAnswer((_) async => false);
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
      ).thenAnswer((_) async => {"import 'package:auth/auth.dart';"});
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
      when(() => mockReportService.addCreated(any())).thenReturn(null);
      when(() => mockReportService.addInjected(any())).thenReturn(null);
    }

    test(
      'generate should execute successfully when state file does not exist',
      () async {
        const logicParam = LogicParam(
          moduleName: 'auth',
          modulePath: '/modules/auth',
          featureName: 'auth',
          featurePath: '/modules/auth/lib/src/features/auth',
          slice: 'logic',
          props: [
            PropModel(
              type: 'SignInParam?',
              name: 'param',
              defaultValue: "",
              converter: '',
            ),
          ],
        );

        setupCommonMocks();

        final progressLogs = <String>[];
        await logicService.generate(
          logic: logicParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        verify(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).called(2);
      },
    );

    test(
      'generateFlow should execute successfully when state file does not exist',
      () async {
        const logicFlowParam = LogicFlowParam(
          type: LogicFlowType.mutation,
          uc: LogicUcModel(
            name: 'LoginUseCase',
            path: '/usecase.dart',
            type: UcType.paramUc,
            method: 'login',
          ),
          control: StateControl.cubit,
          featureName: 'auth',
          featurePath: '/modules/auth/lib/src/features/auth',
          moduleName: 'auth',
          modulePath: '/modules/auth',
          slice: 'logic_flow',
        );

        setupCommonMocks();

        final progressLogs = <String>[];
        await logicService.generateFlow(
          logic: logicFlowParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        verify(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).called(2);
      },
    );
  });
}
