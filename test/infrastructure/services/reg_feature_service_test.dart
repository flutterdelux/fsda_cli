import 'dart:io';

import 'package:fsda_cli/core/extensions/feature_param_x.dart';
import 'package:fsda_cli/core/extensions/reg_module_param_x.dart';
import 'package:fsda_cli/domain/params/app_integration/reg_feature_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/reg_feature_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockFileService extends Mock implements FileService {}

class MockDirectoryService extends Mock implements DirectoryService {}

void main() {
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockDirectoryService mockDirectoryService;
  late RegFeatureService regFeatureService;

  const workspacePath = '/projects/my_workspace';
  const sampleParam = RegFeatureParam(
    featureName: 'task',
    moduleName: 'project_management',
    appName: 'portal_app',
    workspaceName: 'my_workspace',
    workspacePath: workspacePath,
  );

  final expectedPagesPath = p.join(
    sampleParam.appModulePath,
    'features',
    'task',
    'pages',
  );
  final expectedWidgetsPath = p.join(
    sampleParam.appModulePath,
    'features',
    'task',
    'widgets',
  );

  final dsDirPath = p.join(sampleParam.featurePath, 'data', 'datasources');
  final repoDirPath = p.join(sampleParam.featurePath, 'data', 'repositories');
  final ucDirPath = p.join(sampleParam.featurePath, 'domain', 'usecases');
  final logicDirPath = p.join(sampleParam.featurePath, 'logic');

  final diPath = sampleParam.appModuleDiPath;
  final routePath = sampleParam.appModuleRoutePath;

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockDirectoryService = MockDirectoryService();

    regFeatureService = RegFeatureService(
      reportService: mockReportService,
      fileService: mockFileService,
      directoryService: mockDirectoryService,
    );

    when(() => mockDirectoryService.create(any())).thenAnswer((_) async {});
    when(
      () => mockFileService.writeAsString(
        path: any(named: 'path'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});
  });

  group('RegFeatureService.registerFeature', () {
    test(
      'GIVEN valid RegFeatureParam with feature files, DI class, and Route class '
      'WHEN registerFeature is called '
      'THEN scaffolds folders, inspects AST metadata, injects DI and Route definitions, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];

        // 1. Scaffold folders don't exist yet
        when(
          () => mockDirectoryService.exists(expectedPagesPath),
        ).thenAnswer((_) async => false);
        when(
          () => mockDirectoryService.exists(expectedWidgetsPath),
        ).thenAnswer((_) async => false);

        // 2. Feature subdirectories exist
        when(
          () => mockDirectoryService.exists(dsDirPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockDirectoryService.exists(repoDirPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockDirectoryService.exists(ucDirPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockDirectoryService.exists(logicDirPath),
        ).thenAnswer((_) async => true);

        // Datasources: 1 interface (ignored) + 1 Impl (included)
        final dsInterfaceFile = p.join(
          dsDirPath,
          'task_remote_data_source.dart',
        );
        final dsImplFile = p.join(
          dsDirPath,
          'task_remote_data_source_impl.dart',
        );
        when(
          () => mockDirectoryService.listPaths(
            dirPath: dsDirPath,
            where: any(named: 'where'),
          ),
        ).thenAnswer((_) async => [dsInterfaceFile, dsImplFile]);
        when(() => mockFileService.readAsString(dsInterfaceFile)).thenAnswer(
          (_) async => 'abstract interface class TaskRemoteDataSource {}',
        );
        when(() => mockFileService.readAsString(dsImplFile)).thenAnswer(
          (_) async => '''
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final ApiClient _apiClient;
  const TaskRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;
}
''',
        );

        // Repositories
        final repoImplFile = p.join(repoDirPath, 'task_repository_impl.dart');
        when(
          () => mockDirectoryService.listPaths(
            dirPath: repoDirPath,
            where: any(named: 'where'),
          ),
        ).thenAnswer((_) async => [repoImplFile]);
        when(() => mockFileService.readAsString(repoImplFile)).thenAnswer(
          (_) async => '''
class TaskRepositoryImpl implements TaskRepository {
  final AppLogger _log;
  final TaskRemoteDataSource _remoteDataSource;
  const TaskRepositoryImpl({
    required AppLogger appLogger,
    required TaskRemoteDataSource taskRemoteDataSource,
  }) : _log = appLogger, _remoteDataSource = taskRemoteDataSource;
}
''',
        );

        // UseCases
        final ucFile = p.join(ucDirPath, 'get_task_use_case.dart');
        when(
          () => mockDirectoryService.listPaths(
            dirPath: ucDirPath,
            where: any(named: 'where'),
          ),
        ).thenAnswer((_) async => [ucFile]);
        when(() => mockFileService.readAsString(ucFile)).thenAnswer(
          (_) async => '''
class GetTaskUseCase {
  final TaskRepository _repository;
  const GetTaskUseCase({required TaskRepository taskRepository}) : _repository = taskRepository;
}
''',
        );

        // Logic slices
        final listSliceDir = p.join(logicDirPath, 'list');
        final cubitFile = p.join(listSliceDir, 'task_list_cubit.dart');
        when(
          () => mockDirectoryService.listPaths(
            dirPath: logicDirPath,
            where: any(named: 'where'),
          ),
        ).thenAnswer((_) async => [listSliceDir]);
        when(
          () => mockDirectoryService.listPaths(
            dirPath: listSliceDir,
            where: any(named: 'where'),
          ),
        ).thenAnswer((_) async => [cubitFile]);
        when(() => mockFileService.readAsString(cubitFile)).thenAnswer(
          (_) async => '''
class TaskListCubit {
  final GetTaskUseCase _getTaskUseCase;
  TaskListCubit({required GetTaskUseCase getTaskUseCase}) : _getTaskUseCase = getTaskUseCase;
}
''',
        );

        // 3. Initial Module DI & Route contents
        const initialDiContent = '''
class ProjectManagementDi {
  static void register() {
  }
}
''';
        const initialRouteContent = '''
class ProjectManagementRoute {
  static const String root = '/project-management';

  static List<RouteBase> get routes => [
    ...dashboardBase,
  ];

  static List<RouteBase> get dashboardBase => [];
}
''';

        when(
          () => mockFileService.readAsString(diPath),
        ).thenAnswer((_) async => initialDiContent);
        when(
          () => mockFileService.readAsString(routePath),
        ).thenAnswer((_) async => initialRouteContent);

        // When
        await regFeatureService.registerFeature(
          param: sampleParam,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Scaffolding feature pages and widgets directories...',
          'Inspecting feature files in module...',
          'Injecting feature DI registrations into module DI...',
          'Injecting feature routes into module route...',
        ]);

        // Verify scaffold folders
        verify(() => mockDirectoryService.create(expectedPagesPath)).called(1);
        verify(() => mockReportService.addCreated(expectedPagesPath)).called(1);
        verify(
          () => mockDirectoryService.create(expectedWidgetsPath),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedWidgetsPath),
        ).called(1);

        // Verify DI injection
        final capturedDi =
            verify(
                  () => mockFileService.writeAsString(
                    path: diPath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;

        expect(capturedDi, contains('_taskDi();'));
        expect(capturedDi, contains('static void _taskDi() {'));
        expect(
          capturedDi,
          contains('sl.registerLazySingleton<TaskRemoteDataSource>('),
        );
        expect(
          capturedDi,
          contains('sl.registerLazySingleton<TaskRepository>('),
        );
        expect(capturedDi, contains('() => GetTaskUseCase('));
        expect(capturedDi, contains('() => TaskListCubit('));
        verify(() => mockReportService.addInjected(diPath)).called(1);

        // Verify Route injection
        final capturedRoute =
            verify(
                  () => mockFileService.writeAsString(
                    path: routePath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;

        expect(capturedRoute, contains('static RouteBase get taskBase'));
        verify(() => mockReportService.addInjected(routePath)).called(1);
      },
    );

    test(
      'GIVEN pages/widgets already exist, feature folders are missing, and DI/Route are already registered '
      'WHEN registerFeature is called '
      'THEN skips existing folders and duplicate DI/Route injections safely',
      () async {
        // Given
        when(
          () => mockDirectoryService.exists(expectedPagesPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockDirectoryService.exists(expectedWidgetsPath),
        ).thenAnswer((_) async => true);

        when(
          () => mockDirectoryService.exists(dsDirPath),
        ).thenAnswer((_) async => false);
        when(
          () => mockDirectoryService.exists(repoDirPath),
        ).thenAnswer((_) async => false);
        when(
          () => mockDirectoryService.exists(ucDirPath),
        ).thenAnswer((_) async => false);
        when(
          () => mockDirectoryService.exists(logicDirPath),
        ).thenAnswer((_) async => false);
        const alreadyRegisteredDi = '''
class ProjectManagementDi {
static void register() {
_taskDi();
}
static void _taskDi() {}
}
''';
        const alreadyRegisteredRoute = '''
class ProjectManagementRoute {
static List get taskBase => [];
}
''';
        when(
          () => mockFileService.readAsString(diPath),
        ).thenAnswer((_) async => alreadyRegisteredDi);
        when(
          () => mockFileService.readAsString(routePath),
        ).thenAnswer((_) async => alreadyRegisteredRoute);
        // When
        await regFeatureService.registerFeature(
          param: sampleParam,
          onProgress: (_) {},
        );
        // Then
        verifyNever(() => mockDirectoryService.create(any()));
        verify(() => mockReportService.addSkipped(expectedPagesPath)).called(1);
        verify(
          () => mockReportService.addSkipped(expectedWidgetsPath),
        ).called(1);
        verify(() => mockReportService.addSkipped(diPath)).called(1);
        verify(() => mockReportService.addSkipped(routePath)).called(1);
        verifyNever(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        );
        verifyNever(() => mockReportService.addInjected(any()));
      },
    );
    test('GIVEN listPaths predicate filter is invoked '
        'WHEN inspecting datasources and logic directories '
        'THEN filters files and subdirectories accurately', () async {
      // Given
      when(
        () => mockDirectoryService.exists(expectedPagesPath),
      ).thenAnswer((_) async => true);
      when(
        () => mockDirectoryService.exists(expectedWidgetsPath),
      ).thenAnswer((_) async => true);
      when(
        () => mockDirectoryService.exists(dsDirPath),
      ).thenAnswer((_) async => true);
      when(
        () => mockDirectoryService.exists(repoDirPath),
      ).thenAnswer((_) async => false);
      when(
        () => mockDirectoryService.exists(ucDirPath),
      ).thenAnswer((_) async => false);
      when(
        () => mockDirectoryService.exists(logicDirPath),
      ).thenAnswer((_) async => true);
      bool Function(FileSystemEntity, bool)? capturedDsWhere;
      bool Function(FileSystemEntity, bool)? capturedLogicSliceWhere;
      bool Function(FileSystemEntity, bool)? capturedLogicFileWhere;
      when(
        () => mockDirectoryService.listPaths(
          dirPath: dsDirPath,
          where: any(named: 'where'),
        ),
      ).thenAnswer((invocation) async {
        capturedDsWhere =
            invocation.namedArguments[#where]
                as bool Function(FileSystemEntity, bool)?;
        return [];
      });
      final sliceDir = p.join(logicDirPath, 'form');
      when(
        () => mockDirectoryService.listPaths(
          dirPath: logicDirPath,
          where: any(named: 'where'),
        ),
      ).thenAnswer((invocation) async {
        capturedLogicSliceWhere =
            invocation.namedArguments[#where]
                as bool Function(FileSystemEntity, bool)?;
        return [sliceDir];
      });
      when(
        () => mockDirectoryService.listPaths(
          dirPath: sliceDir,
          where: any(named: 'where'),
        ),
      ).thenAnswer((invocation) async {
        capturedLogicFileWhere =
            invocation.namedArguments[#where]
                as bool Function(FileSystemEntity, bool)?;
        return [];
      });
      when(() => mockFileService.readAsString(diPath)).thenAnswer(
        (_) async =>
            'class ProjectManagementDi { static void register() { taskDi(); } }',
      );
      when(() => mockFileService.readAsString(routePath)).thenAnswer(
        (_) async =>
            'class ProjectManagementRoute { static List get taskBase => []; }',
      );
      // When
      await regFeatureService.registerFeature(
        param: sampleParam,
        onProgress: (_) {},
      );
      // Then: Verify filter predicates
      expect(capturedDsWhere!(File('a.dart'), true), isTrue);
      expect(capturedDsWhere!(File('a.txt'), true), isFalse);
      expect(capturedDsWhere!(Directory('sub.dart'), false), isFalse);
      expect(capturedLogicSliceWhere!(Directory('form'), false), isTrue);
      expect(capturedLogicSliceWhere!(File('form.dart'), true), isFalse);
      expect(capturedLogicFileWhere!(File('a_cubit.dart'), true), isTrue);
      expect(capturedLogicFileWhere!(File('a_controller.dart'), true), isTrue);
      expect(capturedLogicFileWhere!(File('a_provider.dart'), true), isTrue);
      expect(capturedLogicFileWhere!(File('a_bloc.dart'), true), isTrue);
      expect(capturedLogicFileWhere!(File('a_state.dart'), true), isFalse);
    });
  });
}
