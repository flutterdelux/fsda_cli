import 'dart:io';
import 'package:fsda_cli/infrastructure/services/helpers/directory_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/mason_generator_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDirectoryService extends Mock implements DirectoryService {}

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockMasonGenerator extends Mock implements MasonGenerator {}

class FakeMasonBundle extends Fake implements MasonBundle {}

class TestableMasonGeneratorService extends MasonGeneratorService {
  final MasonGenerator generatorToReturn;

  const TestableMasonGeneratorService({
    required super.directoryService,
    required super.reportService,
    required this.generatorToReturn,
  });

  @override
  Future<MasonGenerator> createGenerator(MasonBundle bundle) async {
    return generatorToReturn;
  }
}

void main() {
  group('MasonGeneratorService', () {
    late MockDirectoryService mockDirectoryService;
    late MockOperationReportService mockReportService;
    late MockMasonGenerator mockGenerator;
    late Directory tempDir;

    setUpAll(() {
      registerFallbackValue(FakeMasonBundle());
      registerFallbackValue(DirectoryGeneratorTarget(Directory('.')));
    });

    setUp(() {
      mockDirectoryService = MockDirectoryService();
      mockReportService = MockOperationReportService();
      mockGenerator = MockMasonGenerator();
      tempDir = Directory.systemTemp.createTempSync('fsda_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    const tTargetPath = '/workspace/modules/todo';
    const tVars = {'module': 'todo', 'dart_sdk': '3.0.0'};
    final tBundle = MasonBundle.fromJson({
      'name': 'test_bundle',
      'description': 'A test bundle',
      'version': '0.1.0',
      'files': [],
    });

    test(
      'Given valid generated files including freezed, gitkeep, and normal files, '
      'When generate is called successfully, '
      'Then it processes files correctly and reports created paths',
      () async {
        // Arrange (Given)
        when(() => mockDirectoryService.dirOf(tTargetPath)).thenReturn(tempDir);

        // Simulasi file yang dihasilkan generator mencakup semua kondisi cabang kode
        final generatedFiles = [
          GeneratedFile.created(path: '${tempDir.path}/lib/todo.dart'),
          GeneratedFile.created(
            path: '${tempDir.path}/lib/todo.freezed.dart',
          ), // Harus di-skip
          GeneratedFile.created(
            path: '${tempDir.path}/lib/.gitkeep',
          ), // Harus mencatat parent folder-nya
          GeneratedFile.created(
            path: '${tempDir.path}/lib/todo_model.g.dart',
          ), // Harus di-skip
        ];

        when(
          () => mockGenerator.generate(any(), vars: any(named: 'vars')),
        ).thenAnswer((_) async => generatedFiles);

        when(() => mockReportService.addCreated(any())).thenReturn(null);

        final service = TestableMasonGeneratorService(
          directoryService: mockDirectoryService,
          reportService: mockReportService,
          generatorToReturn: mockGenerator,
        );

        // Act (When)
        await service.generate(
          bundle: tBundle,
          targetPath: tTargetPath,
          vars: tVars,
        );

        // Assert (Then)
        verify(() => mockDirectoryService.dirOf(tTargetPath)).called(1);
        verify(() => mockGenerator.generate(any(), vars: tVars)).called(1);
        verify(
          () => mockReportService.addCreated('${tempDir.path}/lib/todo.dart'),
        ).called(1);
        verify(
          () => mockReportService.addCreated('${tempDir.path}/lib'),
        ).called(1); // Untuk .gitkeep parent folder
        verifyNever(
          () => mockReportService.addCreated(
            '${tempDir.path}/lib/todo.freezed.dart',
          ),
        );
        verifyNever(
          () => mockReportService.addCreated(
            '${tempDir.path}/lib/todo_model.g.dart',
          ),
        );
      },
    );

    test('Given an invalid or unreadable mason bundle, '
        'When generate is called, '
        'Then it catches the error and throws a wrapped Exception', () async {
      // Arrange (Given)
      when(() => mockDirectoryService.dirOf(tTargetPath)).thenReturn(tempDir);

      final service = MasonGeneratorService(
        directoryService: mockDirectoryService,
        reportService: mockReportService,
      );

      final invalidBundle = MasonBundle.fromJson({
        'name': 'invalid',
        'description': 'invalid',
        'version': '0.1.0',
        'files': [],
      });

      // Act & Assert (When & Then)
      expect(
        () => service.generate(
          bundle: invalidBundle,
          targetPath: tTargetPath,
          vars: tVars,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
