import 'package:fsda_cli/infrastructure/services/helpers/process_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/l10n_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockProcessService extends Mock implements ProcessService {}

void main() {
  late L10nService l10nService;
  late MockProcessService mockProcessService;

  const workspacePath = '/project/path';

  setUp(() {
    mockProcessService = MockProcessService();
    l10nService = L10nService(processService: mockProcessService);
  });

  group('L10nService Tests', () {
    test(
      'runL10n should run flutter gen-l10n and trigger onProgress',
      () async {
        when(
          () => mockProcessService.run(any(), any(), any()),
        ).thenAnswer((_) async => {});

        final progressLogs = <String>[];

        await l10nService.runL10n(
          workspacePath,
          onProgress: (message) => progressLogs.add(message),
        );

        expect(progressLogs, isNotEmpty);
        expect(progressLogs.first, contains(workspacePath));

        verify(
          () => mockProcessService.run('flutter', ['gen-l10n'], workspacePath),
        ).called(1);
      },
    );
  });
}
