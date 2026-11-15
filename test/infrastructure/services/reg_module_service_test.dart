import 'package:fsda_cli/core/extensions/app_integration_param_x.dart';
import 'package:fsda_cli/domain/params/app_integration/reg_module_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/refresh_service.dart';
import 'package:fsda_cli/infrastructure/services/reg_module_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

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
  });

  group('RegModuleService - registerModule', () {
    const tRegModuleParam = RegModuleParam(
      appName: 'my_app',
      appPath: '/workspace/apps/my_app',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
    );

    test(
      'Given valid RegModuleParam and non-existent wrapper files, '
      'When registerModule is called, '
      'Then it injects pubspec dependency, creates DI & Route wrappers, updates configurations, and refreshes app successfully',
      () async {
        // Arrange (Given)
        final progressLogs = <String>[];

        // 1. Pubspec injection stubbing
        when(
          () => mockFileService.exists(tRegModuleParam.appPubspecPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(tRegModuleParam.appPubspecPath),
        ).thenAnswer(
          (_) async =>
              'name: my_app\ndependencies:\n  flutter:\n    sdk: flutter',
        );
        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockReportService.addInjected(any())).thenReturn(null);
        when(() => mockReportService.addCreated(any())).thenReturn(null);

        // 2. DI & Route wrapper file existence check (dianggap belum ada agar dibuat baru)
        final diArtifactPath = tRegModuleParam.appModuleDiPath;
        final routeArtifactPath = tRegModuleParam.appModuleRoutePath;

        when(
          () => mockFileService.exists(diArtifactPath),
        ).thenAnswer((_) async => false);
        when(
          () => mockFileService.exists(routeArtifactPath),
        ).thenAnswer((_) async => false);

        // 3. Localizations, FailureX, AppDi, AppRouter file checks and contents
        when(
          () => mockFileService.exists(tRegModuleParam.mainAppPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(tRegModuleParam.mainAppPath),
        ).thenAnswer((_) async => 'class MyApp {}');

        when(
          () => mockFileService.exists(tRegModuleParam.failureXPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(tRegModuleParam.failureXPath),
        ).thenAnswer((_) async => 'class FailureX {}');

        when(
          () => mockFileService.exists(tRegModuleParam.appDiPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(tRegModuleParam.appDiPath),
        ).thenAnswer((_) async => 'void initDi() {}');

        when(
          () => mockFileService.exists(tRegModuleParam.appRouterPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(tRegModuleParam.appRouterPath),
        ).thenAnswer((_) async => 'class AppRouter {}');

        when(
          () => mockImportService.injectImport(
            path: any(named: 'path'),
            imports: any(named: 'imports'),
          ),
        ).thenAnswer((_) async {});

        // 4. Refresh service stubbing
        when(
          () => mockRefreshService.refresh(
            tRegModuleParam.appPath,
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async {});

        // Act (When)
        await regModuleService.registerModule(
          param: tRegModuleParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        // Assert (Then)
        expect(
          progressLogs,
          contains('Injecting module dependency into app pubspec.yaml...'),
        );
        expect(
          progressLogs,
          contains('Creating app module DI wrapper file...'),
        );
        expect(
          progressLogs,
          contains('Creating app module Route wrapper file...'),
        );
        expect(
          progressLogs,
          contains('Injecting module localizations into main_app.dart...'),
        );
        expect(
          progressLogs,
          contains('Injecting failure handling into failure_x.dart...'),
        );
        expect(
          progressLogs,
          contains('Injecting module DI registration into core/di/di.dart...'),
        );
        expect(
          progressLogs,
          contains('Injecting module route into app_router.dart...'),
        );
        expect(progressLogs, contains('refreshing app...'));

        verify(
          () => mockFileService.writeAsString(
            path: diArtifactPath,
            content: any(named: 'content'),
          ),
        ).called(1);

        verify(
          () => mockFileService.writeAsString(
            path: routeArtifactPath,
            content: any(named: 'content'),
          ),
        ).called(1);

        verify(
          () => mockRefreshService.refresh(
            tRegModuleParam.appPath,
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
      },
    );

    test(
      'Given valid RegModuleParam and valid app source files containing visitor targets, '
      'When registerModule is called, '
      'Then it fully injects pubspec dependency, creates wrappers, parses AST visitors, injects code updates, and refreshes app',
      () async {
        // Arrange (Given)
        final progressLogs = <String>[];

        // 1. Pubspec injection stubbing (belum ada dependensi todo)
        when(
          () => mockFileService.exists(tRegModuleParam.appPubspecPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(tRegModuleParam.appPubspecPath),
        ).thenAnswer(
          (_) async =>
              'name: my_app\ndependencies:\n  flutter:\n    sdk: flutter\n',
        );

        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async {});

        when(() => mockReportService.addInjected(any())).thenReturn(null);
        when(() => mockReportService.addCreated(any())).thenReturn(null);

        // 2. Wrapper files (dianggap belum ada)
        when(
          () => mockFileService.exists(tRegModuleParam.appModuleDiPath),
        ).thenAnswer((_) async => false);
        when(
          () => mockFileService.exists(tRegModuleParam.appModuleRoutePath),
        ).thenAnswer((_) async => false);

        // 3. Stubbing file utama dengan struktur AST yang dikenali oleh visitor masing-masing
        when(
          () => mockFileService.exists(tRegModuleParam.mainAppPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(tRegModuleParam.mainAppPath),
        ).thenAnswer(
          (_) async => '''
class MyApp {
  List<LocalizationsDelegate> get localizationsDelegates => [
        AppLocalizations.delegate,
      ];
}
''',
        );

        when(
          () => mockFileService.exists(tRegModuleParam.failureXPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(tRegModuleParam.failureXPath),
        ).thenAnswer(
          (_) async => '''
String mapFailureToString(Failure failure, BuildContext context) {
  return 'Unexpected error';
}
''',
        );

        when(
          () => mockFileService.exists(tRegModuleParam.appDiPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(tRegModuleParam.appDiPath),
        ).thenAnswer(
          (_) async => '''
void initDi() {
  // register others
}
''',
        );

        when(
          () => mockFileService.exists(tRegModuleParam.appRouterPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(tRegModuleParam.appRouterPath),
        ).thenAnswer(
          (_) async => '''
class AppRouter {
  final routes = [
    HomeRoute.base,
  ];
}
''',
        );

        when(
          () => mockImportService.injectImport(
            path: any(named: 'path'),
            imports: any(named: 'imports'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => mockRefreshService.refresh(
            tRegModuleParam.appPath,
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async {});

        // Act (When)
        await regModuleService.registerModule(
          param: tRegModuleParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        // Assert (Then)
        expect(progressLogs, isNotEmpty);
        verify(
          () => mockFileService.writeAsString(
            path: tRegModuleParam.appPubspecPath,
            content: any(named: 'content'),
          ),
        ).called(1);
        verify(
          () => mockRefreshService.refresh(
            tRegModuleParam.appPath,
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
      },
    );

    test(
      'Given pubspec already contains the module dependency and files already contain injections, '
      'When registerModule is called, '
      'Then it safely skips existing injections without duplicating code',
      () async {
        // Arrange (Given)
        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);

        // Pubspec sudah ada dependensi todo
        when(
          () => mockFileService.readAsString(tRegModuleParam.appPubspecPath),
        ).thenAnswer(
          (_) async => 'dependencies:\n  todo:\n    path: ../modules/todo\n',
        );

        // File-file target sudah mengandung string pendaftaran modul
        when(
          () => mockFileService.readAsString(tRegModuleParam.mainAppPath),
        ).thenAnswer((_) async => 'TodoLocalizations');
        when(
          () => mockFileService.readAsString(tRegModuleParam.failureXPath),
        ).thenAnswer((_) async => 'TodoFailure');
        when(
          () => mockFileService.readAsString(tRegModuleParam.appDiPath),
        ).thenAnswer((_) async => 'TodoDi');
        when(
          () => mockFileService.readAsString(tRegModuleParam.appRouterPath),
        ).thenAnswer((_) async => 'TodoRoute.base');

        when(
          () => mockFileService.exists(tRegModuleParam.appModuleDiPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.exists(tRegModuleParam.appModuleRoutePath),
        ).thenAnswer((_) async => true);

        when(
          () => mockRefreshService.refresh(
            any(),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async {});

        final progressLogs = <String>[];

        // Act (When)
        await regModuleService.registerModule(
          param: tRegModuleParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        // Assert (Then)
        expect(progressLogs, isNotEmpty);
        verifyNever(
          () => mockFileService.writeAsString(
            path: tRegModuleParam.appPubspecPath,
            content: any(named: 'content'),
          ),
        );
      },
    );
  });
}
