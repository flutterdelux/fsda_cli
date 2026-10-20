import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../models/generation/typed_prop.dart';
import '../../services/file_service.dart';
import '../../services/logger_service.dart';
import '../../services/modelling/model_type_resolver_service.dart';
import '../../services/operation_report_service.dart';

const _requestPostHooks = ['dart run build_runner build --force-jit'];

class RequestGenerator {
  final LoggerService logger;
  final FileService fileService;
  final OperationReportService report;

  RequestGenerator({
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

    final progress = logger.progress('Baking Request "$name" in memory...');
    try {
      final nameSnake = name.snakeCase;
      final namePascal = name.pascalCase;
      final paramNameSnake =
          '${nameSnake.substring(0, nameSnake.length - '_request'.length)}_param';
      final paramNamePascal = paramNameSnake.pascalCase;
      final typeResolution = await const ModelTypeResolverService().resolve(
        featureRoot: featureRoot,
        props: props,
      );
      final files = <String, List<int>>{
        'data/requests/$nameSnake.dart': utf8.encode(
          _buildRequestSource(
            nameSnake: nameSnake,
            namePascal: namePascal,
            paramNameSnake: paramNameSnake,
            paramNamePascal: paramNamePascal,
            props: props,
            typeImports: typeResolution.importsFor(
              fromDirectory: p.join(featureRoot, 'data', 'requests'),
              excluding: <String>{namePascal, paramNamePascal},
            ),
            enumConverterTypes: typeResolution.enumConverterTypes,
          ),
        ),
      };

      progress.update('Writing Request artifact...');
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
          'Skipped ${writeResult.skippedCount} existing request file(s) to prevent overwrite.',
        );
        if (strict || writeResult.abortedDueToExisting) {
          logger.error(
            'Strict mode: generation aborted because some request files already exist.',
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
        'Request "$name" successfully generated for "$feature" feature.',
      );
      return <String, dynamic>{
        'success': true,
        if (writeResult.writtenCount > 0) 'post_hook': _requestPostHooks,
        'working_directory': p.join(Directory.current.path, 'modules', module),
      };
    } catch (e) {
      progress.fail('Failed to generate Request "$name": $e');
      exitCode = 1;
      return <String, dynamic>{'success': false};
    }
  }

  String _buildRequestSource({
    required String nameSnake,
    required String namePascal,
    required String paramNameSnake,
    required String paramNamePascal,
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
      "import '../../domain/params/$paramNameSnake.dart';",
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
    final fromParamAssignments = props
        .map(
          (prop) =>
              '      ${_resolvePropertyName(prop)}: param.${_resolvePropertyName(prop)},',
        )
        .join('\n');

    return '''$packageImports\n\n${relativeImports.join('\n')}

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

  factory $namePascal.fromParam($paramNamePascal param) {
    return $namePascal(
$fromParamAssignments
    );
  }
}
''';
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
    final dataExport = "export 'data/requests/$nameSnake.dart';";

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
