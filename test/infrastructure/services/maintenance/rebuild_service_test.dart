import 'package:fsda_cli/infrastructure/services/maintenance/build_runner_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/l10n_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/rebuild_service.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test/test.dart';

class MockBuildRunnerService extends Mock implements BuildRunnerService {}

class MockL10nService extends Mock implements L10nService {}

void main() {
  late RebuildService rebuildService;
  late MockBuildRunnerService mockBuildRunnerService;
  late MockL10nService mockL10nService;

  const workspacePath = '/project/path';

  setUp(() {
    mockBuildRunnerService = MockBuildRunnerService();
    mockL10nService = MockL10nService();

    rebuildService = RebuildService(
      buildRunnerService: mockBuildRunnerService,
      l10nService: mockL10nService,
    );
  });

  group('RebuildService Tests', () {
    test(
      'rebuild should invoke buildRunner and gen-l10n sequentially',
      () async {
        when(
          () => mockBuildRunnerService.runBuildRunner(
            any(),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockL10nService.runL10n(
            any(),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async => {});

        final progressLogs = <String>[];

        await rebuildService.rebuild(
          workspacePath,
          onProgress: (message) => progressLogs.add(message),
        );

        verify(
          () => mockBuildRunnerService.runBuildRunner(
            workspacePath,
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
        verify(
          () => mockL10nService.runL10n(
            workspacePath,
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
      },
    );
  });
}
