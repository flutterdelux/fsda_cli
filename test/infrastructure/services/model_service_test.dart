import 'package:fsda_cli/domain/enums/model_type.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/model_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_resolver_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/model_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockExportService extends Mock implements ExportService {}

class MockArbService extends Mock implements ArbService {}

class MockFileService extends Mock implements FileService {}

class MockImportResolverService extends Mock implements ImportResolverService {}

class MockImportService extends Mock implements ImportService {}

void main() {
  late ModelService modelService;
  late MockOperationReportService mockReportService;
  late MockExportService mockExportService;
  late MockArbService mockArbService;
  late MockFileService mockFileService;
  late MockImportResolverService mockImportResolverService;
  late MockImportService mockImportService;

  setUp(() {
    mockReportService = MockOperationReportService();
    mockExportService = MockExportService();
    mockArbService = MockArbService();
    mockFileService = MockFileService();
    mockImportResolverService = MockImportResolverService();
    mockImportService = MockImportService();

    modelService = ModelService(
      reportService: mockReportService,
      exportService: mockExportService,
      arbService: mockArbService,
      fileService: mockFileService,
      importResolverService: mockImportResolverService,
      importService: mockImportService,
    );
  });

  group('ModelService Tests', () {
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
      when(() => mockFileService.exists(any())).thenAnswer((_) async => true);
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
    }

    test(
      'generateModel and removeModel cover all ModelTypes and helpers',
      () async {
        setupCommonMocks();

        for (final type in ModelType.values) {
          final param = ModelParam(
            moduleName: 'auth',
            modulePath: '/modules/auth',
            featureName: 'auth',
            featurePath: '/modules/auth/lib/src/features/auth',
            name: 'TestModel',
            path: '/modules/auth/lib/src/features/auth/model.dart',
            type: type,
            isInjectL10n: true,
            props: const [
              PropModel(
                type: 'String',
                name: 'id',
                defaultValue: "''",
                converter: '',
              ),
            ],
          );

          final logs = <String>[];
          await modelService.generateModel(
            model: param,
            onProgress: (msg) => logs.add(msg),
          );
          await modelService.removeModel(
            model: param,
            onProgress: (msg) => logs.add(msg),
          );
          expect(logs, isNotEmpty);
        }
      },
    );

    test(
      'getPropsFromModelFile parses constructor parameters correctly via AST visitor',
      () async {
        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);
        when(() => mockFileService.readAsString(any())).thenAnswer(
          (_) async => '''
class User {
  const User({required String emailAddress, int? age});
}
''',
        );

        final props = await modelService.getPropsFromModelFile(
          '/path/user.dart',
        );
        expect(props, isNotEmpty);
        expect(props.first.name, 'email_address');
      },
    );

    test(
      'getPropsFromModelFile returns empty list on file read error / exception catch block',
      () async {
        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(any()),
        ).thenAnswer((_) async => 'INVALID SYNTAX {{{');

        final props = await modelService.getPropsFromModelFile(
          '/path/invalid.dart',
        );
        expect(props, isEmpty);
      },
    );
  });
}
