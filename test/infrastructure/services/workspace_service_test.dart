import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/workspace_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

void main() {
  late WorkspaceService workspaceService;
  late MockOperationReportService mockReportService;
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;

  setUp(() {
    mockReportService = MockOperationReportService();
    mockDirectoryService = MockDirectoryService();
    mockFileService = MockFileService();

    workspaceService = WorkspaceService(
      reportService: mockReportService,
      directoryService: mockDirectoryService,
      fileService: mockFileService,
    );
  });

  group('WorkspaceService Tests', () {
    test(
      'generate workspace structure and configuration should execute successfully',
      () async {
        const workspaceParam = WorkspaceParam(
          name: 'my_workspace',
          path: '/workspace',
        );

        when(
          () => mockDirectoryService.create(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});
        when(() => mockReportService.addCreated(any())).thenReturn(null);

        final progressLogs = <String>[];
        await workspaceService.generate(
          workspace: workspaceParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        verify(() => mockDirectoryService.create(any())).called(3);
        verify(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).called(1);
      },
    );
  });
}
