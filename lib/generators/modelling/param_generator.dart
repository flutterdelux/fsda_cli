import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../models/generation/typed_prop.dart';
import '../../services/file_service.dart';
import '../../services/logger_service.dart';
import '../../services/modelling/model_type_resolver_service.dart';
import '../../services/operation_report_service.dart';

const _paramPostHooks = ['dart run build_runner build --force-jit'];

class ParamGenerator {
  final LoggerService logger;
  final FileService fileService;
  final OperationReportService report;

  ParamGenerator({
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

    final featureRoot = p.join(
      Directory.current.path,
      'modules',
      module,
      'lib',
      'src',
      'features',
      feature,
    );
    if (!await Directory(featureRoot).exists()) {
      logger.error(
        'Feature path not found: modules/$module/lib/src/features/$feature',
      );
      exitCode = 1;
      return <String, dynamic>{'success': false};
    }

    final barrelPath = p.join(featureRoot, '${feature.snakeCase}_feature.dart');
    if (!await File(barrelPath).exists()) {
      logger.error(
        'Feature barrel file not found at: modules/$module/lib/src/features/$feature/${feature.snakeCase}_feature.dart',
      );
      exitCode = 1;
      return <String, dynamic>{'success': false};
    }

    final progress = logger.progress('Baking Param "$name" in memory...');
    try {
      final nameSnake = name.snakeCase;
      final namePascal = name.pascalCase;
      final typeResolution = await const ModelTypeResolverService().resolve(
        featureRoot: featureRoot,
        props: props,
      );
      final files = <String, List<int>>{
        'domain/params/$nameSnake.dart': utf8.encode(
          _buildParamSource(
            nameSnake: nameSnake,
            namePascal: namePascal,
            props: props,
            typeImports: typeResolution.importsFor(
              fromDirectory: p.join(featureRoot, 'domain', 'params'),
            ),
          ),
        ),
      };

      progress.update('Writing Param artifact...');
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
          'Skipped ${writeResult.skippedCount} existing param file(s) to prevent overwrite.',
        );
        if (strict || writeResult.abortedDueToExisting) {
          logger.error(
            'Strict mode: generation aborted because some param files already exist.',
          );
          exitCode = 1;
          return <String, dynamic>{'success': false};
        }
      }

      final barrelChanged = await _injectFeatureBarrelExports(
        path: barrelPath,
        nameSnake: nameSnake,
      );
      if (barrelChanged) report.addInjected(barrelPath);

      progress.complete(
        'Param "$name" successfully generated for "$feature" feature.',
      );
      return <String, dynamic>{
        'success': true,
        if (writeResult.writtenCount > 0) 'post_hook': _paramPostHooks,
        'working_directory': p.join(Directory.current.path, 'modules', module),
      };
    } catch (e) {
      progress.fail('Failed to generate Param "$name": $e');
      exitCode = 1;
      return <String, dynamic>{'success': false};
    }
  }

  String _buildParamSource({
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

    final relativeImportSet = <String>{...typeImports};
    final relativeImports = relativeImportSet.toList(growable: false)..sort();

    final fieldLines = props.map(_buildFieldLine).join('\n');

    return '''$packageImports
${relativeImports.isEmpty ? '' : '\n${relativeImports.join('\n')}'}

part '$nameSnake.freezed.dart';

@freezed
abstract class $namePascal with _\$$namePascal {
  const factory $namePascal({
$fieldLines
  }) = _$namePascal;
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

  Future<bool> _injectFeatureBarrelExports({
    required String path,
    required String nameSnake,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    final content = await file.readAsString();
    final lines = content.split('\n');
    final existingStatements = lines.map((line) => line.trim()).toSet();
    final domainExport = "export 'domain/params/$nameSnake.dart';";

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
