import 'package:fsda_cli/infrastructure/services/helpers/process_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/build_runner_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockProcessService extends Mock implements ProcessService {}

void main() {
  late BuildRunnerService buildRunnerService;
  late MockProcessService mockProcessService;

  const workspacePath = '/project/path';

  setUp(() {
    mockProcessService = MockProcessService();
    buildRunnerService = BuildRunnerService(processService: mockProcessService);
  });

  group('BuildRunnerService Tests', () {
    test(
      'runBuildRunner should execute build_runner via ProcessService with correct arguments and trigger onProgress',
      () async {
        when(
          () => mockProcessService.run(any(), any(), any()),
        ).thenAnswer((_) async => {});

        final progressLogs = <String>[];

        await buildRunnerService.runBuildRunner(
          workspacePath,
          onProgress: (message) {
            progressLogs.add(message);
          },
        );

        // Memastikan callback onProgress dipanggil dengan pesan yang sesuai
        expect(progressLogs, isNotEmpty);
        expect(progressLogs.first, contains(workspacePath));

        // Memastikan ProcessService.run dipanggil dengan perintah build_runner yang tepat
        verify(
          () => mockProcessService.run('dart', [
            'run',
            'build_runner',
            'build',
            '--delete-conflicting-outputs',
            '--force-jit',
          ], workspacePath),
        ).called(1);
      },
    );

    test(
      'runBuildRunner should throw exception if ProcessService fails',
      () async {
        when(
          () => mockProcessService.run(any(), any(), any()),
        ).thenThrow(Exception('Process failed'));

        expect(
          () async => await buildRunnerService.runBuildRunner(
            workspacePath,
            onProgress: (_) {},
          ),
          throwsException,
        );
      },
    );
  });
}
