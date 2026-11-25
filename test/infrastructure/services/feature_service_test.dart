import 'package:fsda_cli/core/extensions/feature_param_x.dart';
import 'package:fsda_cli/core/extensions/module_param_x.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/infrastructure/services/feature_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/templates/feature_template.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repository_template.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockExportService extends Mock implements ExportService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

class MockArbService extends Mock implements ArbService {}

void main() {
  late MockOperationReportService mockReportService;
  late MockExportService mockExportService;
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;
  late MockArbService mockArbService;
  late FeatureService featureService;

  const workspacePath = '/projects/my_workspace';
  const sampleFeature = FeatureParam(
    featureName: 'task',
    moduleName: 'project_management',
    workspaceName: 'my_workspace',
    workspacePath: workspacePath,
  );

  final expectedModulePath = sampleFeature.modulePath;
  final expectedFeaturePath = sampleFeature.featurePath;
  final expectedFeatureBarrelPath = sampleFeature.featureBarrelPath;
  final expectedRepoInterfacePath = sampleFeature.repoInterfacePath;
  final expectedRepoImplPath = sampleFeature.repoImplPath;
  final expectedModuleBarrelPath = p.join(
    expectedModulePath,
    'lib',
    'project_management.dart',
  );
  final arbPaths = [
    p.join(expectedModulePath, 'lib', 'l10n', 'app_en.arb'),
    p.join(expectedModulePath, 'lib', 'l10n', 'app_id.arb'),
  ];

  setUp(() {
    mockReportService = MockOperationReportService();
    mockExportService = MockExportService();
    mockDirectoryService = MockDirectoryService();
    mockFileService = MockFileService();
    mockArbService = MockArbService();

    featureService = FeatureService(
      reportService: mockReportService,
      exportService: mockExportService,
      directoryService: mockDirectoryService,
      fileService: mockFileService,
      arbService: mockArbService,
    );

    when(() => mockDirectoryService.create(any())).thenAnswer((_) async {});
    when(() => mockDirectoryService.delete(any())).thenAnswer((_) async {});
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
      () => mockArbService.injectBySnippet(
        arbPath: any(named: 'arbPath'),
        arbSnippet: any(named: 'arbSnippet'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockArbService.unjectBetweenKeys(
        arbPath: any(named: 'arbPath'),
        startKey: any(named: 'startKey'),
        endKey: any(named: 'endKey'),
      ),
    ).thenAnswer((_) async {});
  });

  group('FeatureService.generateFeature', () {
    test(
      'GIVEN valid FeatureParam '
      'WHEN generateFeature is called '
      'THEN creates feature directories, barrel, repository files, injects exports and ARB snippets, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];
        final expectedSubDirs = [
          p.join('data', 'converters'),
          p.join('data', 'datasources'),
          p.join('data', 'dtos'),
          p.join('data', 'repositories'),
          p.join('data', 'requests'),
          p.join('data', 'responses'),
          p.join('domain', 'entities'),
          p.join('domain', 'enums'),
          p.join('domain', 'params'),
          p.join('domain', 'repositories'),
          p.join('domain', 'usecases'),
          'logic',
          'ui',
        ];

        // When
        await featureService.generate(
          feature: sampleFeature,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Creating feature directory...',
          'Creating feature folder structure...',
          'Creating feature barrel file...',
          'Creating repository interface and export to feature barrel...',
          'Creating repository impl and export to feature barrel...',
          'Injecting export feature to module barrel...',
          'Injecting initial arb template for feature...',
        ]);

        // 1. Verify root & sub-directory creation (1 + 13 = 14)
        verify(
          () => mockDirectoryService.create(expectedFeaturePath),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedFeaturePath),
        ).called(1);

        for (final sub in expectedSubDirs) {
          final subPath = p.join(expectedFeaturePath, sub);
          verify(() => mockDirectoryService.create(subPath)).called(1);
          verify(() => mockReportService.addCreated(subPath)).called(1);
        }

        // 2. Verify feature barrel creation
        verify(
          () => mockFileService.writeAsString(
            path: expectedFeatureBarrelPath,
            content: FeatureTemplate.initialBarrelContent(),
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedFeatureBarrelPath),
        ).called(1);

        // 3. Verify repository interface & export
        verify(
          () => mockFileService.writeAsString(
            path: expectedRepoInterfacePath,
            content: RepositoryTemplate.interfaceClass('task'),
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedRepoInterfacePath),
        ).called(1);
        verify(
          () => mockExportService.inject(
            barrelPath: expectedFeatureBarrelPath,
            exportLines: ["export 'domain/repositories/task_repository.dart';"],
            checkpoint: '// domain',
          ),
        ).called(1);

        // 4. Verify repository impl & export
        verify(
          () => mockFileService.writeAsString(
            path: expectedRepoImplPath,
            content: RepositoryTemplate.implClass('task'),
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedRepoImplPath),
        ).called(1);
        verify(
          () => mockExportService.inject(
            barrelPath: expectedFeatureBarrelPath,
            exportLines: [
              "export 'data/repositories/task_repository_impl.dart';",
            ],
            checkpoint: '// data',
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(expectedFeatureBarrelPath),
        ).called(2);

        // 5. Verify module barrel export injection
        verify(
          () => mockExportService.inject(
            barrelPath: expectedModuleBarrelPath,
            exportLines: ["export 'src/features/task/task_feature.dart';"],
            checkpoint: '// task',
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(expectedModuleBarrelPath),
        ).called(1);

        // 6. Verify ARB snippet injection
        final expectedArbSnippet = FeatureTemplate.buildArbSnippet('task');
        for (final arbPath in arbPaths) {
          verify(
            () => mockArbService.injectBySnippet(
              arbPath: arbPath,
              arbSnippet: expectedArbSnippet,
            ),
          ).called(1);
          verify(() => mockReportService.addInjected(arbPath)).called(1);
        }
      },
    );
  });

  group('FeatureService.removeFeature', () {
    test(
      'GIVEN existing feature directory and module barrel file '
      'WHEN removeFeature is called '
      'THEN deletes feature directory, unjects module barrel export, removes ARB entries between dividers, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];
        when(
          () => mockFileService.exists(expectedModuleBarrelPath),
        ).thenAnswer((_) async => true);

        // When
        await featureService.feature(
          feature: sampleFeature,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Removing feature "task" directory...',
          'Unject export feature from module barrel...',
          'Unjecting ARB entries for feature "task"...',
        ]);

        verify(
          () => mockDirectoryService.delete(expectedFeaturePath),
        ).called(1);
        verify(
          () => mockReportService.addRemoved(expectedFeaturePath),
        ).called(1);

        verify(
          () => mockExportService.unject(
            barrelPath: expectedModuleBarrelPath,
            exportLines: ["export 'src/features/task/task_feature.dart';"],
          ),
        ).called(1);
        verify(
          () => mockReportService.addUnjected(expectedModuleBarrelPath),
        ).called(1);
        for (final arbPath in arbPaths) {
          verify(
            () => mockArbService.unjectBetweenKeys(
              arbPath: arbPath,
              startKey: '@${FeatureTemplate.startDividerArbKey('task')}',
              endKey: '@${FeatureTemplate.endDividerArbKey('task')}',
            ),
          ).called(1);
          verify(() => mockReportService.addUnjected(arbPath)).called(1);
        }
      },
    );
    test(
      'GIVEN module barrel file does not exist '
      'WHEN removeFeature is called '
      'THEN deletes feature directory and unjects ARB entries without calling exportService.unject',
      () async {
        // Given
        when(
          () => mockFileService.exists(expectedModuleBarrelPath),
        ).thenAnswer((_) async => false);
        // When
        await featureService.feature(
          feature: sampleFeature,
          onProgress: (_) {},
        );
        // Then
        verify(
          () => mockDirectoryService.delete(expectedFeaturePath),
        ).called(1);
        verifyNever(
          () => mockExportService.unject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
          ),
        );
        verifyNever(
          () => mockReportService.addUnjected(expectedModuleBarrelPath),
        );
      },
    );
  });
}
