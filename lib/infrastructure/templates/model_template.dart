import '../../core/utils/import_util.dart';
import '../../domain/models/prop_model.dart';
import '../../domain/params/model_param.dart';
import '../text_modifiers/string_extension.dart';

abstract final class ModelTemplate {
  static String buildEntity(ModelParam model) {
    return _buildFreezed(model);
  }

  static String buildParam(ModelParam model) {
    return _buildFreezed(model);
  }

  static String buildDto(ModelParam model) {
    return _buildFreezedWithSerializable(
      model: model,
      otherMethods: [
        _fromMethod(model: model, from: 'entity'),
        _toMethod(model, 'entity'),
      ],
    );
  }

  static String buildRequest(ModelParam model) {
    return _buildFreezedWithSerializable(
      model: model,
      otherMethods: [
        _fromMethod(model: model, from: 'param'),
        _toMethod(model, 'param'),
      ],
    );
  }

  static String buildResponse(ModelParam model) {
    return _buildFreezedWithSerializable(model: model);
  }

  static Map<String, dynamic> buildArbEntries(ModelParam model) {
    final modelSnake = model.name;
    final modelCamel = modelSnake.camelCase;
    final modelTitle = modelSnake.titleCase;

    final entries = <String, dynamic>{};

    final modelKey = modelCamel;
    entries[modelKey] = modelTitle;

    final props = model.props;
    for (final prop in props) {
      final nameSnake = prop.name;
      final namePascal = nameSnake.pascalCase;
      final propKey = '$modelCamel$namePascal';

      entries[propKey] = prop.name.titleCase;
    }

    return entries;
  }
}

String _buildFreezed(ModelParam model) {
  final modelSnake = model.name;
  final modelPascal = modelSnake.pascalCase;

  final typeSnake = model.type.value;
  final typePascal = typeSnake.pascalCase;

  final className = '$modelPascal$typePascal';

  final props = model.props;

  return '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${modelSnake}_$typeSnake.freezed.dart';

@freezed
abstract class $className with _\$$className {
  const factory $className({
${props.map((e) => _propDefinition(e)).join('\n')}
  }) = _$className;
}
''';
}

String _buildFreezedWithSerializable({
  required ModelParam model,
  List<String> otherMethods = const [],
}) {
  final modelSnake = model.name;
  final modelPascal = modelSnake.pascalCase;

  final typeSnake = model.type.value;
  final typePascal = typeSnake.pascalCase;

  final className = '$modelPascal$typePascal';

  final sortedImports = ImportUtil.sort([
    "import 'package:freezed_annotation/freezed_annotation.dart';",
    if (otherMethods.join('').contains('fromEntity') ||
        otherMethods.join('').contains('toEntity'))
      "import '../../domain/entities/${modelSnake}_entity.dart';",
    if (otherMethods.join('').contains('fromParam') ||
        otherMethods.join('').contains('toParam'))
      "import '../../domain/params/${modelSnake}_param.dart';",
  ]);

  final props = model.props;

  return '''${sortedImports.join('\n')}

part '${modelSnake}_$typeSnake.freezed.dart';
part '${modelSnake}_$typeSnake.g.dart';

@freezed
abstract class $className with _\$$className {
  const $className._();

  const factory $className({
${props.map((e) => _propDefinition(e)).join('\n')}
  }) = _$className;

  factory $className.fromJson(Map<String, dynamic> json) =>
      _\$${className}FromJson(json);

${otherMethods.join('\n')}
}
''';
}

String _fromMethod({required ModelParam model, required String from}) {
  final fromCamel = from.camelCase;
  final fromPascal = from.pascalCase;

  final modelSnake = model.name;
  final modelPascal = modelSnake.pascalCase;

  final typeSnake = model.type.value;
  final typePascal = typeSnake.pascalCase;

  final className = '$modelPascal$typePascal';

  final props = model.props;
  return '''
  factory $className.from$fromPascal($modelPascal$fromPascal $fromCamel) {
    return $className(
${props.map((e) => _propFrom(e, from)).join('\n')}
    );
  }
''';
}

String _toMethod(ModelParam model, String to) {
  final toPascal = to.pascalCase;

  final modelSnake = model.name;
  final modelPascal = modelSnake.pascalCase;

  final props = model.props;
  return '''
  $modelPascal$toPascal to$toPascal() {
    return $modelPascal$toPascal(
${props.map((e) => _propTo(e)).join('\n')}      
    );
  }
''';
}

String _propDefinition(PropModel prop) {
  final isNullable = prop.type.endsWith('?');
  final hasDefault = prop.defaultValue.isNotEmpty;
  final hasConverter = prop.converter.isNotEmpty;
  final isRequired = !isNullable && !hasDefault;
  return [
    "   ",
    if (hasConverter) '@${prop.converter}()',
    if (hasDefault) '@Default(${prop.defaultValue})',
    if (isRequired) 'required',
    prop.type,
    '${prop.name.camelCase},',
  ].join(' ');
}

String _propFrom(PropModel prop, String from) {
  final propCamel = prop.name.camelCase;
  return "      $propCamel: $from.$propCamel,";
}

String _propTo(PropModel prop) {
  final propCamel = prop.name.camelCase;
  return "      $propCamel: $propCamel,";
}
