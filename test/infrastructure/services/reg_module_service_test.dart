import 'package:fsda_cli/domain/params/app_integration/reg_module_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/reg_module_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockFileService extends Mock implements FileService {}

class MockImportService extends Mock implements ImportService {}

void main() {
  late RegModuleService regModuleService;
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockImportService mockImportService;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockImportService = MockImportService();

    regModuleService = RegModuleService(
      reportService: mockReportService,
      fileService: mockFileService,
      importService: mockImportService,
    );
  });

  group('RegModuleService 100% Comprehensive Tests', () {
    const regModuleParam = RegModuleParam(
      appName: 'my_app',
      appPath: '/app',
      moduleName: 'auth',
      modulePath: '/modules/auth',
      featureName: 'auth',
      featurePath: '/modules/auth/lib/src/features/auth',
    );

    test(
      'registerModule executes successfully and covers all AST visitors including AppRouter',
      () async {
        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);

        // Mengembalikan konten file sesuai jalur path yang diuji, pastikan app_router.dart di-mock dengan GoRouter
        when(() => mockFileService.readAsString(any())).thenAnswer((
          invocation,
        ) async {
          final path = invocation.positionalArguments.first as String;
          if (path.contains('main_app.dart')) {
            return '''
class MainApp {
  void build() {
    MaterialApp(
      localizationsDelegates: [
        AuthLocalizations.delegate,
      ],
    );
  }
}
''';
          } else if (path.contains('failure_x.dart')) {
            return '''
extension FailureX on Failure {
  String localizeAny() {
    return 'error';
  }
}
''';
          } else if (path.contains('di.dart')) {
            return '''
void initDI() {
}
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
          return '';
        });

        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});

        when(
          () => mockImportService.injectImport(
            path: any(named: 'path'),
            imports: any(named: 'imports'),
          ),
        ).thenAnswer((_) async => {});

        when(() => mockReportService.addCreated(any())).thenReturn(null);
        when(() => mockReportService.addInjected(any())).thenReturn(null);

        final progressLogs = <String>[];
        await regModuleService.registerModule(
          param: regModuleParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        verify(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).called(greaterThan(0));
      },
    );

    test(
      'registerModule handles empty list literals in visitors and empty routes',
      () async {
        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);

        when(() => mockFileService.readAsString(any())).thenAnswer((
          invocation,
        ) async {
          final path = invocation.positionalArguments.first as String;
          if (path.contains('main_app.dart')) {
            return '''
class MainApp {
  void build() {
    MaterialApp(
      localizationsDelegates: [],
    );
  }
}
''';
          } else if (path.contains('failure_x.dart')) {
            return '''
extension FailureX on Failure {
  String localizeAny() {
    // Tanpa return statement agar mencakup branch rightBracket.offset
  }
}
''';
          } else if (path.contains('di.dart')) {
            return 'void initDI() {}';
          } else if (path.contains('app_router.dart')) {
            return '''
class AppRouter {
  final router = GoRouter(
    routes: [],
  );
}
''';
          }
          return '';
        });

        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockImportService.injectImport(
            path: any(named: 'path'),
            imports: any(named: 'imports'),
          ),
        ).thenAnswer((_) async => {});
        when(() => mockReportService.addCreated(any())).thenReturn(null);
        when(() => mockReportService.addInjected(any())).thenReturn(null);

        final progressLogs = <String>[];
        await regModuleService.registerModule(
          param: regModuleParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
      },
    );
  });
}
