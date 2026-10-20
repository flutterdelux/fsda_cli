import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../models/generation/typed_prop.dart';
import '../../services/file_service.dart';
import '../../services/logger_service.dart';
import '../../services/modelling/model_type_resolver_service.dart';
import '../../services/operation_report_service.dart';

const _dtoPostHooks = ['dart run build_runner build --force-jit'];

class DtoGenerator {
  final LoggerService logger;
  final FileService fileService;
  final OperationReportService report;

  DtoGenerator({
    required this.logger,
    required this.fileService,
    required this.report,
  });

  Future<Map<String, dynamic>> generate(
    ({
      String name,
      String feature,
      String module,
      List<TypedProp> props,
      bool strict,
    })
    args,
  ) async {
    final name = args.name;
    final feature = args.feature;
    final module = args.module;
    final props = args.props;
    final strict = args.strict;
    final operationLabel = 'fsda dto $name';

    final featureRoot = p.join(
      Directory.current.path,
      'modules',
      module,
      'lib',
      'src',
      'features',
      feature,
    );

    final featureDir = Directory(featureRoot);
    if (!await featureDir.exists()) {
      logger.error(
        'Feature path not found: modules/$module/lib/src/features/$feature',
      );
      exitCode = 1;
      return <String, dynamic>{'success': false};
    }

    final progress = logger.progress('Baking DTO "$name" in memory...');

    try {
      final nameSnake = name.snakeCase;
      final namePascal = name.pascalCase;
      final modelNameSnake = nameSnake.substring(
        0,
        nameSnake.length - '_dto'.length,
      );
      final modelNamePascal = modelNameSnake.pascalCase;
      final typeResolution = await const ModelTypeResolverService().resolve(
        featureRoot: featureRoot,
        props: props,
      );

      final files = <String, List<int>>{
        'data/dtos/$nameSnake.dart': utf8.encode(
          _buildDtoSource(
            nameSnake: nameSnake,
            namePascal: namePascal,
            modelNameSnake: modelNameSnake,
            modelNamePascal: modelNamePascal,
            props: props,
            typeImports: typeResolution.importsFor(
              fromDirectory: p.join(featureRoot, 'data', 'dtos'),
              excluding: <String>{namePascal, '${modelNamePascal}Entity'},
            ),
            enumConverterTypes: typeResolution.enumConverterTypes,
          ),
        ),
      };

      progress.update('Writing DTO artifact...');
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

      if (writeResult.skippedCount > 0) {
        logger.info(
          'Skipped ${writeResult.skippedCount} existing dto file(s) to prevent overwrite.',
        );

        if (strict || writeResult.abortedDueToExisting) {
          logger.error(
            'Strict mode: generation aborted because some dto files already exist.',
          );
          report.logSummary(logger, operationLabel: operationLabel);
          exitCode = 1;
          return <String, dynamic>{'success': false};
        }
      }

      progress.complete(
        'DTO "$name" successfully generated for "$feature" feature.',
      );
      report.logSummary(logger, operationLabel: operationLabel);

      return <String, dynamic>{
        'success': true,
        if (writeResult.writtenCount > 0) 'post_hook': _dtoPostHooks,
        'working_directory': p.join(Directory.current.path, 'modules', module),
      };
    } catch (e) {
      progress.fail('Failed to generate DTO "$name": $e');
      exitCode = 1;
      return <String, dynamic>{'success': false};
    }
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
        props.any(_requiresUtcConverter) ||
        referencedTypes.contains('NetworkFile');

    final packageImports = <String>[
      if (requiresAppCore) "import 'package:app_core/app_core.dart';",
      "import 'package:freezed_annotation/freezed_annotation.dart';",
    ].join('\n');

    final relativeImportSet = <String>{
      "import '../../domain/entities/${modelNameSnake}_entity.dart';",
      ...typeImports,
      ...enumConverterTypes.map(
        (type) => "import '../converters/${type.snakeCase}_converter.dart';",
      ),
    };
    final relativeImports = relativeImportSet.toList(growable: false)..sort();

    final fieldLines = props
        .map(
          (prop) => _buildFieldLine(
            prop: prop,
            withConverter: true,
            enumConverterTypes: enumConverterTypes,
          ),
        )
        .join('\n');
    final toEntityAssignments = props
        .map(
          (prop) =>
              '      ${_resolvePropertyName(prop)}: ${_resolveDtoToEntityExpression(prop)},',
        )
        .join('\n');
    final fromEntityAssignments = props
        .map(
          (prop) =>
              '      ${_resolvePropertyName(prop)}: entity.${_resolvePropertyName(prop)},',
        )
        .join('\n');

    return '''$packageImports

${relativeImports.join('\n')}

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

  String _resolveDtoToEntityExpression(TypedProp prop) {
    final type = prop.typeWithoutNullability;
    final value = _resolvePropertyName(prop);

    if (_isDtoType(type)) {
      if (prop.isNullable) {
        return '$value?.toEntity()';
      }
      return '$value.toEntity()';
    }

    final listDtoMatch = RegExp(
      r'^List<([A-Z][A-Za-z0-9_]*Dto)>$',
    ).firstMatch(type);
    if (listDtoMatch != null) {
      if (prop.isNullable) {
        return '$value?.map((entry) => entry.toEntity()).toList()';
      }
      return '$value.map((entry) => entry.toEntity()).toList()';
    }

    return value;
  }

  String _buildFieldLine({
    required TypedProp prop,
    required bool withConverter,
    required Set<String> enumConverterTypes,
  }) {
    final propertyName = _resolvePropertyName(prop);
    final annotations = <String>[];

    if (withConverter) {
      final converterAnnotation = _buildConverterAnnotation(
        prop,
        enumConverterTypes,
      );
      if (converterAnnotation != null) {
        annotations.add(converterAnnotation);
      }
    }

    final defaultLiteral = _buildDefaultLiteral(prop);
    if (defaultLiteral != null) {
      annotations.add('@Default($defaultLiteral)');
    }

    final annotationPrefix = annotations.isEmpty
        ? ''
        : '${annotations.join(' ')} ';
    final requiredPrefix = prop.isRequired ? 'required ' : '';

    return '    $annotationPrefix$requiredPrefix${prop.normalizedType} $propertyName,';
  }

  String _resolvePropertyName(TypedProp prop) {
    return prop.name.camelCase;
  }

  String? _buildConverterAnnotation(
    TypedProp prop,
    Set<String> enumConverterTypes,
  ) {
    final type = prop.typeWithoutNullability;
    if (type == 'DateTime') {
      return '@UtcDateTimeConverter()';
    }

    if (enumConverterTypes.contains(type)) {
      return '@${type}Converter()';
    }

    return null;
  }

  String? _buildDefaultLiteral(TypedProp prop) {
    final rawDefault = prop.defaultValue;
    if (rawDefault == null) {
      return null;
    }

    final raw = rawDefault.trim();
    if (prop.typeWithoutNullability != 'String') {
      return raw;
    }

    if ((raw.startsWith("'") && raw.endsWith("'")) ||
        (raw.startsWith('"') && raw.endsWith('"'))) {
      return raw;
    }

    final escaped = raw.replaceAll("'", "\\'");
    return "'$escaped'";
  }

  bool _requiresUtcConverter(TypedProp prop) {
    return prop.typeWithoutNullability == 'DateTime';
  }

  Set<String> _collectReferencedTypes(List<TypedProp> props) {
    final result = <String>{};
    for (final prop in props) {
      result.addAll(_extractTypeTokens(prop.typeWithoutNullability));
    }
    return result;
  }

  Set<String> _extractTypeTokens(String typeExpression) {
    final compact = typeExpression.replaceAll(' ', '').replaceAll('?', '');
    final matches = RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(compact);

    final result = <String>{};
    for (final match in matches) {
      final token = match.group(0);
      if (token == null || token.isEmpty) {
        continue;
      }
      if (_isCollectionTypeToken(token) || _isPrimitiveType(token)) {
        continue;
      }
      result.add(token);
    }

    return result;
  }

  bool _isDtoType(String token) {
    return RegExp(r'^[A-Z][A-Za-z0-9_]*Dto$').hasMatch(token);
  }

  bool _isCollectionTypeToken(String token) {
    switch (token) {
      case 'List':
      case 'Map':
      case 'Set':
      case 'Iterable':
        return true;
      default:
        return false;
    }
  }

  bool _isPrimitiveType(String type) {
    switch (type) {
      case 'String':
      case 'int':
      case 'double':
      case 'num':
      case 'bool':
      case 'dynamic':
      case 'Object':
      case 'DateTime':
      case 'Duration':
      case 'BigInt':
        return true;
      default:
        return false;
    }
  }
}
