import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../models/generation/typed_prop.dart';
import '../../services/file_service.dart';
import '../../services/logger_service.dart';
import '../../services/modelling/model_type_resolver_service.dart';
import '../../services/operation_report_service.dart';

const _entityDtoPostHooks = [
  'dart run build_runner build --delete-conflicting-outputs --force-jit',
];

class EntityDtoGenerator {
  final LoggerService logger;
  final FileService fileService;
  final OperationReportService report;

  EntityDtoGenerator({
    required this.logger,
    required this.fileService,
    required this.report,
  });

  Future<Map<String, dynamic>> generate(
    ({
      String prefix,
      String feature,
      String module,
      List<TypedProp> props,
      bool strict,
    })
    args,
  ) async {
    final prefix = args.prefix;
    final feature = args.feature;
    final module = args.module;
    final props = args.props;
    final strict = args.strict;
    final featureRoot = p.join(
      Directory.current.path,
      'modules',
      module,
      'lib',
      'src',
      'features',
      feature,
    );
    final barrelPath = p.join(featureRoot, '${feature.snakeCase}_feature.dart');
    if (!await File(barrelPath).exists()) {
      logger.error('Feature barrel file not found at: $barrelPath');
      exitCode = 1;
      return <String, dynamic>{'success': false};
    }

    final progress = logger.progress(
      'Baking Entity & DTO "$prefix" in memory...',
    );
    try {
      final entityNameSnake = '${prefix}_entity';
      final entityNamePascal = entityNameSnake.pascalCase;
      final dtoNameSnake = '${prefix}_dto';
      final dtoNamePascal = dtoNameSnake.pascalCase;
      final typeResolution = await const ModelTypeResolverService().resolve(
        featureRoot: featureRoot,
        props: props,
      );
      final files = <String, List<int>>{
        'domain/entities/$entityNameSnake.dart': utf8.encode(
          _buildEntitySource(
            nameSnake: entityNameSnake,
            namePascal: entityNamePascal,
            props: props,
            typeImports: typeResolution.importsFor(
              fromDirectory: p.join(featureRoot, 'domain', 'entities'),
              excluding: <String>{entityNamePascal},
            ),
          ),
        ),
        'data/dtos/$dtoNameSnake.dart': utf8.encode(
          _buildDtoSource(
            nameSnake: dtoNameSnake,
            namePascal: dtoNamePascal,
            modelNameSnake: prefix,
            modelNamePascal: prefix.pascalCase,
            props: props,
            typeImports: typeResolution.importsFor(
              fromDirectory: p.join(featureRoot, 'data', 'dtos'),
              excluding: <String>{entityNamePascal},
            ),
            enumConverterTypes: typeResolution.enumConverterTypes,
          ),
        ),
      };

      progress.update('Writing Entity & DTO artifacts...');
      final writeResult = await fileService.generateTemplate(
        path: featureRoot,
        files: files,
        failOnExisting: strict,
      );
      report.addCreatedTemplateFiles(
        targetRoot: featureRoot,
        relativeFiles: writeResult.writtenFiles,
      );
      report.addSkippedTemplateFiles(
        targetRoot: featureRoot,
        relativeFiles: writeResult.skippedFiles,
      );
      if (writeResult.skippedCount > 0 && strict) {
        logger.error(
          'Strict mode: generation aborted because some files already exist.',
        );
        exitCode = 1;
        return <String, dynamic>{'success': false};
      }

      await _injectFeatureBarrelExports(
        path: barrelPath,
        nameSnake: entityNameSnake,
      );
      progress.complete('Entity & DTO "$prefix" successfully generated.');
      return <String, dynamic>{
        'success': true,
        if (writeResult.writtenCount > 0) 'post_hook': _entityDtoPostHooks,
        'working_directory': p.join(Directory.current.path, 'modules', module),
      };
    } catch (e) {
      progress.fail('Failed to generate Entity & DTO "$prefix": $e');
      exitCode = 1;
      return <String, dynamic>{'success': false};
    }
  }

  String _buildEntitySource({
    required String nameSnake,
    required String namePascal,
    required List<TypedProp> props,
    required List<String> typeImports,
  }) {
    final referencedTypes = _collectReferencedTypes(props);
    final requiresAppCore = referencedTypes.contains('NetworkFile');

    final packageImports = <String>[
      if (requiresAppCore) "import 'package:app_core/app_core.dart';",
      "import 'package:freezed_annotation/freezed_annotation.dart';",
    ].join('\n');
    final imports = typeImports.toList(growable: false)..sort();

    final fieldLines = props.map(_buildFieldLine).join('\n');

    return '''$packageImports
  ${imports.isEmpty ? '' : '\n${imports.join('\n')}'}

part '$nameSnake.freezed.dart';

@freezed
abstract class $namePascal with _\$$namePascal {
  const factory $namePascal({
$fieldLines
  }) = _$namePascal;
}
''';
  }

