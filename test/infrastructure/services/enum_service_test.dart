import 'package:fsda_cli/domain/params/enum_param.dart';
import 'package:fsda_cli/infrastructure/services/enum_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/templates/enum_template.dart';
import 'package:fsda_cli/infrastructure/templates/feature_template.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockExportService extends Mock implements ExportService {}

class MockArbService extends Mock implements ArbService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

void main() {
  late MockOperationReportService mockReportService;
  late MockExportService mockExportService;
  late MockArbService mockArbService;
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;
  late EnumService enumService;

  const workspacePath = '/projects/my_workspace';
  const sampleEnumParam = EnumParam(
    enumName: 'task_status',
    values: ['todo', 'in_progress', 'done'],
    isLower: true,
    featureName: 'task',
    moduleName: 'project_management',
    workspaceName: 'my_workspace',
    workspacePath: workspacePath,
  );

  final expectedModulePath = p.join(
    workspacePath,
    'modules',
    'project_management',
  );
  final expectedFeaturePath = p.join(
    expectedModulePath,
    'lib',
    'src',
    'features',
    'task',
  );
  final expectedBarrelPath = p.join(expectedFeaturePath, 'task_feature.dart');
  final expectedEnumPath = p.join(
    expectedFeaturePath,
    'domain',
    'enums',
    'task_status.dart',
  );
  final expectedConverterPath = p.join(
    expectedFeaturePath,
    'data',
    'converters',
    'task_status_converter.dart',
  );
  final expectedExtensionPath = p.join(
    expectedFeaturePath,
    'ui',
    'shared',
    'extensions',
    'task_status_x.dart',
  );
  final arbPaths = [
    p.join(expectedModulePath, 'lib', 'l10n', 'app_en.arb'),
    p.join(expectedModulePath, 'lib', 'l10n', 'app_id.arb'),
  ];

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

    when(() => mockDirectoryService.create(any())).thenAnswer((_) async {});
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

  group('EnumService.generate', () {
    test(
      'GIVEN valid EnumParam '
      'WHEN generate is called '
      'THEN creates enum, converter, extension files, injects barrel exports and ARB entries, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];
        final expectedArbEntries = EnumTemplate.buildArbEntries(
          sampleEnumParam,
        );
        final expectedEndKey = FeatureTemplate.endDividerArbKey('task');

        // When
        await enumService.generate(
          enumParam: sampleEnumParam,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Creating enum file...',
          'Injecting export enum file...',
          'Creating enum converter file...',
          'Creating enum extension file...',
          'Injecting export enum extension file...',
          'Injecting localization keys into ARB files...',
        ]);

        // Verify enum file creation
        verify(
          () => mockDirectoryService.create(p.dirname(expectedEnumPath)),
        ).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: expectedEnumPath,
            content: EnumTemplate.buildEnum(sampleEnumParam),
          ),
        ).called(1);
        verify(() => mockReportService.addCreated(expectedEnumPath)).called(1);

        // Verify converter file creation
        verify(
          () => mockDirectoryService.create(p.dirname(expectedConverterPath)),
        ).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: expectedConverterPath,
            content: EnumTemplate.buildConverter(sampleEnumParam),
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedConverterPath),
        ).called(1);

        // Verify extension file creation
        verify(
          () => mockDirectoryService.create(p.dirname(expectedExtensionPath)),
        ).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: expectedExtensionPath,
            content: EnumTemplate.buildExtension(sampleEnumParam),
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedExtensionPath),
        ).called(1);

        // Verify barrel exports
        verify(
          () => mockExportService.inject(
            barrelPath: expectedBarrelPath,
            exportLines: ["export 'domain/enums/task_status.dart';"],
            checkpoint: '// domain',
          ),
        ).called(1);
        verify(
          () => mockExportService.inject(
            barrelPath: expectedBarrelPath,
            exportLines: ["export 'ui/shared/extensions/task_status_x.dart';"],
            checkpoint: '// ui',
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(expectedBarrelPath),
        ).called(2);

        // Verify ARB injections
        for (final arbPath in arbPaths) {
          verify(
            () => mockArbService.injectEntriesBeforeKey(
              arbPath: arbPath,
              arbEntries: expectedArbEntries,
              endKey: expectedEndKey,
            ),
          ).called(1);
          verify(() => mockReportService.addInjected(arbPath)).called(1);
        }
      },
    );
  });

  group('EnumService.removeEnum', () {
    test(
      'GIVEN all generated enum artifacts and barrel file exist '
      'WHEN removeEnum is called '
      'THEN deletes files, unjects barrel exports and ARB entries, and reports removals',
      () async {
        // Given
        final progressLogs = <String>[];
        final expectedArbEntries = EnumTemplate.buildArbEntries(
          sampleEnumParam,
        );

        when(
          () => mockFileService.exists(expectedBarrelPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.exists(expectedConverterPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.exists(expectedExtensionPath),
        ).thenAnswer((_) async => true);

        // When
        await enumService.remove(
          enumParam: sampleEnumParam,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Removing enum file...',
          'Unjecting export enum from feature barrel...',
          'Removing enum converter file...',
          'Removing enum extension file...',
          'Unjecting export enum extension from feature barrel...',
          'Unjecting localization keys from ARB files...',
        ]);

        verify(() => mockFileService.delete(expectedEnumPath)).called(1);
        verify(() => mockReportService.addRemoved(expectedEnumPath)).called(1);

        verify(() => mockFileService.delete(expectedConverterPath)).called(1);
        verify(
          () => mockReportService.addRemoved(expectedConverterPath),
        ).called(1);

        verify(() => mockFileService.delete(expectedExtensionPath)).called(1);
        verify(
          () => mockReportService.addRemoved(expectedExtensionPath),
        ).called(1);

        verify(
          () => mockExportService.unject(
            barrelPath: expectedBarrelPath,
            exportLines: ["export 'domain/enums/task_status.dart';"],
          ),
        ).called(1);
        verify(
          () => mockExportService.unject(
            barrelPath: expectedBarrelPath,
            exportLines: ["export 'ui/shared/extensions/task_status_x.dart';"],
          ),
        ).called(1);
        verify(
          () => mockReportService.addUnjected(expectedBarrelPath),
        ).called(2);

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
      'GIVEN barrel, converter, and extension files do not exist '
      'WHEN removeEnum is called '
      'THEN deletes primary enum file and skips optional file deletions and barrel unjections',
      () async {
        // Given
        when(
          () => mockFileService.exists(expectedBarrelPath),
        ).thenAnswer((_) async => false);
        when(
          () => mockFileService.exists(expectedConverterPath),
        ).thenAnswer((_) async => false);
        when(
          () => mockFileService.exists(expectedExtensionPath),
        ).thenAnswer((_) async => false);
        // When
        await enumService.remove(
          enumParam: sampleEnumParam,
          onProgress: (_) {},
        );
        // Then
        verify(() => mockFileService.delete(expectedEnumPath)).called(1);
        verifyNever(() => mockFileService.delete(expectedConverterPath));
        verifyNever(() => mockFileService.delete(expectedExtensionPath));
        verifyNever(
          () => mockExportService.unject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
          ),
        );
        verifyNever(() => mockReportService.addUnjected(expectedBarrelPath));
      },
    );
  });
  group('EnumService.getValuesFromEnumFile', () {
    test('GIVEN enum file does not exist '
        'WHEN getValuesFromEnumFile is called '
        'THEN returns empty list', () async {
      // Given
      when(
        () => mockFileService.exists(expectedEnumPath),
      ).thenAnswer((_) async => false);
      // When
      final result = await enumService.getValuesFromEnumFile(expectedEnumPath);
      // Then
      expect(result, isEmpty);
      verifyNever(() => mockFileService.readAsString(any()));
    });
    test(
      'GIVEN valid Dart enum file with camelCase constants '
      'WHEN getValuesFromEnumFile is called '
      'THEN parses AST and converts constants back to snake_case list',
      () async {
        // Given
        const enumSource = '''
enum TaskStatus {
todo,
inProgress,
waitingForReview,
done,
}
''';
        when(
          () => mockFileService.exists(expectedEnumPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(expectedEnumPath),
        ).thenAnswer((_) async => enumSource);
        // When
        final result = await enumService.getValuesFromEnumFile(
          expectedEnumPath,
        );
        // Then
        expect(result, ['todo', 'in_progress', 'waiting_for_review', 'done']);
      },
    );
  });
}
