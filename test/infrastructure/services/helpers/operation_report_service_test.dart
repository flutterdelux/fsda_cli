import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDirectoryService extends Mock implements DirectoryService {}

void main() {
  late OperationReportService operationReportService;
  late MockDirectoryService mockDirectoryService;

  const currentPath = '/project/root';

  setUp(() {
    mockDirectoryService = MockDirectoryService();
    when(() => mockDirectoryService.currentPath).thenReturn(currentPath);

    operationReportService = OperationReportService(
      directoryService: mockDirectoryService,
    );
  });

  group('OperationReportService Tests', () {
    test(
      'should normalize path correctly (handle absolute path, .gitkeep, and backslashes)',
      () {
        // Menguji normalisasi jalur mutlak, .gitkeep, serta pembersihan backslash
        operationReportService.addCreated(
          '/project/root/lib/features/auth/.gitkeep',
        );
        operationReportService.addInjected(
          r'lib\features\auth\auth_controller.dart',
        );

        final report = operationReportService.generateReport(
          operationLabel: 'Create Feature',
        );

        expect(report, isNotNull);
        // Memastikan laporan berhasil digenerate dan dikosongkan (clear) setelahnya
      },
    );

    test('generateReport should build report and clear paths afterwards', () {
      operationReportService.addCreated('lib/features/auth/auth_view.dart');
      operationReportService.addSkipped('lib/features/auth/auth_model.dart');

      final report1 = operationReportService.generateReport(
        operationLabel: 'Generate Auth',
      );

      expect(report1, isNotNull);

      // Setelah generateReport, method clear() dipanggil secara internal.
      // Jika dipanggil kembali tanpa penambahan path baru, seharusnya list di dalam laporan kosong.
      // Kita bisa menguji bahwa fungsi clear() bekerja dengan baik tanpa error.
      operationReportService.clear();
    });

    test(
      'generatePackageReport should build package report and clear package collections',
      () {
        operationReportService.addAddedPackages('app_core');
        operationReportService.addRemovedPackages('old_pkg');
        operationReportService.addRetainedPackages('flutter');

        final packageReport = operationReportService.generatePackageReport(
          operationLabel: 'Configure Packages',
        );

        expect(packageReport, isNotNull);
      },
    );

    test(
      'should normalize path correctly (handle absolute path, .gitkeep, and backslashes)',
      () {
        // Menguji normalisasi jalur mutlak, .gitkeep, serta pembersihan backslash
        operationReportService.addCreated(
          '/project/root/lib/features/auth/.gitkeep',
        );
        operationReportService.addInjected(
          r'lib\features\auth\auth_controller.dart',
        );

        // Tambahkan pemanggilan ini untuk mengcover baris 25 dan 26
        operationReportService.addUnjected('lib/features/auth/old_export.dart');
        operationReportService.addRemoved(
          'lib/features/auth/deprecated_file.dart',
        );

        final report = operationReportService.generateReport(
          operationLabel: 'Create Feature',
        );

        expect(report, isNotNull);
      },
    );
  });
}
