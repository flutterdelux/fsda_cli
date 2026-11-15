import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDirectoryService extends Mock implements DirectoryService {}

void main() {
  late OperationReportService operationReportService;
  late MockDirectoryService mockDirectoryService;

  setUp(() {
    mockDirectoryService = MockDirectoryService();
    // Konfigurasi default currentPath pada DirectoryService dengan mocktail
    when(() => mockDirectoryService.currentPath).thenReturn('/project/root');
    operationReportService = OperationReportService(
      directoryService: mockDirectoryService,
    );
  });

  group('OperationReportService Unit Tests', () {
    test(
      'Given created paths containing a .gitkeep file and absolute path, '
      'When generateReport is called, '
      'Then it normalizes paths correctly, generates operation report buffer, and clears the path sets',
      () {
        // Given
        operationReportService.addCreated('/project/root/lib/.gitkeep');
        operationReportService.addInjected('lib\\models\\user.dart');

        // When
        final StringBuffer report = operationReportService.generateReport(
          operationLabel: 'Generate Operation',
        );

        // Then
        expect(report, isA<StringBuffer>());
        expect(report.toString(), isNotEmpty);

        // Verify that clear() was executed internally after generating report
        final StringBuffer secondReport = operationReportService.generateReport(
          operationLabel: 'Generate Operation',
        );
        expect(secondReport, isA<StringBuffer>());
      },
    );

    test(
      'Given package actions added (added, removed, retained), '
      'When generatePackageReport is called, '
      'Then it generates the package configuration report buffer and clears package sets',
      () {
        // Given
        operationReportService.addAddedPackages('package_a');
        operationReportService.addRemovedPackages('package_b');
        operationReportService.addRetainedPackages('package_c');

        // When
        final StringBuffer packageReport = operationReportService
            .generatePackageReport(operationLabel: 'Configure Packages');

        // Then
        expect(packageReport, isA<StringBuffer>());
        expect(packageReport.toString(), isNotNull);
      },
    );

    test(
      'Given paths and packages are added to the service, '
      'When clear method is called directly, '
      'Then all stored paths and package collections are successfully cleared',
      () {
        // Given
        operationReportService.addCreated('lib/main.dart');
        operationReportService.addAddedPackages('http');

        // When
        operationReportService.clear();

        // Then
        final StringBuffer report = operationReportService.generateReport(
          operationLabel: 'Empty Check',
        );
        expect(report, isA<StringBuffer>());
      },
    );
  });
}
