import 'package:fsda_cli/infrastructure/services/helpers/process_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/fix_import_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockProcessService extends Mock implements ProcessService {}

void main() {
  late FixImportService fixImportService;
  late MockProcessService mockProcessService;

  const workspacePath = '/project/path';

  setUp(() {
    mockProcessService = MockProcessService();
    fixImportService = FixImportService(processService: mockProcessService);
  });

  group('FixImportService Tests', () {
    test(
      'fixImport should run dart fix with correct arguments and trigger onProgress',
      () async {
        when(
          () => mockProcessService.run(any(), any(), any()),
        ).thenAnswer((_) async => {});

        final progressLogs = <String>[];

        await fixImportService.fixImport(
          workspacePath,
          onProgress: (message) => progressLogs.add(message),
        );

        expect(progressLogs, isNotEmpty);
        expect(progressLogs.first, contains(workspacePath));

        verify(
          () => mockProcessService.run('dart', [
            'fix',
            '--apply',
            '--code=directives_ordering',
            '--code=unused_import',
          ], workspacePath),
        ).called(1);
      },
    );
  });
}
