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
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockArbService mockArbService;
  late MockExportService mockExportService;
  late MockMethodService mockMethodService;
  late MockImportService mockImportService;
  late MockImportResolverService mockImportResolverService;
  late SequenceService sequenceService;

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

  group('SequenceService', () {
    const tSequenceParam = SequenceParam(
      action: Action.post,
      usecase: 'create_task',
      usecasePath:
          '/workspace/modules/todo/lib/src/features/task/domain/usecases/create_task_usecase.dart',
      method: 'createTask',
      flow: FlowType.asynchronous,
      dsMode: DsMode.remote,
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
    );

    group('generate', () {
      test(
        'Given valid SequenceParam with remote ds mode, '
        'When generate is called, '
        'Then it executes all datasource, repository, usecase injections and reports progress successfully',
        () async {
          // Arrange (Given)
          final progressLogs = <String>[];

          when(
            () => mockMethodService.injectToClass(
              path: any(named: 'path'),
              methodCode: any(named: 'methodCode'),
            ),
          ).thenAnswer((_) async {});

          when(() => mockReportService.addInjected(any())).thenReturn(null);
          when(() => mockReportService.addCreated(any())).thenReturn(null);

          when(
            () => mockImportResolverService.resolve(
              rawTypes: any(named: 'rawTypes'),
              targetFilePath: any(named: 'targetFilePath'),
              modulePath: any(named: 'modulePath'),
            ),
          ).thenAnswer((_) async => {'import "some_import.dart";'});

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

          when(
            () => mockExportService.inject(
              barrelPath: any(named: 'barrelPath'),
              exportLines: any(named: 'exportLines'),
              checkpoint: any(named: 'checkpoint'),
            ),
          ).thenAnswer((_) async {});

          when(() => mockArbService.getArbPaths(any())).thenAnswer(
            (_) async => ['/workspace/modules/todo/lib/src/l10n/app_en.arb'],
          );

          when(
            () => mockArbService.injectEntriesBeforeKey(
              arbPath: any(named: 'arbPath'),
              arbEntries: any(named: 'arbEntries'),
              endKey: any(named: 'endKey'),
            ),
          ).thenAnswer((_) async {});

          // Act (When)
          await sequenceService.generate(
            sequence: tSequenceParam,
            onProgress: (msg) => progressLogs.add(msg),
          );

          // Assert (Then)
          expect(
            progressLogs,
            contains('Injecting method to datasource interface...'),
          );
          expect(
            progressLogs,
            contains('Injecting method to datasource implementation...'),
          );
          expect(
            progressLogs,
            contains(
              'Creating use case and injecting export to feature barrel...',
            ),
          );
          expect(progressLogs, contains('Injecting use case localization...'));

          verify(
            () => mockMethodService.injectToClass(
              path: any(named: 'path'),
              methodCode: any(named: 'methodCode'),
            ),
          ).called(4); // DS interface, DS impl, Repo interface, Repo impl

          verify(
            () => mockFileService.writeAsString(
              path: tSequenceParam.usecasePath,
              content: any(named: 'content'),
            ),
          ).called(1);

          verify(
            () => mockArbService.getArbPaths(tSequenceParam.modulePath),
          ).called(1);
        },
      );
    });

    group('remove', () {
      test(
        'Given valid SequenceParam for removal, '
        'When remove is called, '
        'Then it unjects methods from classes, removes usecase file, and cleans up arb entries',
        () async {
          // Arrange (Given)
          final progressLogs = <String>[];

          when(
            () => mockMethodService.unjectFromClass(
              path: any(named: 'path'),
              methodName: any(named: 'methodName'),
            ),
          ).thenAnswer((_) async {});

          when(() => mockReportService.addUnjected(any())).thenReturn(null);
          when(() => mockReportService.addRemoved(any())).thenReturn(null);

          when(
            () => mockFileService.exists(any()),
          ).thenAnswer((_) async => true);
          when(() => mockFileService.delete(any())).thenAnswer((_) async {});

          when(
            () => mockExportService.unject(
              barrelPath: any(named: 'barrelPath'),
              exportLines: any(named: 'exportLines'),
            ),
          ).thenAnswer((_) async {});

          when(() => mockArbService.getArbPaths(any())).thenAnswer(
            (_) async => ['/workspace/modules/todo/lib/src/l10n/app_en.arb'],
          );

          when(
            () => mockArbService.unjectEntries(
              arbPath: any(named: 'arbPath'),
              arbEntries: any(named: 'arbEntries'),
            ),
          ).thenAnswer((_) async {});

          // Act (When)
          await sequenceService.remove(
            sequence: tSequenceParam,
            onProgress: (msg) => progressLogs.add(msg),
          );

          // Assert (Then)
          expect(
            progressLogs,
            contains('Unjecting method from datasource interface...'),
          );
          expect(
            progressLogs,
            contains('Removing use case file and unjecting barrel export...'),
          );
          expect(progressLogs, contains('Unjecting localization entries...'));

          verify(
            () => mockMethodService.unjectFromClass(
              path: any(named: 'path'),
              methodName: tSequenceParam.method,
            ),
          ).called(4); // DS interface, DS impl, Repo interface, Repo impl

          verify(
            () => mockFileService.delete(tSequenceParam.usecasePath),
          ).called(1);
          verify(
            () => mockReportService.addRemoved(tSequenceParam.usecasePath),
          ).called(1);
          verify(
            () => mockArbService.unjectEntries(
              arbPath: any(named: 'arbPath'),
              arbEntries: any(named: 'arbEntries'),
            ),
          ).called(1);
        },
      );
    });
  });
}
