import 'package:fsda_cli/core/extensions/failure_param_x.dart';
import 'package:fsda_cli/core/extensions/module_param_x.dart';
import 'package:fsda_cli/domain/params/failure_param.dart';
import 'package:fsda_cli/infrastructure/services/failure_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/templates/failure_template.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockFileService extends Mock implements FileService {}

class MockArbService extends Mock implements ArbService {}

void main() {
  late MockOperationReportService mockReportService;
  late MockFileService mockFileService;
  late MockArbService mockArbService;
  late FailureService failureService;

  const workspacePath = '/projects/my_workspace';
  const sampleFailureParam = FailureParam(
    name: 'task_not_found',
    message: 'Task not found.',
    moduleName: 'project_management',
    workspaceName: 'my_workspace',
    workspacePath: workspacePath,
  );

  final expectedModulePath = sampleFailureParam.modulePath;
  final expectedExceptionPath = sampleFailureParam.exceptionPath;
  final expectedFailurePath = sampleFailureParam.failurePath;
  final expectedExtensionPath = sampleFailureParam.extensionPath;
  final arbPaths = [
    p.join(expectedModulePath, 'lib', 'l10n', 'app_en.arb'),
    p.join(expectedModulePath, 'lib', 'l10n', 'app_id.arb'),
  ];

  setUp(() {
    mockReportService = MockOperationReportService();
    mockFileService = MockFileService();
    mockArbService = MockArbService();

    failureService = FailureService(
      reportService: mockReportService,
      fileService: mockFileService,
      arbService: mockArbService,
    );

    when(
      () => mockFileService.writeAsString(
        path: any(named: 'path'),
        content: any(named: 'content'),
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
  });

  group('FailureService.generateFailure', () {
    test(
      'GIVEN valid FailureParam and existing exception, failure enum, and extension files '
      'WHEN generateFailure is called '
      'THEN injects factory, message, toFailure, switch case, enum value, localize entry, and ARB keys accurately',
      () async {
        // Given
        final progressLogs = <String>[];

        const initialExceptionSource = '''
class ProjectManagementException {
  const factory ProjectManagementException.unknown({required String msg}) = _Unknown;

  String get message => when(
    unknown: (msg) => msg
  );

  ProjectManagementFailure toFailure() => when(
    unknown: (_) => ProjectManagementFailure.unknown
  );

  static AppException fromApiResponse(ApiResponse response, {StackTrace? st}) {
    if (response.body is Map<String, dynamic>) {
      final code = response.body['code'] as String?;
      final message = response.body['message'] as String?;
      return switch (code) {
        _ => CoreException.fromException(response.body.toString(), st: st),
      };
    }
    return CoreException.fromException(response.body.toString(), st: st);
  }
}
''';

        const initialFailureEnumSource = '''
enum ProjectManagementFailure {
  unknown
}
''';

        const initialExtensionSource = '''
extension ProjectManagementFailureX on ProjectManagementFailure {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      ProjectManagementFailure.unknown => l10n.unknownError,
      _ => l10n.unknownError,
    };
  }
}
''';

        when(
          () => mockFileService.readAsString(expectedExceptionPath),
        ).thenAnswer((_) async => initialExceptionSource);
        when(
          () => mockFileService.readAsString(expectedFailurePath),
        ).thenAnswer((_) async => initialFailureEnumSource);
        when(
          () => mockFileService.readAsString(expectedExtensionPath),
        ).thenAnswer((_) async => initialExtensionSource);

        // When
        await failureService.generate(
          failureParam: sampleFailureParam,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Injecting exception factory, message, toFailure, and code response at the end...',
          'Injecting failure enum value at the end...',
          'Injecting localize entry in failure extension at the end...',
          'Injecting localization keys into ARB files...',
        ]);

        // 1. Verify Exception file AST injection
        final capturedException =
            verify(
                  () => mockFileService.writeAsString(
                    path: expectedExceptionPath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;

        expect(
          capturedException,
          contains(FailureTemplate.buildFactory(sampleFailureParam)),
        );
        expect(
          capturedException,
          contains(
            'unknown: (msg) => msg\n  ,\n    ${FailureTemplate.buildMessage(sampleFailureParam)}',
          ),
        );
        expect(
          capturedException,
          contains(
            'unknown: (_) => ProjectManagementFailure.unknown\n  ,\n    ${FailureTemplate.buildToFailure(sampleFailureParam)}',
          ),
        );
        expect(
          capturedException,
          contains(
            FailureTemplate.buildCodeResponse(sampleFailureParam).trim(),
          ),
        );
        verify(
          () => mockReportService.addInjected(expectedExceptionPath),
        ).called(1);

        // 2. Verify Failure Enum file AST injection
        final capturedFailureEnum =
            verify(
                  () => mockFileService.writeAsString(
                    path: expectedFailurePath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;

        expect(
          capturedFailureEnum,
          contains(
            'unknown\n,\n  ${FailureTemplate.buildEnumValue(sampleFailureParam)}',
          ),
        );

        verify(
          () => mockReportService.addInjected(expectedFailurePath),
        ).called(1);

        // 3. Verify Failure Extension file AST injection
        final capturedExtension =
            verify(
                  () => mockFileService.writeAsString(
                    path: expectedExtensionPath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;

        expect(
          capturedExtension,
          contains(
            '  ${FailureTemplate.buildItemLocalizeX(sampleFailureParam)},\n    _ =>',
          ),
        );
        verify(
          () => mockReportService.addInjected(expectedExtensionPath),
        ).called(1);

        // 4. Verify ARB injections
        final expectedArbEntries = FailureTemplate.buildArbEntries(
          sampleFailureParam,
        );
        final expectedEndKey = FailureTemplate.endDividerArbKey();

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

    test(
      'GIVEN existing source files already have trailing commas in when() and enum '
      'WHEN generateFailure is called '
      'THEN does not insert duplicate commas before new entries',
      () async {
        // Given
        const exceptionWithCommas = '''
class ProjectManagementException {
  const factory ProjectManagementException.unknown({required String msg}) = _Unknown;

  String get message => when(
    unknown: (msg) => msg,
  );

  ProjectManagementFailure toFailure() => when(
    unknown: (_) => ProjectManagementFailure.unknown,
  );
}
''';

        const failureEnumWithComma = '''
enum ProjectManagementFailure {
  unknown,
}
''';

        const extensionSource = '''
extension ProjectManagementFailureX on ProjectManagementFailure {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      _ => l10n.unknownError,
    };
  }
}
''';

        when(
          () => mockFileService.readAsString(expectedExceptionPath),
        ).thenAnswer((_) async => exceptionWithCommas);
        when(
          () => mockFileService.readAsString(expectedFailurePath),
        ).thenAnswer((_) async => failureEnumWithComma);
        when(
          () => mockFileService.readAsString(expectedExtensionPath),
        ).thenAnswer((_) async => extensionSource);

        // When
        await failureService.generate(
          failureParam: sampleFailureParam,
          onProgress: (_) {},
        );

        // Then
        final capturedException =
            verify(
                  () => mockFileService.writeAsString(
                    path: expectedExceptionPath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;

        expect(capturedException, isNot(contains(',,')));

        final capturedFailureEnum =
            verify(
                  () => mockFileService.writeAsString(
                    path: expectedFailurePath,
                    content: captureAny(named: 'content'),
                  ),
                ).captured.single
                as String;

        expect(capturedFailureEnum, isNot(contains(',,')));
      },
    );
  });
}
