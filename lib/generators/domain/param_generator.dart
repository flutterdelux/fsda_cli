import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../models/generation/typed_prop.dart';
import '../../services/operation_report_service.dart';
import '../base_generator.dart';

const _paramPostHooks = ['dart run build_runner build --force-jit'];

class ParamGenerator
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
  ParamGenerator({
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
        'FileService and HookService are required for param generation.',
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

    final progress = logger.progress('Baking param "$prefix" in memory...');
    final report = OperationReportService();

    try {
      final prefixSnake = prefix.snakeCase;
      final prefixPascal = prefix.pascalCase;

      final files = <String, List<int>>{
        'domain/params/${prefixSnake}_param.dart': utf8.encode(
          _buildParamSource(
            prefixSnake: prefixSnake,
            prefixPascal: prefixPascal,
            props: props,
          ),
        ),
      };

      progress.update('Writing Param artifact...');
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
          'Skipped ${writeResult.skippedCount} existing param file(s) to prevent overwrite.',
        );

        if (strict || writeResult.abortedDueToExisting) {
          logger.error(
            'Strict mode: generation aborted because some param files already exist.',
          );
          report.logSummary(logger, operationLabel: 'fsda param');
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
            hooks: _paramPostHooks,
            workingDirectory: p.join(Directory.current.path, 'modules', module),
            logger: logger,
            disabled: hookDisabled,
            operationLabel: 'fsda param',
          );
        } catch (e) {
          logger.info(
            'Param file was created, but post-hook failed. You can rerun manually in module root: dart run build_runner build --force-jit',
          );
          logger.error('Post-hook error: $e');
        }
      }

      progress.complete(
        'Param "$prefix" successfully generated for "$feature" feature.',
      );
      report.logSummary(logger, operationLabel: 'fsda param');
    } catch (e) {
      progress.fail('Failed to generate param "$prefix": $e');
      exitCode = 1;
    }
  }

  String _buildParamSource({
    required String prefixSnake,
    required String prefixPascal,
    required List<TypedProp> props,
  }) {
    final referencedTypes = _collectReferencedTypes(props);
    final entityTypes =
        referencedTypes
            .where((type) => _isEntityType(type))
            .toList(growable: false)
          ..sort();
    final dtoTypes =
        referencedTypes
            .where((type) => _isDtoType(type))
            .toList(growable: false)
          ..sort();
    final enumTypes = referencedTypes.where(_isEnumType).toList(growable: false)
      ..sort();
    final requiresAppCore = referencedTypes.contains('NetworkFile');

    final packageImports = <String>[
      if (requiresAppCore) "import 'package:app_core/app_core.dart';",
      "import 'package:freezed_annotation/freezed_annotation.dart';",
    ].join('\n');

    final relativeImportSet = <String>{
      ...entityTypes.map(
        (type) => "import '../entities/${_resolveEntityFileName(type)}.dart';",
      ),
      ...dtoTypes.map(
        (type) => "import '../../data/dtos/${type.snakeCase}.dart';",
      ),
      ...enumTypes.map((type) => "import '../enums/${type.snakeCase}.dart';"),
    };
    final relativeImports = relativeImportSet.toList(growable: false)..sort();

    final fieldLines = props.map(_buildFieldLine).join('\n');

    return '''$packageImports
${relativeImports.isEmpty ? '' : '\n${relativeImports.join('\n')}'}

part '${prefixSnake}_param.freezed.dart';

@freezed
abstract class ${prefixPascal}Param with _\$${prefixPascal}Param {
  const factory ${prefixPascal}Param({
$fieldLines
  }) = _${prefixPascal}Param;
}
''';
  }

  String _buildFieldLine(TypedProp prop) {
    final propertyName = _resolvePropertyName(prop);
    final defaultLiteral = _buildDefaultLiteral(prop);
    final defaultAnnotation = defaultLiteral == null
        ? ''
        : '@Default($defaultLiteral) ';
    final requiredPrefix = prop.isRequired ? 'required ' : '';

    return '    $defaultAnnotation$requiredPrefix${prop.normalizedType} $propertyName,';
  }

  String _resolvePropertyName(TypedProp prop) {
    return prop.name.camelCase;
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
    final domainExport = "export 'domain/params/${prefixSnake}_param.dart';";

    final changed = _insertExportUnderLayer(
      lines: lines,
      existingStatements: existingStatements,
      layer: 'domain',
      statement: domainExport,
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
