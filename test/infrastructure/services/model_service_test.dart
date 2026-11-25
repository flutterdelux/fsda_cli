import 'package:fsda_cli/core/extensions/feature_param_x.dart';
import 'package:fsda_cli/core/extensions/model_param_x.dart';
import 'package:fsda_cli/domain/enums/model_type.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/model_param.dart';
import 'package:fsda_cli/infrastructure/services/helpers/arb_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/export_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/file_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_resolver_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/import_service.dart';
import 'package:fsda_cli/infrastructure/services/helpers/operation_report_service.dart';
import 'package:fsda_cli/infrastructure/services/model_service.dart';
import 'package:fsda_cli/infrastructure/templates/feature_template.dart';
import 'package:fsda_cli/infrastructure/templates/model_template.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class MockOperationReportService extends Mock
    implements OperationReportService {}

class MockExportService extends Mock implements ExportService {}

class MockArbService extends Mock implements ArbService {}

class MockFileService extends Mock implements FileService {}

class MockImportResolverService extends Mock implements ImportResolverService {}

class MockImportService extends Mock implements ImportService {}

void main() {
  late MockOperationReportService mockReportService;
  late MockExportService mockExportService;
  late MockArbService mockArbService;
  late MockFileService mockFileService;
  late MockImportResolverService mockImportResolverService;
  late MockImportService mockImportService;
  late ModelService modelService;

  const workspacePath = '/projects/my_workspace';
  const moduleName = 'project_management';
  const featureName = 'task';

  const sampleProps = [
    PropModel(type: 'String', name: 'title', defaultValue: "''", converter: ''),
    PropModel(
      type: 'DateTime',
      name: 'due_date',
      defaultValue: 'null',
      converter: 'UtcDateTimeConverter',
    ),
  ];

  ModelParam createModelParam({
    required String modelName,
    required ModelType modelType,
    List<PropModel> props = sampleProps,
    bool isInjectL10n = false,
  }) {
    return ModelParam(
      type: modelType,
      modelName: modelName,
      props: props,
      isL10n: isInjectL10n,
      featureName: featureName,
      moduleName: moduleName,
      workspaceName: 'my_workspace',
      workspacePath: workspacePath,
    );
  }

  final expectedModulePath = p.join(workspacePath, 'modules', moduleName);
  final arbPaths = [
    p.join(expectedModulePath, 'lib', 'l10n', 'app_en.arb'),
    p.join(expectedModulePath, 'lib', 'l10n', 'app_id.arb'),
  ];

  setUp(() {
    mockReportService = MockOperationReportService();
    mockExportService = MockExportService();
    mockArbService = MockArbService();
    mockFileService = MockFileService();
    mockImportResolverService = MockImportResolverService();
    mockImportService = MockImportService();

    modelService = ModelService(
      reportService: mockReportService,
      exportService: mockExportService,
      arbService: mockArbService,
      fileService: mockFileService,
      importResolverService: mockImportResolverService,
      importService: mockImportService,
    );

    when(
      () => mockFileService.writeAsString(
        path: any(named: 'path'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockFileService.delete(any())).thenAnswer((_) async {});
    when(
      () => mockImportResolverService.resolve(
        rawTypes: any(named: 'rawTypes'),
        targetFilePath: any(named: 'targetFilePath'),
        modulePath: any(named: 'modulePath'),
      ),
    ).thenAnswer((_) async => {"import 'package:app_core/app_core.dart';"});
    when(
      () => mockImportService.injectImport(
        path: any(named: 'path'),
        imports: any(named: 'imports'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockExportService.inject(
        barrelPath: any(named: 'barrelPath'),
        exportLines: any(named: 'exportLines'),
        checkpoint: any(named: 'checkpoint'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockExportService.unject(
        barrelPath: any(named: 'barrelPath'),
        exportLines: any(named: 'exportLines'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockArbService.getArbPaths(expectedModulePath),
    ).thenAnswer((_) async => arbPaths);
    when(
      () => mockArbService.injectEntriesBeforeKey(
        arbPath: any(named: 'arbPath'),
        arbEntries: any(named: 'arbEntries'),
        endKey: any(named: 'endKey'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockArbService.unjectEntries(
        arbPath: any(named: 'arbPath'),
        arbEntries: any(named: 'arbEntries'),
      ),
    ).thenAnswer((_) async {});
  });

  group('ModelService.generateModel', () {
    test(
      'GIVEN an entity ModelParam with isInjectL10n true and existing barrel '
      'WHEN generateModel is called '
      'THEN creates entity file, resolves prop and converter imports, exports to barrel, and injects ARB entries',
      () async {
        // Given
        final progressLogs = <String>[];
        final entityParam = createModelParam(
          modelName: 'task_entity',
          modelType: .entity,
          isInjectL10n: true,
        );

        when(
          () => mockFileService.exists(entityParam.featureBarrelPath),
        ).thenAnswer((_) async => true);

        // When
        await modelService.generate(
          model: entityParam,
          onProgress: progressLogs.add,
        );

        // Then
        expect(progressLogs, [
          'Creating model file...',
          'Injecting import for class that use in model...',
          'Injecting export model to feature barrel...',
          'Injecting localization keys into ARB files...',
        ]);

        // 1. Verify file creation
        verify(
          () => mockFileService.writeAsString(
            path: entityParam.modelPath,
            content: ModelTemplate.buildEntity(entityParam),
          ),
        ).called(1);
        verify(
          () => mockReportService.addCreated(entityParam.modelPath),
        ).called(1);

        // 2. Verify import resolution (includes prop types + non-empty converters)
        verify(
          () => mockImportResolverService.resolve(
            rawTypes: {'String', 'DateTime', 'UtcDateTimeConverter'},
            targetFilePath: entityParam.modelPath,
            modulePath: expectedModulePath,
          ),
        ).called(1);
        verify(
          () => mockImportService.injectImport(
            path: entityParam.modelPath,
            imports: any(named: 'imports'),
          ),
        ).called(1);

        // 3. Verify barrel export injection
        verify(
          () => mockExportService.inject(
            barrelPath: entityParam.featureBarrelPath,
            exportLines: ["export 'domain/entities/task_entity.dart';"],
            checkpoint: '// domain',
          ),
        ).called(1);
        verify(
          () => mockReportService.addInjected(entityParam.featureBarrelPath),
        ).called(1);

        // 4. Verify ARB injection
        final expectedArbEntries = ModelTemplate.buildArbEntries(entityParam);
        final expectedEndKey = FeatureTemplate.endDividerArbKey(featureName);
        for (final arbPath in arbPaths) {
          verify(
            () => mockArbService.injectEntriesBeforeKey(
              arbPath: arbPath,
              arbEntries: expectedArbEntries,
              endKey: expectedEndKey,
            ),
          ).called(1);
          verify(() => mockReportService.addInjected(arbPath)).called(1);
        }
      },
    );

    test(
      'GIVEN a param ModelParam with isInjectL10n true and missing barrel '
      'WHEN generateModel is called '
      'THEN creates param file, skips barrel export when barrel does not exist, and skips ARB injection',
      () async {
        // Given
        final paramModel = createModelParam(
          modelName: 'task_create_param',
          modelType: .param,
          isInjectL10n: true,
        );

        when(
          () => mockFileService.exists(paramModel.featureBarrelPath),
        ).thenAnswer((_) async => false);

        // When
        await modelService.generate(model: paramModel, onProgress: (_) {});

        // Then
        verify(
          () => mockFileService.writeAsString(
            path: paramModel.modelPath,
            content: ModelTemplate.buildParam(paramModel),
          ),
        ).called(1);
        verifyNever(
          () => mockExportService.inject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
            checkpoint: any(named: 'checkpoint'),
          ),
        );
        verifyNever(() => mockArbService.getArbPaths(any()));
      },
    );

    test(
      'GIVEN dto, request, and response ModelParams '
      'WHEN generateModel is called '
      'THEN builds corresponding templates and skips barrel export and ARB injection',
      () async {
        // Given
        final dtoParam = createModelParam(
          modelName: 'task_dto',
          modelType: .dto,
        );
        final requestParam = createModelParam(
          modelName: 'task_request',
          modelType: .request,
        );
        final responseParam = createModelParam(
          modelName: 'task_response',
          modelType: .response,
        );

        // When
        await modelService.generate(model: dtoParam, onProgress: (_) {});
        await modelService.generate(model: requestParam, onProgress: (_) {});
        await modelService.generate(model: responseParam, onProgress: (_) {});

        // Then
        verify(
          () => mockFileService.writeAsString(
            path: dtoParam.modelPath,
            content: ModelTemplate.buildDto(dtoParam),
          ),
        ).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: requestParam.modelPath,
            content: ModelTemplate.buildRequest(requestParam),
          ),
        ).called(1);
        verify(
          () => mockFileService.writeAsString(
            path: responseParam.modelPath,
            content: ModelTemplate.buildResponse(responseParam),
          ),
        ).called(1);
        verifyNever(
          () => mockExportService.inject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
            checkpoint: any(named: 'checkpoint'),
          ),
        );
        verifyNever(() => mockArbService.getArbPaths(any()));
      },
    );
  });
  group('ModelService.removeModel', () {
    test(
      'GIVEN an entity ModelParam where .dart, .freezed.dart, and .g.dart exist '
      'WHEN removeModel is called '
      'THEN deletes main and generated files, unjects barrel export, and unjects ARB entries',
      () async {
        // Given
        final progressLogs = [];
        final entityParam = createModelParam(
          modelName: 'task_entity',
          modelType: .entity,
        );
        final freezedPath = entityParam.modelPath.replaceAll(
          '.dart',
          '.freezed.dart',
        );
        final gPath = entityParam.modelPath.replaceAll('.dart', '.g.dart');
        when(
          () => mockFileService.exists(entityParam.modelPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.exists(freezedPath),
        ).thenAnswer((_) async => true);
        when(() => mockFileService.exists(gPath)).thenAnswer((_) async => true);
        // When
        await modelService.remove(
          model: entityParam,
          onProgress: progressLogs.add,
        );
        // Then
        expect(progressLogs, [
          'Removing model file...',
          'Unjecting export model from feature barrel...',
          'Unjecting localization model...',
        ]);
        verify(() => mockFileService.delete(entityParam.modelPath)).called(1);
        verify(
          () => mockReportService.addRemoved(entityParam.modelPath),
        ).called(1);
        verify(() => mockFileService.delete(freezedPath)).called(1);
        verify(() => mockFileService.delete(gPath)).called(1);
        verify(
          () => mockExportService.unject(
            barrelPath: entityParam.featureBarrelPath,
            exportLines: ["export 'domain/entities/task_entity.dart';"],
          ),
        ).called(1);
        verify(
          () => mockReportService.addUnjected(entityParam.featureBarrelPath),
        ).called(1);
        final expectedArbEntries = ModelTemplate.buildArbEntries(entityParam);
        for (final arbPath in arbPaths) {
          verify(
            () => mockArbService.unjectEntries(
              arbPath: arbPath,
              arbEntries: expectedArbEntries,
            ),
          ).called(1);
          verify(() => mockReportService.addUnjected(arbPath)).called(1);
        }
      },
    );
    test(
      'GIVEN a dto ModelParam where generated files do not exist '
      'WHEN removeModel is called '
      'THEN deletes only main file and skips barrel and ARB unjection',
      () async {
        // Given
        final dtoParam = createModelParam(
          modelName: 'task_dto',
          modelType: .dto,
        );
        final freezedPath = dtoParam.modelPath.replaceAll(
          '.dart',
          '.freezed.dart',
        );
        final gPath = dtoParam.modelPath.replaceAll('.dart', '.g.dart');
        when(
          () => mockFileService.exists(dtoParam.modelPath),
        ).thenAnswer((_) async => true);
        when(
          () => mockFileService.exists(freezedPath),
        ).thenAnswer((_) async => false);
        when(
          () => mockFileService.exists(gPath),
        ).thenAnswer((_) async => false);
        // When
        await modelService.remove(model: dtoParam, onProgress: (_) {});
        // Then
        verify(() => mockFileService.delete(dtoParam.modelPath)).called(1);
        verifyNever(() => mockFileService.delete(freezedPath));
        verifyNever(() => mockFileService.delete(gPath));
        verifyNever(
          () => mockExportService.unject(
            barrelPath: any(named: 'barrelPath'),
            exportLines: any(named: 'exportLines'),
          ),
        );
        verifyNever(() => mockArbService.getArbPaths(any()));
      },
    );
  });
  group('ModelService.getPropsFromModelFile', () {
    test('GIVEN model file does not exist '
        'WHEN getPropsFromModelFile is called '
        'THEN returns empty list', () async {
      // Given
      const path = '/projects/my_workspace/missing_model.dart';
      when(() => mockFileService.exists(path)).thenAnswer((_) async => false);
      // When
      final result = await modelService.getPropsFromModelFile(path);
      // Then
      expect(result, isEmpty);
      verifyNever(() => mockFileService.readAsString(any()));
    });
    test(
      'GIVEN valid Dart model source file '
      'WHEN getPropsFromModelFile is called '
      'THEN parses AST via ModelVisitor and returns extracted PropModel list',
      () async {
        // Given
        const path = '/projects/my_workspace/task_entity.dart';
        const modelSource = '''
import 'package:freezed_annotation/freezed_annotation.dart';
part 'task_entity.freezed.dart';
@freezed
abstract class TaskEntity with \$TaskEntity {
const factory TaskEntity({
required String id,
@Default('') String title,
@UtcDateTimeConverter() DateTime? createdAt,
}) = TaskEntity;
}
''';
        when(() => mockFileService.exists(path)).thenAnswer((_) async => true);
        when(
          () => mockFileService.readAsString(path),
        ).thenAnswer((_) async => modelSource);
        // When
        final result = await modelService.getPropsFromModelFile(path);
        // Then
        expect(result, hasLength(3));
        expect(result[0].name, 'id');
        expect(result[0].type, 'String');
        expect(result[1].name, 'title');
        expect(result[1].defaultValue, '');
        expect(result[2].name, 'created_at');
        expect(result[2].type, 'DateTime?');
        expect(result[2].converter, '');
      },
    );
    test('GIVEN malformed Dart file that causes parseString to throw '
        'WHEN getPropsFromModelFile is called '
        'THEN catches error and returns empty list safely', () async {
      // Given
      const path = '/projects/my_workspace/broken_model.dart';
      when(() => mockFileService.exists(path)).thenAnswer((_) async => true);
      when(
        () => mockFileService.readAsString(path),
      ).thenAnswer((_) async => 'class Broken { invalid syntax ===');
      // When
      final result = await modelService.getPropsFromModelFile(path);
      // Then
      expect(result, isEmpty);
    });
  });
}
