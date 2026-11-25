import 'package:fsda_cli/core/extensions/app_param_x.dart';
import 'package:fsda_cli/core/extensions/reg_module_param_x.dart';
import 'package:fsda_cli/domain/params/app_integration/reg_module_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/refresh_service.dart';
import 'package:fsda_cli/infrastructure/services/reg_module_service.dart';
import 'package:fsda_cli/infrastructure/templates/app_integration/app_module_di_template.dart';
import 'package:fsda_cli/infrastructure/templates/app_integration/app_module_route_template.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockFileService extends Mock implements FileService {}

class MockImportService extends Mock implements ImportService {}

class MockRefreshService extends Mock implements RefreshService {}

void main() {
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockImportService mockImportService;
  late MockRefreshService mockRefreshService;
  late RegModuleService regModuleService;

  const workspacePath = '/projects/my_workspace';
  const sampleParam = RegModuleParam(
    moduleName: 'project_management',
    appName: 'portal_app',
    workspaceName: 'my_workspace',
    workspacePath: workspacePath,
  );

  final pubspecPath = sampleParam.appPubspecPath;
  final diArtifact = AppModuleDiTemplate.build(sampleParam);
  final routeArtifact = AppModuleRouteTemplate.build(sampleParam);
  final mainAppPath = sampleParam.mainAppPath;
  final failureXPath = sampleParam.failureXPath;
  final appDiPath = sampleParam.appDiPath;
  final appRouterPath = sampleParam.appRouterPath;

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockImportService = MockImportService();
    mockRefreshService = MockRefreshService();

    regModuleService = RegModuleService(
      reportService: mockReportService,
      fileService: mockFileService,
      importService: mockImportService,
      refreshService: mockRefreshService,
    );

    when(
      () => mockFileService.writeAsString(
        path: any(named: 'path'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockImportService.injectImport(
        path: any(named: 'path'),
        imports: any(named: 'imports'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockRefreshService.refresh(
        any(),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async {});
  });

  group('RegModuleService.registerModule', () {
    test(
      'GIVEN valid RegModuleParam and target app files without existing module registration '
      'WHEN registerModule is called '
      'THEN updates pubspec, creates DI/Route wrappers, injects AST across app files, refreshes app, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];

        // All target files exist; wrapper files do not exist yet
        when(
          () => mockFileService.exists(pubspecPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.exists(diArtifact.path),
        ).thenAnswer((_) async => false);
        when(
          () => mockFileService.exists(routeArtifact.path),
        ).thenAnswer((_) async => false);
        when(
          () => mockFileService.exists(mainAppPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.exists(failureXPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.exists(appDiPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.exists(appRouterPath),
        ).thenAnswer((_) async => true);

        const initialPubspec = '''
name: portal_app
dependencies:
  flutter:
    sdk: flutter
''';

        const initialMainApp = '''
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate
      ],
    );
  }
}
''';

        const initialFailureX = '''
extension FailureX on Failure {
  String localizeAny(BuildContext context) {
    if (this is CoreFailure) {
      return (this as CoreFailure).localize(context);
    }
    return context.l10n.unknownError;
  }
}
''';

        const initialAppDi = '''
Future<void> initDI() async {
  sl.registerLazySingleton(() => AppConfig());
}
''';

        const initialAppRouter = '''
final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SizedBox())
  ],
);
''';

        when(
          () => mockFileService.readAsString(pubspecPath),
        ).thenAnswer((_) async => initialPubspec);
        when(
          () => mockFileService.readAsString(mainAppPath),
        ).thenAnswer((_) async => initialMainApp);
        when(
          () => mockFileService.readAsString(failureXPath),
        ).thenAnswer((_) async => initialFailureX);
        when(
          () => mockFileService.readAsString(appDiPath),
        ).thenAnswer((_) async => initialAppDi);
        when(
          () => mockFileService.readAsString(appRouterPath),
        ).thenAnswer((_) async => initialAppRouter);

        // When
        await regModuleService.registerModule(
          param: sampleParam,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Injecting module dependency into app pubspec.yaml...',
          'Creating app module DI wrapper file...',
          'Creating app module Route wrapper file...',
          'Injecting module localizations into main_app.dart...',
          'Injecting failure handling into failure_x.dart...',
          'Injecting module DI registration into core/di/di.dart...',
          'Injecting module route into app_router.dart...',
          'refreshing app...',
        ]);

        // 1. Verify pubspec.yaml dependency injection
        final capturedPubspec =
            verify(
                  () => mockFileService.writeAsString(
                    path: pubspecPath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;

        final parsedPubspec = loadYaml(capturedPubspec) as YamlMap;
        expect(
          parsedPubspec['dependencies']['project_management']['path'],
          '../../modules/project_management',
        );
        verify(() => mockReportService.addInjected(pubspecPath)).called(1);

        // 2. Verify DI & Route wrapper files creation
        verify(
          () => mockFileService.writeAsString(
            path: diArtifact.path,
            content: diArtifact.content,
          ),
        ).called(1);
        verify(() => mockReportService.addCreated(diArtifact.path)).called(1);

        verify(
          () => mockFileService.writeAsString(
            path: routeArtifact.path,
            content: routeArtifact.content,
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(routeArtifact.path),
        ).called(1);

        // 3. Verify main_app.dart localizationsDelegates injection
        verify(
          () => mockImportService.injectImport(
            path: mainAppPath,
            imports: {
              "import 'package:project_management/project_management.dart';",
            },
          ),
        ).called(1);
        final capturedMainApp =
            verify(
                  () => mockFileService.writeAsString(
                    path: mainAppPath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;
        expect(
          capturedMainApp,
          contains('...ProjectManagementLocalizations.localizationsDelegates'),
        );
        verify(() => mockReportService.addInjected(mainAppPath)).called(1);

        // 4. Verify failure_x.dart injection
        verify(
          () => mockImportService.injectImport(
            path: failureXPath,
            imports: {
              "import 'package:project_management/project_management.dart';",
            },
          ),
        ).called(1);
        final capturedFailureX =
            verify(
                  () => mockFileService.writeAsString(
                    path: failureXPath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;
        expect(
          capturedFailureX,
          contains('if (this is ProjectManagementFailure)'),
        );
        expect(
          capturedFailureX,
          contains(
            'return (this as ProjectManagementFailure).localize(context);',
          ),
        );
        verify(() => mockReportService.addInjected(failureXPath)).called(1);

        // 5. Verify core/di/di.dart injection
        verify(
          () => mockImportService.injectImport(
            path: appDiPath,
            imports: {
              "import '../../modules/project_management/project_management_di.dart';",
            },
          ),
        ).called(1);
        final capturedAppDi =
            verify(
                  () => mockFileService.writeAsString(
                    path: appDiPath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;
        expect(capturedAppDi, contains('ProjectManagementDi.register();'));
        verify(() => mockReportService.addInjected(appDiPath)).called(1);

        // 6. Verify app_router.dart injection
        final relativeRoutePath = p
            .relative(
              sampleParam.appModuleRoutePath,
              from: p.dirname(appRouterPath),
            )
            .replaceAll(r'\', '/');
        verify(
          () => mockImportService.injectImport(
            path: appRouterPath,
            imports: {"import '$relativeRoutePath';"},
          ),
        ).called(1);
        final capturedAppRouter =
            verify(
                  () => mockFileService.writeAsString(
                    path: appRouterPath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;
        expect(capturedAppRouter, contains('ProjectManagementRoute.base'));
        verify(() => mockReportService.addInjected(appRouterPath)).called(1);
        // 7. Verify app refresh
        verify(
          () => mockRefreshService.refresh(
            sampleParam.appPath,
            onProgress: progressLogs.add,
          ),
        ).called(1);
      },
    );
    test(
      'GIVEN module is already registered in all target files and wrappers already exist '
      'WHEN registerModule is called '
      'THEN skips duplicate creations and injections and only triggers refresh',
      () async {
        // Given
        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);
        when(() => mockFileService.readAsString(pubspecPath)).thenAnswer(
          (_) async => '''
name: portal_app
dependencies:
  project_management:
    path: ../../modules/project_management
''',
        );

        when(() => mockFileService.readAsString(mainAppPath)).thenAnswer(
          (_) async =>
              '...ProjectManagementLocalizations.localizationsDelegates',
        );
        when(
          () => mockFileService.readAsString(failureXPath),
        ).thenAnswer((_) async => 'if (this is ProjectManagementFailure) {}');
        when(
          () => mockFileService.readAsString(appDiPath),
        ).thenAnswer((_) async => 'ProjectManagementDi.register();');
        when(
          () => mockFileService.readAsString(appRouterPath),
        ).thenAnswer((_) async => 'ProjectManagementRoute.base');
        // When
        await regModuleService.registerModule(
          param: sampleParam,
          onProgress: (_) {},
        );
        // Then
        verifyNever(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        );
        verifyNever(
          () => mockImportService.injectImport(
            path: any(named: 'path'),
            imports: any(named: 'imports'),
          ),
        );
        verifyNever(() => mockReportService.addCreated(any()));
        verifyNever(() => mockReportService.addInjected(any()));
        verify(
          () => mockRefreshService.refresh(
            sampleParam.appPath,
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
      },
    );
    test('GIVEN optional target files do not exist '
        'WHEN registerModule is called '
        'THEN skips missing files gracefully without throwing', () async {
      // Given
      when(
        () => mockFileService.exists(pubspecPath),
      ).thenAnswer((_) async => false);
      when(
        () => mockFileService.exists(diArtifact.path),
      ).thenAnswer((_) async => true);
      when(
        () => mockFileService.exists(routeArtifact.path),
      ).thenAnswer((_) async => true);
      when(
        () => mockFileService.exists(mainAppPath),
      ).thenAnswer((_) async => false);
      when(
        () => mockFileService.exists(failureXPath),
      ).thenAnswer((_) async => false);
      when(
        () => mockFileService.exists(appDiPath),
      ).thenAnswer((_) async => false);
      when(
        () => mockFileService.exists(appRouterPath),
      ).thenAnswer((_) async => false);
      // When
      await regModuleService.registerModule(
        param: sampleParam,
        onProgress: (_) {},
      );
      // Then
      verifyNever(() => mockFileService.readAsString(any()));
      verifyNever(
        () => mockFileService.writeAsString(
          path: any(named: 'path'),
          content: any(named: 'content'),
        ),
      );
      verify(
        () => mockRefreshService.refresh(
          sampleParam.appPath,
          onProgress: any(named: 'onProgress'),
        ),
      ).called(1);
    });
  });
}
