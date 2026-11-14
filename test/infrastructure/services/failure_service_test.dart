import 'package:fsda_cli/domain/params/failure_param.dart';
import 'package:fsda_cli/infrastructure/services/failure_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockFileService extends Mock implements FileService {}

class MockArbService extends Mock implements ArbService {}

void main() {
  late FailureService failureService;
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockArbService mockArbService;

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockArbService = MockArbService();

    failureService = FailureService(
      reportService: mockReportService,
      fileService: mockFileService,
      arbService: mockArbService,
    );
  });

  group('FailureService Tests', () {
    const failureParam = FailureParam(
      moduleName: 'auth',
      modulePath: '/modules/auth',
      name: 'NetworkFailure',
      message: 'Network error occurred',
    );

    test(
      'generateFailure should execute full failure generation pipeline successfully',
      () async {
        when(() => mockFileService.readAsString(any())).thenAnswer(
          (_) async => '''
class AppException {
  const AppException._();
  factory AppException.unauthorized() = _Unauthorized;
  
  String get message => when(
    unauthorized: () => 'Unauthorized',
  );

  AppFailure toFailure() => when(
    unauthorized: () => AppFailure.unauthorized,
  );

  R when<R>({required R Function() unauthorized}) => throw '';

  static AppException fromApiResponse(int code) => switch (code) {
    401 => const AppException.unauthorized(),
    _ => throw '',
  };
}

enum AppFailure {
  unauthorized,
}

extension FailureX on AppFailure {
  String get localize => switch (this) {
    AppFailure.unauthorized => 'Unauthorized',
    _ => 'Unknown',
  };
}
''',
        );

        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
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

        when(() => mockReportService.addInjected(any())).thenReturn(null);

        final progressLogs = <String>[];

        await failureService.generateFailure(
          failureParam: failureParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        expect(progressLogs.first, contains('Injecting exception factory'));

        verify(() => mockFileService.readAsString(any())).called(3);
        verify(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).called(3);
        verify(() => mockArbService.getArbPaths(any())).called(1);
        verify(
          () => mockArbService.injectEntriesBeforeKey(
            arbPath: any(named: 'arbPath'),
            arbEntries: any(named: 'arbEntries'),
            endKey: any(named: 'endKey'),
          ),
        ).called(1);
        verify(() => mockReportService.addInjected(any())).called(4);
      },
    );
  });
}
