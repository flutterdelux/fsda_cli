import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../models/generation/typed_prop.dart';
import '../../services/operation_report_service.dart';
import '../base_generator.dart';

const _dtoPostHooks = ['dart run build_runner build --force-jit'];

class DtoGenerator
    extends
        BaseGenerator<
          void,
          ({
            String prefix,
            String feature,
            String module,
            List<TypedProp> props,
            bool strict,
            bool hookDisabled,
          })
        > {
  DtoGenerator({
    required super.logger,
    required super.fileService,
    required super.hookService,
  });

  @override
  Future<void> generate(
    ({
      String prefix,
      String feature,
      String module,
      List<TypedProp> props,
      bool strict,
      bool hookDisabled,
    })
    args,
  ) async {
    final prefix = args.prefix;
    final feature = args.feature;
    final module = args.module;
    final props = args.props;
    final strict = args.strict;
    final hookDisabled = args.hookDisabled;

    if (fileService == null || hookService == null) {
      logger.error(
        'FileService and HookService are required for dto generation.',
      );
      exitCode = 1;
      return;
    }

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
      return;
    }

    final progress = logger.progress('Baking dto "$prefix" in memory...');
    final report = OperationReportService();

    try {
      final prefixSnake = prefix.snakeCase;
      final prefixPascal = prefix.pascalCase;

      final files = <String, List<int>>{
        'data/dtos/${prefixSnake}_dto.dart': utf8.encode(
          _buildDtoSource(
            prefixSnake: prefixSnake,
            prefixPascal: prefixPascal,
            props: props,
          ),
        ),
      };

      progress.update('Writing DTO artifact...');
      final writeResult = await fileService!.generateTemplate(
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
          report.logSummary(logger, operationLabel: 'fsda dto');
          exitCode = 1;
          return;
        }
      }

      if (writeResult.writtenCount > 0) {
        progress.update('Running post hooks...');
        try {
          await hookService!.runHook(
            hooks: _dtoPostHooks,
            workingDirectory: p.join(Directory.current.path, 'modules', module),
            logger: logger,
            disabled: hookDisabled,
            operationLabel: 'fsda dto',
          );
        } catch (e) {
          logger.info(
            'DTO file was created, but post-hook failed. You can rerun manually in module root: dart run build_runner build --force-jit',
          );
          logger.error('Post-hook error: $e');
        }
      }

      progress.complete(
        'DTO "$prefix" successfully generated for "$feature" feature.',
      );
      report.logSummary(logger, operationLabel: 'fsda dto');
    } catch (e) {
      progress.fail('Failed to generate dto "$prefix": $e');
      exitCode = 1;
    }
  }

  String _buildDtoSource({
    required String prefixSnake,
    required String prefixPascal,
    required List<TypedProp> props,
  }) {
    final referencedTypes = _collectReferencedTypes(props);
    final dtoTypes =
        referencedTypes
            .where((type) => _isDtoType(type) && type != '${prefixPascal}Dto')
            .toList(growable: false)
          ..sort();
    final entityTypes =
        referencedTypes
            .where(
              (type) => _isEntityType(type) && type != '${prefixPascal}Entity',
            )
            .toList(growable: false)
          ..sort();
    final enumTypes = referencedTypes.where(_isEnumType).toList(growable: false)
      ..sort();

    final requiresAppCore =
        props.any(_requiresUtcConverter) ||
        referencedTypes.contains('NetworkFile');

    final packageImports = <String>[
      if (requiresAppCore) "import 'package:app_core/app_core.dart';",
      "import 'package:freezed_annotation/freezed_annotation.dart';",
    ].join('\n');

    final relativeImportSet = <String>{
      "import '../../domain/entities/${prefixSnake}_entity.dart';",
      ...dtoTypes.map((type) => "import '${type.snakeCase}.dart';"),
      ...entityTypes.map(
        (type) =>
            "import '../../domain/entities/${_resolveEntityFileName(type)}.dart';",
      ),
      ...enumTypes.map(
        (type) => "import '../../domain/enums/${type.snakeCase}.dart';",
      ),
      ...enumTypes.map(
        (type) => "import '../converters/${type.snakeCase}_converter.dart';",
      ),
    };
    final relativeImports = relativeImportSet.toList(growable: false)..sort();

    final fieldLines = props
        .map((prop) => _buildFieldLine(prop: prop, withConverter: true))
        .join('\n');
    final toEntityAssignments = props
        .map(
          (prop) =>
              '      ${_resolvePropertyName(prop)}: ${_resolveDtoToEntityExpression(prop)},',
        )
        .join('\n');

    return '''$packageImports

${relativeImports.join('\n')}

part '${prefixSnake}_dto.freezed.dart';
part '${prefixSnake}_dto.g.dart';

@freezed
abstract class ${prefixPascal}Dto with _\$${prefixPascal}Dto {
  const ${prefixPascal}Dto._();

  const factory ${prefixPascal}Dto({
$fieldLines
  }) = _${prefixPascal}Dto;

  factory ${prefixPascal}Dto.fromJson(Map<String, dynamic> json) =>
      _\$${prefixPascal}DtoFromJson(json);

  ${prefixPascal}Entity toEntity() {
    return ${prefixPascal}Entity(
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
  }) {
    final propertyName = _resolvePropertyName(prop);
    final annotations = <String>[];

    if (withConverter) {
      final converterAnnotation = _buildConverterAnnotation(prop);
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

  String? _buildConverterAnnotation(TypedProp prop) {
    final type = prop.typeWithoutNullability;
    if (type == 'DateTime') {
      return '@UtcDateTimeConverter()';
    }

    if (_isEnumType(type)) {
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

  bool _isEntityType(String token) {
    return RegExp(r'^[A-Z][A-Za-z0-9_]*Entity$').hasMatch(token);
  }

  bool _isEnumType(String token) {
    if (_isPrimitiveType(token) || _isCollectionTypeToken(token)) {
      return false;
    }
    if (_isDtoType(token) || _isEntityType(token) || token == 'NetworkFile') {
      return false;
    }
    return RegExp(r'^[A-Z][A-Za-z0-9_]*$').hasMatch(token);
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

  String _resolveEntityFileName(String entityType) {
    final normalized = entityType.replaceAll(' ', '').replaceAll('?', '');
    final baseName = normalized.endsWith('Entity')
        ? normalized.substring(0, normalized.length - 'Entity'.length)
        : normalized;
    return '${baseName.snakeCase}_entity';
  }
}
