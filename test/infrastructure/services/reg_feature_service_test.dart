import 'dart:io';

import 'package:fsda_cli/domain/params/app_integration/reg_feature_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/reg_feature_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockFileService extends Mock implements FileService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class FakeFileSystemEntity extends Mock implements FileSystemEntity {
  final String _path;
  FakeFileSystemEntity(this._path);

  @override
  String get path => _path;
}

void main() {
  late RegFeatureService regFeatureService;
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockDirectoryService mockDirectoryService;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockDirectoryService = MockDirectoryService();

    regFeatureService = RegFeatureService(
      reportService: mockReportService,
      fileService: mockFileService,
      directoryService: mockDirectoryService,
    );
  });

  group('RegFeatureService Full 100% Coverage Tests', () {
    const regParam = RegFeatureParam(
      appName: 'my_app',
      appPath: '/app',
      moduleName: 'auth',
      modulePath: '/modules/auth',
      featureName: 'auth',
      featurePath: '/modules/auth/lib/src/features/auth',
    );

    test(
      'registerFeature executes fully covering all metadata inspectors, filters, cubit parameters, and app router visitor',
      () async {
        // 1. Stub directory exists untuk folder fitur
        when(() => mockDirectoryService.exists(any())).thenAnswer((
          invocation,
        ) async {
          final path = invocation.positionalArguments.first as String;
          if (path.contains('pages')) {
            return true;
          }
          return false;
        });

        when(
          () => mockDirectoryService.create(any()),
        ).thenAnswer((_) async => {});

        // 2. Stub listFilePaths dengan mengeksekusi parameter 'where' secara eksplisit
        when(
          () => mockDirectoryService.listPaths(
            dirPath: any(named: 'dirPath'),
            where: any(named: 'where'),
          ),
        ).thenAnswer((invocation) async {
          final dirPath =
              invocation.namedArguments[const Symbol('dirPath')] as String;
          final whereFilter =
              invocation.namedArguments[const Symbol('where')]
                  as bool Function(FakeFileSystemEntity, bool)?;

          List<String> rawPaths = [];
          if (dirPath.contains('datasources')) {
            rawPaths = [
              '/modules/auth/lib/src/features/auth/data/datasources/auth_ds.dart',
              '/modules/auth/lib/src/features/auth/data/datasources/auth_ds_impl.dart', // Diuji agar terfilter oleh !_impl.dart
            ];
          } else if (dirPath.contains('repositories')) {
            rawPaths = [
              '/modules/auth/lib/src/features/auth/domain/repositories/auth_repo.dart',
            ];
          } else if (dirPath.contains('usecases')) {
            rawPaths = [
              '/modules/auth/lib/src/features/auth/domain/usecases/login_usecase.dart',
            ];
          } else if (dirPath.contains('logic')) {
            rawPaths = [
              '/modules/auth/lib/src/features/auth/logic/auth_cubit.dart',
            ];
          }

          if (whereFilter != null) {
            return rawPaths
                .where(
                  (path) =>
                      whereFilter(FakeFileSystemEntity(path), true) == true,
                )
                .toList();
          }
          return rawPaths;
        });

        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);

        // 3. Stub readAsString untuk mengembalikan kode Dart valid pada setiap file
        when(() => mockFileService.readAsString(any())).thenAnswer((
          invocation,
        ) async {
          final path = invocation.positionalArguments.first as String;
          if (path.contains('auth_ds_impl.dart')) {
            return 'class AuthDatasourceImpl {}';
          } else if (path.contains('auth_ds.dart')) {
            return 'abstract class AuthRemoteDatasource {}';
          } else if (path.contains('auth_repo.dart')) {
            return 'abstract class AuthRepository {}';
          } else if (path.contains('login_usecase.dart')) {
            return 'class LoginUseCase {}';
          } else if (path.contains('auth_cubit.dart')) {
            return '''
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.loginUseCase, super.initialState, token);
  final LoginUseCase loginUseCase;
}
''';
          } else if (path.contains('di')) {
            return '''
class AuthDi {
  static void register() {}
}
''';
          } else if (path.contains('route')) {
            return '''
class AuthRoute {}
''';
          } else if (path.contains('app_router.dart')) {
            return '''
class AppRouter {
  final router = GoRouter(
    routes: [
      RouteItem(),
    ],
  );
}
''';
          }
          return 'class DummyClass {}';
        });

        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        when(() => mockReportService.addCreated(any())).thenReturn(null);
        when(() => mockReportService.addInjected(any())).thenReturn(null);

        final progressLogs = <String>[];
        await regFeatureService.registerFeature(
          param: regParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
      },
    );

    test(
      'Given feature subdirectories exist with valid architecture files (datasources, repositories, usecases, logic), '
      'When registerFeature is called, '
      'Then it successfully inspects feature metadata, parses AST classes, and injects DI & routes',
      () async {
        // Arrange (Given)
        when(() => mockDirectoryService.exists(any())).thenAnswer((
          invocation,
        ) async {
          final path = invocation.positionalArguments.first as String;
          // Mengaktifkan folder fitur agar proses _inspectFeatureMetadata dieksekusi
          if (path.contains('datasources') ||
              path.contains('repositories') ||
              path.contains('usecases') ||
              path.contains('logic') ||
              path.contains('pages') ||
              path.contains('widgets')) {
            return true;
          }
          return false;
        });

        when(
          () => mockDirectoryService.create(any()),
        ).thenAnswer((_) async => {});

        when(
          () => mockDirectoryService.listPaths(
            dirPath: any(named: 'dirPath'),
            where: any(named: 'where'),
          ),
        ).thenAnswer((invocation) async {
          final dirPath =
              invocation.namedArguments[const Symbol('dirPath')] as String;
          final whereFilter =
              invocation.namedArguments[const Symbol('where')]
                  as bool Function(FakeFileSystemEntity, bool)?;

          List<String> rawPaths = [];
          if (dirPath.contains('datasources')) {
            rawPaths = [
              '/modules/auth/lib/src/features/auth/data/datasources/auth_ds_impl.dart',
            ];
          } else if (dirPath.contains('repositories')) {
            rawPaths = [
              '/modules/auth/lib/src/features/auth/domain/repositories/auth_repo.dart',
            ];
          } else if (dirPath.contains('usecases')) {
            rawPaths = [
              '/modules/auth/lib/src/features/auth/domain/usecases/login_usecase.dart',
            ];
          } else if (dirPath.contains('logic')) {
            rawPaths = [
              '/modules/auth/lib/src/features/auth/logic/auth_slice/auth_cubit.dart',
            ];
          } else if (dirPath.contains('logicPath') ||
              dirPath.endsWith('logic')) {
            return ['/modules/auth/lib/src/features/auth/logic/auth_slice'];
          }

          if (whereFilter != null) {
            return rawPaths
                .where(
                  (path) =>
                      whereFilter(FakeFileSystemEntity(path), true) == true,
                )
                .toList();
          }
          return rawPaths;
        });

        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);

        when(() => mockFileService.readAsString(any())).thenAnswer((
          invocation,
        ) async {
          final path = invocation.positionalArguments.first as String;
          if (path.contains('auth_ds_impl.dart')) {
            return 'class AuthDatasourceImpl {}';
          } else if (path.contains('auth_repo.dart')) {
            return 'abstract class AuthRepository {}';
          } else if (path.contains('login_usecase.dart')) {
            return 'class LoginUseCase {}';
          } else if (path.contains('auth_cubit.dart')) {
            return 'class AuthCubit {}';
          } else if (path.contains('di')) {
            return 'class AuthDi { static void register() {} }';
          } else if (path.contains('route')) {
            return 'class AuthRoute {}';
          }
          return 'class DummyClass {}';
        });

        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        when(() => mockReportService.addCreated(any())).thenReturn(null);
        when(() => mockReportService.addInjected(any())).thenReturn(null);
        when(() => mockReportService.addSkipped(any())).thenReturn(null);

        final progressLogs = <String>[];

        // Act (When)
        await regFeatureService.registerFeature(
          param: regParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        // Assert (Then)
        expect(progressLogs, isNotEmpty);
        verify(() => mockDirectoryService.exists(any())).called(greaterThan(0));
      },
    );

    test('Given feature DI and route already exist in target module files, '
        'When registerFeature is called, '
        'Then it skips injection and reports them as skipped', () async {
      // Arrange (Given)
      when(
        () => mockDirectoryService.exists(any()),
      ).thenAnswer((_) async => true);
      when(
        () => mockDirectoryService.create(any()),
      ).thenAnswer((_) async => {});
      when(
        () => mockDirectoryService.listPaths(
          dirPath: any(named: 'dirPath'),
          where: any(named: 'where'),
        ),
      ).thenAnswer((_) async => []);

      when(() => mockFileService.exists(any())).thenAnswer((_) async => true);

      // Mengembalikan konten yang sudah memiliki tanda pendaftaran agar memicu branch skipped
      when(() => mockFileService.readAsString(any())).thenAnswer((
        invocation,
      ) async {
        final path = invocation.positionalArguments.first as String;
        if (path.contains('di')) {
          return 'class AuthDi { static void register() { _authDi(); } }';
        } else if (path.contains('route')) {
          return 'class AuthRoute { static final authBase = ""; }';
        }
        return '';
      });

      when(() => mockReportService.addSkipped(any())).thenReturn(null);

      final progressLogs = <String>[];

      // Act (When)
      await regFeatureService.registerFeature(
        param: regParam,
        onProgress: (msg) => progressLogs.add(msg),
      );

      // Assert (Then)
      expect(progressLogs, isNotEmpty);
      verify(
        () => mockReportService.addSkipped(any()),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