  String _buildDtoSource({
    required String nameSnake,
    required String namePascal,
    required String modelNameSnake,
    required String modelNamePascal,
    required List<TypedProp> props,
    required List<String> typeImports,
    required Set<String> enumConverterTypes,
  }) {
    final referencedTypes = _collectReferencedTypes(props);
    final requiresAppCore =
        props.any((p) => p.typeWithoutNullability == 'DateTime') ||
        referencedTypes.contains('NetworkFile');

    final packageImports = <String>[
      if (requiresAppCore) "import 'package:app_core/app_core.dart';",
      "import 'package:freezed_annotation/freezed_annotation.dart';",
    ].join('\n');
    final imports = <String>{
      "import '../../domain/entities/${modelNameSnake}_entity.dart';",
      ...typeImports.where(
        (directive) => !directive.endsWith("/${modelNameSnake}_entity.dart';"),
      ),
      ...enumConverterTypes.map(
        (type) => "import '../converters/${type.snakeCase}_converter.dart';",
      ),
    }.toList()..sort();

    final fieldLines = props
        .map(
          (prop) => _buildFieldLineWithConverter(
            prop: prop,
            enumConverterTypes: enumConverterTypes,
          ),
        )
        .join('\n');
    final toEntityAssignments = props
        .map(
          (prop) =>
              '      ${prop.name.camelCase}: ${_resolveDtoToEntityExpression(prop)},',
        )
        .join('\n');
    final fromEntityAssignments = props
        .map(
          (prop) =>
              '      ${prop.name.camelCase}: entity.${prop.name.camelCase},',
        )
        .join('\n');

    return '''$packageImports

  ${imports.join('\n')}

part '$nameSnake.freezed.dart';
part '$nameSnake.g.dart';

@freezed
abstract class $namePascal with _\$$namePascal {
  const $namePascal._();

  const factory $namePascal({
$fieldLines
  }) = _$namePascal;

  factory $namePascal.fromJson(Map<String, dynamic> json) =>
      _\$${namePascal}FromJson(json);

  factory $namePascal.fromEntity(${modelNamePascal}Entity entity) {
    return $namePascal(
$fromEntityAssignments
    );
  }

  ${modelNamePascal}Entity toEntity() {
    return ${modelNamePascal}Entity(
$toEntityAssignments
    );
  }
}
''';
  }

  String _buildFieldLine(TypedProp prop) {
    final propertyName = prop.name.camelCase;
    final defaultLiteral = prop.defaultValue;
    final defaultAnnotation = defaultLiteral == null
        ? ''
        : '@Default($defaultLiteral) ';
    final requiredPrefix = prop.isRequired ? 'required ' : '';
    return '    $defaultAnnotation$requiredPrefix${prop.normalizedType} $propertyName,';
  }

  String _buildFieldLineWithConverter({
    required TypedProp prop,
    required Set<String> enumConverterTypes,
  }) {
    final propertyName = prop.name.camelCase;
    final annotations = <String>[];
    if (prop.typeWithoutNullability == 'DateTime') {
      annotations.add('@UtcDateTimeConverter()');
    } else if (enumConverterTypes.contains(prop.typeWithoutNullability)) {
      annotations.add('@${prop.typeWithoutNullability}Converter()');
    }
    final defaultLiteral = prop.defaultValue;
    if (defaultLiteral != null) {
      annotations.add('@Default($defaultLiteral)');
    }
    final annotationPrefix = annotations.isEmpty
        ? ''
        : '${annotations.join(' ')} ';
    final requiredPrefix = prop.isRequired ? 'required ' : '';
    return '    $annotationPrefix$requiredPrefix${prop.normalizedType} $propertyName,';
  }

  String _resolveDtoToEntityExpression(TypedProp prop) {
    final type = prop.typeWithoutNullability;
    final value = prop.name.camelCase;
    if (type.endsWith('Dto')) {
      return prop.isNullable ? '$value?.toEntity()' : '$value.toEntity()';
    }
    return value;
  }

  Set<String> _collectReferencedTypes(List<TypedProp> props) {
    final result = <String>{};
    for (final prop in props) {
      final compact = prop.typeWithoutNullability
          .replaceAll(' ', '')
          .replaceAll('?', '');
      for (final match in RegExp(
        r'[A-Za-z_][A-Za-z0-9_]*',
      ).allMatches(compact)) {
        final token = match.group(0);
        if (token != null) result.add(token);
      }
    }
    return result;
  }

  Future<void> _injectFeatureBarrelExports({
    required String path,
    required String nameSnake,
  }) async {
    final file = File(path);
    if (!await file.exists()) return;

    final content = await file.readAsString();
    final lines = content.split('\n');
    final existingStatements = lines.map((l) => l.trim()).toSet();
    final statement = "export 'domain/entities/$nameSnake.dart';";

    if (existingStatements.contains(statement)) return;

    final marker = '// domain';
    final markerIndex = lines.indexWhere((line) => line.trim() == marker);

    if (markerIndex == -1) {
      lines.add('');
      lines.add(marker);
      lines.add(statement);
    } else {
      lines.insert(markerIndex + 1, statement);
    }

    await file.writeAsString('${lines.join('\n').trimRight()}\n');
  }
}
