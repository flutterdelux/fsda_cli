import 'package:fsda_cli/core/constants/cli_info.dart';
import 'package:fsda_cli/domain/params/workspace_param.dart';
import 'package:fsda_cli/infrastructure/bundles/package_bundle.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/workspace_service.dart';
import 'package:fsda_cli/infrastructure/templates/config_template.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

void main() {
  late MockOperationReportService mockReportService;
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;
  late WorkspaceService workspaceService;

  const sampleWorkspace = WorkspaceParam(
    workspaceName: 'my_workspace',
    workspacePath: '/projects/my_workspace',
  );

  setUp(() {
    mockReportService = MockOperationReportService();
    mockDirectoryService = MockDirectoryService();
    mockFileService = MockFileService();

    workspaceService = WorkspaceService(
      reportService: mockReportService,
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
  });

  group('WorkspaceService.generate', () {
    test(
      'GIVEN valid WorkspaceParam '
      'WHEN generate is called '
      'THEN creates workspace directories, writes .fsda/config.yaml, and reports progress',
      () async {
        // Given
        final progressLogs = <String>[];
        final expectedFsdaDir = p.join(
          '/projects/my_workspace',
          CliInfo.fsdaDirName,
        );
        final expectedDirs = [
          expectedFsdaDir,
          p.join(expectedFsdaDir, CliInfo.plansDirName),
          p.join('/projects/my_workspace', 'apps'),
          p.join('/projects/my_workspace', 'modules'),
          p.join('/projects/my_workspace', 'packages'),
        ];
        final expectedConfigPath = p.join(
          expectedFsdaDir,
          CliInfo.configFileName,
        );
        final expectedConfigContent = ConfigTemplate.buildConfig(
          workspaceName: 'my_workspace',
          packages: packageBundle.keys.toList(),
        );

        // When
        await workspaceService.generate(
          workspace: sampleWorkspace,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Creating directory structures...',
          'Generating ${CliInfo.fsdaDirName}/${CliInfo.configFileName} configuration...',
        ]);

        for (final dirPath in expectedDirs) {
          verify(() => mockDirectoryService.create(dirPath)).called(1);
          verify(() => mockReportService.addCreated(dirPath)).called(1);
        }

        verify(
          () => mockFileService.writeAsString(
            path: expectedConfigPath,
            content: expectedConfigContent,
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(expectedConfigPath),
        ).called(1);
      },
    );
  });
}
