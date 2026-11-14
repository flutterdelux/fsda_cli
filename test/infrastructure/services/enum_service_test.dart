import 'package:fsda_cli/domain/params/enum_param.dart';
import 'package:fsda_cli/infrastructure/services/enum_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockExportService extends Mock implements ExportService {}

class MockArbService extends Mock implements ArbService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

void main() {
  late EnumService enumService;
  late MockOperationReportService mockReportService;
  late MockExportService mockExportService;
  late MockArbService mockArbService;
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;

  setUp(() {
    mockReportService = MockOperationReportService();
    mockExportService = MockExportService();
    mockArbService = MockArbService();
    mockDirectoryService = MockDirectoryService();
    mockFileService = MockFileService();

    enumService = EnumService(
      reportService: mockReportService,
      exportService: mockExportService,
      arbService: mockArbService,
      directoryService: mockDirectoryService,
      fileService: mockFileService,
    );
  });

  group('EnumService Tests', () {
    const enumParam = EnumParam(
      name: 'status',
      path: '/modules/auth/lib/src/features/auth/domain/enums/status.dart',
      values: ['active', 'inactive'],
      moduleName: 'auth',
      modulePath: '/modules/auth',
      featureName: 'auth',
      featurePath: '/modules/auth/lib/src/features/auth',
      isLower: false,
    );

    test(
      'generateEnum should execute full generation pipeline successfully',
      () async {
        when(() => mockDirectoryService.create(any())).thenAnswer((_) async {});
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
        ).thenAnswer((_) async => ['/project/lib/l10n/app_en.arb']);
        when(
          () => mockArbService.injectEntriesBeforeKey(
            arbPath: any(named: 'arbPath'),
            arbEntries: any(named: 'arbEntries'),
            endKey: any(named: 'endKey'),
          ),
        ).thenAnswer((_) async => {});

        when(() => mockReportService.addCreated(any())).thenReturn(null);
        when(() => mockReportService.addInjected(any())).thenReturn(null);

        final progressLogs = <String>[];

        await enumService.generateEnum(
          enumParam: enumParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        expect(progressLogs.first, contains('Creating enum file'));

        verify(() => mockDirectoryService.create(any())).called(3);
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
        verify(() => mockArbService.getArbPaths(any())).called(1);
        verify(
          () => mockArbService.injectEntriesBeforeKey(
            arbPath: any(named: 'arbPath'),
            arbEntries: any(named: 'arbEntries'),
            endKey: any(named: 'endKey'),
          ),
        ).called(1);
      },
    );

    test(
      'removeEnum should execute full removal pipeline successfully',
      () async {
        when(() => mockFileService.delete(any())).thenAnswer((_) async => {});
        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);
        when(
          () => mockExportService.unject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockArbService.getArbPaths(any()),
        ).thenAnswer((_) async => ['/project/lib/l10n/app_en.arb']);
        when(
          () => mockArbService.unjectEntries(
            arbPath: any(named: 'arbPath'),
            arbEntries: any(named: 'arbEntries'),
          ),
        ).thenAnswer((_) async => {});

        when(() => mockReportService.addRemoved(any())).thenReturn(null);
        when(() => mockReportService.addUnjected(any())).thenReturn(null);

        final progressLogs = <String>[];

        await enumService.removeEnum(
          enumParam: enumParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        expect(progressLogs.first, contains('Removing enum file'));

        verify(() => mockFileService.delete(any())).called(3);
        verify(() => mockFileService.exists(any())).called(4);
        verify(
          () => mockExportService.unject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
          ),
        ).called(2);
        verify(() => mockArbService.getArbPaths(any())).called(1);
        verify(
          () => mockArbService.unjectEntries(
            arbPath: any(named: 'arbPath'),
            arbEntries: any(named: 'arbEntries'),
          ),
        ).called(1);
      },
    );

    test(
      'getValuesFromEnumFile should return empty list if file does not exist',
      () async {
        when(
          () => mockFileService.exists(any()),
        ).thenAnswer((_) async => false);

        final values = await enumService.getValuesFromEnumFile(
          '/path/to/enum.dart',
        );

        expect(values, isEmpty);
        verify(() => mockFileService.exists(any())).called(1);
      },
    );

    test(
      'getValuesFromEnumFile should parse enum constants correctly and convert camelCase to snake_case',
      () async {
        const enumContent = '''
enum Status {
  active,
  inProgress,
  completedTask,
}
''';

        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(any()),
        ).thenAnswer((_) async => enumContent);

        final values = await enumService.getValuesFromEnumFile(
          '/path/to/enum.dart',
        );

        expect(values, ['active', 'in_progress', 'completed_task']);
        verify(() => mockFileService.exists(any())).called(1);
        verify(() => mockFileService.readAsString(any())).called(1);
      },
    );
  });
}
