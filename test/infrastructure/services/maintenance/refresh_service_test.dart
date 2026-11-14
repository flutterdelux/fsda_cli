import 'package:fsda_cli/infrastructure/services/helpers/process_service.dart';
import 'package:fsda_cli/infrastructure/services/maintenance/refresh_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockProcessService extends Mock implements ProcessService {}

void main() {
  late RefreshService refreshService;
  late MockProcessService mockProcessService;

  const workspacePath = '/project/path';

  setUp(() {
    mockProcessService = MockProcessService();
    refreshService = RefreshService(processService: mockProcessService);
  });

  group('RefreshService Tests', () {
    test(
      'refresh should run flutter clean and flutter pub get sequentially',
      () async {
        when(
          () => mockProcessService.run(any(), any(), any()),
        ).thenAnswer((_) async => {});

        final progressLogs = <String>[];

        await refreshService.refresh(
          workspacePath,
          onProgress: (message) => progressLogs.add(message),
        );

        expect(progressLogs.length, 2);

        verify(
          () => mockProcessService.run('flutter', ['clean'], workspacePath),
        ).called(1);
        verify(
          () =>
              mockProcessService.run('flutter', ['pub', 'get'], workspacePath),
        ).called(1);
      },
    );
  });
}
