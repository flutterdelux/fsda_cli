import 'dart:io';

import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/infrastructure/services/feature_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockExportService extends Mock implements ExportService {}

class MockDirectoryService extends Mock implements DirectoryService {}

class MockFileService extends Mock implements FileService {}

class MockArbService extends Mock implements ArbService {}

void main() {
  late FeatureService featureService;
  late MockOperationReportService mockReportService;
  late MockExportService mockExportService;
  late MockDirectoryService mockDirectoryService;
  late MockFileService mockFileService;
  late MockArbService mockArbService;

  setUp(() {
    mockReportService = MockOperationReportService();
    mockExportService = MockExportService();
    mockDirectoryService = MockDirectoryService();
    mockFileService = MockFileService();
    mockArbService = MockArbService();

    featureService = FeatureService(
      reportService: mockReportService,
      exportService: mockExportService,
      directoryService: mockDirectoryService,
      fileService: mockFileService,
      arbService: mockArbService,
    );
  });

  group('FeatureService Tests', () {
    const featureParam = FeatureParam(
      name: 'auth',
      path: '/modules/auth/lib/src/features/auth',
      moduleName: 'auth',
      modulePath: '/modules/auth',
    );

    test(
      'generateFeature should execute full feature generation pipeline successfully',
      () async {
        when(
          () => mockDirectoryService.create(any()),
        ).thenAnswer((_) async => Directory(''));
        when(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockExportService.inject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
            checkpoint: any(named: 'checkpoint'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockArbService.getArbPaths(any()),
        ).thenAnswer((_) async => ['/project/lib/l10n/app_en.arb']);
        when(
          () => mockArbService.injectBySnippet(
            arbPath: any(named: 'arbPath'),
            arbSnippet: any(named: 'arbSnippet'),
          ),
        ).thenAnswer((_) async => {});

        when(() => mockReportService.addCreated(any())).thenReturn(null);
        when(() => mockReportService.addInjected(any())).thenReturn(null);

        final progressLogs = <String>[];

        await featureService.generateFeature(
          feature: featureParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        expect(progressLogs.first, contains('Creating feature directory'));

        verify(
          () => mockDirectoryService.create(any()),
        ).called(14); // 1 main + 13 subdirs
        verify(
          () => mockFileService.writeAsString(
            path: any(named: 'path'),
            content: any(named: 'content'),
          ),
        ).called(3); // barrel + repo interface + repo impl
        verify(
          () => mockExportService.inject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
            checkpoint: any(named: 'checkpoint'),
          ),
        ).called(3); // interface repo, impl repo, module barrel export
        verify(() => mockArbService.getArbPaths(any())).called(1);
        verify(
          () => mockArbService.injectBySnippet(
            arbPath: any(named: 'arbPath'),
            arbSnippet: any(named: 'arbSnippet'),
          ),
        ).called(1);
      },
    );

    test(
      'removeFeature should execute full removal pipeline successfully when barrel exists',
      () async {
        when(() => mockDirectoryService.delete(any())).thenAnswer((_) async {});
        when(() => mockFileService.exists(any())).thenAnswer((_) async => true);
        when(
          () => mockExportService.unject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockArbService.getArbPaths(any()),
        ).thenAnswer((_) async => ['/project/lib/l10n/app_en.arb']);
        when(
          () => mockArbService.unjectBetweenKeys(
            arbPath: any(named: 'arbPath'),
            startKey: any(named: 'startKey'),
            endKey: any(named: 'endKey'),
          ),
        ).thenAnswer((_) async => {});

        when(() => mockReportService.addRemoved(any())).thenReturn(null);
        when(() => mockReportService.addUnjected(any())).thenReturn(null);

        final progressLogs = <String>[];

        await featureService.removeFeature(
          feature: featureParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);
        expect(progressLogs.first, contains('Removing feature'));

        verify(() => mockDirectoryService.delete(any())).called(1);
        verify(() => mockFileService.exists(any())).called(1);
        verify(
          () => mockExportService.unject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
          ),
        ).called(1);
        verify(() => mockArbService.getArbPaths(any())).called(1);
        verify(
          () => mockArbService.unjectBetweenKeys(
            arbPath: any(named: 'arbPath'),
            startKey: any(named: 'startKey'),
            endKey: any(named: 'endKey'),
          ),
        ).called(1);
      },
    );

    test(
      'removeFeature should skip unjecting export when barrel does not exist',
      () async {
        when(
          () => mockDirectoryService.delete(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockFileService.exists(any()),
        ).thenAnswer((_) async => false);
        when(
          () => mockArbService.getArbPaths(any()),
        ).thenAnswer((_) async => ['/project/lib/l10n/app_en.arb']);
        when(
          () => mockArbService.unjectBetweenKeys(
            arbPath: any(named: 'arbPath'),
            startKey: any(named: 'startKey'),
            endKey: any(named: 'endKey'),
          ),
        ).thenAnswer((_) async => {});

        when(() => mockReportService.addRemoved(any())).thenReturn(null);
        when(() => mockReportService.addUnjected(any())).thenReturn(null);

        final progressLogs = <String>[];

        await featureService.removeFeature(
          feature: featureParam,
          onProgress: (msg) => progressLogs.add(msg),
        );

        expect(progressLogs, isNotEmpty);

        verify(() => mockDirectoryService.delete(any())).called(1);
        verify(() => mockFileService.exists(any())).called(1);
        verifyZeroInteractions(mockExportService);
        verify(() => mockArbService.getArbPaths(any())).called(1);
      },
    );
  });
}
