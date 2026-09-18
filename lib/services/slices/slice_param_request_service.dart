import 'dart:convert';

import 'package:mason/mason.dart';

import '../../models/generation/typed_prop.dart';

class SliceParamRequestService {
  const SliceParamRequestService();

  void putParamRequestArtifacts({
    required Map<String, List<int>> files,
    required String featureName,
    required String sliceName,
    required List<TypedProp> props,
  }) {
    final featureSnake = featureName.snakeCase;
    final sliceSnake = sliceName.snakeCase;
    final modelSnake = '${featureSnake}_$sliceSnake';
    final modelPascal = '${featureName.pascalCase}${sliceName.pascalCase}';

    final paramPath = 'domain/params/${modelSnake}_param.dart';
    final requestPath = 'data/requests/${modelSnake}_request.dart';

    files[paramPath] = utf8.encode(
      _buildOverriddenParamSource(
        modelSnake: modelSnake,
        modelPascal: modelPascal,
        props: props,
      ),
    );
    files[requestPath] = utf8.encode(
      _buildOverriddenRequestSource(
        modelSnake: modelSnake,
        modelPascal: modelPascal,
        props: props,
      ),
    );
  }

  Map<String, List<String>> buildParamRequestBarrelExports({
    required String featureName,
    required String sliceName,
    required bool includeParamExports,
  }) {
    if (!includeParamExports) {
      return const <String, List<String>>{};
    }

    final featureSnake = featureName.snakeCase;
    final sliceSnake = sliceName.snakeCase;
    final modelSnake = '${featureSnake}_$sliceSnake';

    return <String, List<String>>{
      'domain': <String>["export 'domain/params/${modelSnake}_param.dart';"],
    };
  }

  String _buildOverriddenParamSource({
    required String modelSnake,
    required String modelPascal,
    required List<TypedProp> props,
  }) {
    final enumTypes = _collectCustomEnumTypes(props);
    final enumImports = enumTypes
        .map((type) => "import '../enums/${type.snakeCase}.dart';")
        .join('\n');

    final fieldLines = props
        .map((prop) => _buildPropFieldLine(prop: prop, withConverter: false))
        .join('\n');

    return '''import 'package:freezed_annotation/freezed_annotation.dart';
${enumImports.isEmpty ? '' : '\n$enumImports'}

part '${modelSnake}_param.freezed.dart';

@freezed
abstract class ${modelPascal}Param with _\$${modelPascal}Param {
  const factory ${modelPascal}Param({
$fieldLines
  }) = _${modelPascal}Param;
}
''';
  }

  String _buildOverriddenRequestSource({
    required String modelSnake,
    required String modelPascal,
    required List<TypedProp> props,
  }) {
    final enumTypes = _collectCustomEnumTypes(props);
    final requiresAppCore = props.any(_requiresUtcConverter);

    final packageImports = <String>[
      if (requiresAppCore) "import 'package:app_core/app_core.dart';",
      "import 'package:freezed_annotation/freezed_annotation.dart';",
    ].join('\n');

    final relativeImports = <String>[
      "import '../../domain/params/${modelSnake}_param.dart';",
      ...enumTypes.map(
        (type) => "import '../../domain/enums/${type.snakeCase}.dart';",
      ),
      ...enumTypes.map(
        (type) => "import '../converters/${type.snakeCase}_converter.dart';",
      ),
    ].join('\n');

    final fieldLines = props
        .map((prop) => _buildPropFieldLine(prop: prop, withConverter: true))
        .join('\n');
    final fromParamAssignments = props
        .map((prop) => '      ${prop.name}: param.${prop.name},')
        .join('\n');

    return '''$packageImports

$relativeImports

part '${modelSnake}_request.freezed.dart';
part '${modelSnake}_request.g.dart';

@freezed
abstract class ${modelPascal}Request with _\$${modelPascal}Request {
  const ${modelPascal}Request._();

  const factory ${modelPascal}Request({
$fieldLines
  }) = _${modelPascal}Request;

  factory ${modelPascal}Request.fromJson(Map<String, dynamic> json) =>
      _\$${modelPascal}RequestFromJson(json);

  factory ${modelPascal}Request.fromParam(${modelPascal}Param param) {
    return ${modelPascal}Request(
$fromParamAssignments
    );
  }
}
''';
  }

  String _buildPropFieldLine({
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

    if (_isCustomEnumType(type)) {
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

  List<String> _collectCustomEnumTypes(List<TypedProp> props) {
    final set = <String>{};
    for (final prop in props) {
      final type = prop.typeWithoutNullability;
      if (_isCustomEnumType(type)) {
        set.add(type);
      }
    }

    final values = set.toList(growable: false);
    values.sort();
    return values;
  }

  bool _isCustomEnumType(String type) {
    if (_isCollectionType(type)) {
      return false;
    }

    if (_isPrimitiveType(type)) {
      return false;
    }

    return true;
  }

  bool _isCollectionType(String type) {
    return type.startsWith('List<') ||
        type.startsWith('Map<') ||
        type.startsWith('Set<');
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
        return true;
      default:
        return false;
    }
  }
}
