import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../models/generation/typed_prop.dart';
import '../../services/operation_report_service.dart';
import '../base_generator.dart';

const _requestPostHooks = ['dart run build_runner build --force-jit'];

class RequestGenerator
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
  RequestGenerator({
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
        'FileService and HookService are required for request generation.',
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

    final barrelPath = p.join(featureRoot, '${feature.snakeCase}_feature.dart');
    final barrelFile = File(barrelPath);
    if (!await barrelFile.exists()) {
      logger.error(
        'Feature barrel file not found at: modules/$module/lib/src/features/$feature/${feature.snakeCase}_feature.dart',
      );
      exitCode = 1;
      return;
    }

    final progress = logger.progress('Baking request "$prefix" in memory...');
    final report = OperationReportService();

    try {
      final prefixSnake = prefix.snakeCase;
      final prefixPascal = prefix.pascalCase;

      final files = <String, List<int>>{
        'data/requests/${prefixSnake}_request.dart': utf8.encode(
          _buildRequestSource(
            prefixSnake: prefixSnake,
            prefixPascal: prefixPascal,
            props: props,
          ),
        ),
      };

      progress.update('Writing Request artifact...');
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
          'Skipped ${writeResult.skippedCount} existing request file(s) to prevent overwrite.',
        );

        if (strict || writeResult.abortedDueToExisting) {
          logger.error(
            'Strict mode: generation aborted because some request files already exist.',
          );
          report.logSummary(logger, operationLabel: 'fsda request');
          exitCode = 1;
          return;
        }
      }

      final barrelChanged = await _injectFeatureBarrelExports(
        path: barrelPath,
        prefixSnake: prefixSnake,
      );
      if (barrelChanged) {
        report.addInjected(barrelPath);
      }

      if (writeResult.writtenCount > 0) {
        progress.update('Running post hooks...');
        try {
          await hookService!.runHook(
            hooks: _requestPostHooks,
            workingDirectory: p.join(Directory.current.path, 'modules', module),
            logger: logger,
            disabled: hookDisabled,
            operationLabel: 'fsda request',
          );
        } catch (e) {
          logger.info(
            'Request file was created, but post-hook failed. You can rerun manually in module root: dart run build_runner build --force-jit',
          );
          logger.error('Post-hook error: $e');
        }
      }

      progress.complete(
        'Request "$prefix" successfully generated for "$feature" feature.',
      );
      report.logSummary(logger, operationLabel: 'fsda request');
    } catch (e) {
      progress.fail('Failed to generate request "$prefix": $e');
      exitCode = 1;
    }
  }

  String _buildRequestSource({
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
            .where((type) => _isEntityType(type))
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
      "import '../../domain/params/${prefixSnake}_param.dart';",
      ...dtoTypes.map((type) => "import '../dtos/${type.snakeCase}.dart';"),
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
    final fromParamAssignments = props
        .map((prop) => '      ${prop.name}: param.${prop.name},')
        .join('\n');

    return '''$packageImports

${relativeImports.join('\n')}

part '${prefixSnake}_request.freezed.dart';
part '${prefixSnake}_request.g.dart';

@freezed
abstract class ${prefixPascal}Request with _\$${prefixPascal}Request {
  const ${prefixPascal}Request._();

  const factory ${prefixPascal}Request({
$fieldLines
  }) = _${prefixPascal}Request;

  factory ${prefixPascal}Request.fromJson(Map<String, dynamic> json) =>
      _\$${prefixPascal}RequestFromJson(json);

  factory ${prefixPascal}Request.fromParam(${prefixPascal}Param param) {
    return ${prefixPascal}Request(
$fromParamAssignments
    );
  }
}
''';
  }

  String _buildFieldLine({
    required TypedProp prop,
    required bool withConverter,
  }) {
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

    return '    $annotationPrefix$requiredPrefix${prop.normalizedType} ${prop.name},';
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

  Future<bool> _injectFeatureBarrelExports({
    required String path,
    required String prefixSnake,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    final content = await file.readAsString();
    final lines = content.split('\n');
    final existingStatements = lines.map((line) => line.trim()).toSet();
    final dataExport = "export 'data/requests/${prefixSnake}_request.dart';";

    final changed = _insertExportUnderLayer(
      lines: lines,
      existingStatements: existingStatements,
      layer: 'data',
      statement: dataExport,
    );

    if (!changed) {
      return false;
    }

    final normalized = _normalizeBlankLines(lines.join('\n')).trimRight();
    await file.writeAsString('$normalized\n');
    return true;
  }

  bool _insertExportUnderLayer({
    required List<String> lines,
    required Set<String> existingStatements,
    required String layer,
    required String statement,
  }) {
    if (existingStatements.contains(statement)) {
      return false;
    }

    final marker = '// $layer';
    final markerIndex = lines.indexWhere((line) => line.trim() == marker);

    if (markerIndex == -1) {
      if (lines.isNotEmpty && lines.last.trim().isNotEmpty) {
        lines.add('');
      }
      lines.add(marker);
      lines.add(statement);
      existingStatements.add(statement);
      return true;
    }

    var insertIndex = markerIndex + 1;
    while (insertIndex < lines.length) {
      final trimmed = lines[insertIndex].trim();
      if (trimmed.isEmpty) {
        insertIndex += 1;
        continue;
      }
      if (trimmed.startsWith('// ')) {
        break;
      }
      if (trimmed.startsWith('export ')) {
        insertIndex += 1;
        continue;
      }
      break;
    }

    lines.insert(insertIndex, statement);
    existingStatements.add(statement);
    return true;
  }

  String _normalizeBlankLines(String source) {
    final sanitized = source.replaceAll(RegExp(r'[ \t]+\n'), '\n');
    return sanitized.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }
}
