import '../../core/extensions/model_param_x.dart';
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
    final baseSnake = model.baseNameSnake;
    final baseCamel = baseSnake.camelCase;
    final baseTitle = baseSnake.titleCase;

    final entries = <String, dynamic>{};

    final baseKey = baseCamel;
    entries[baseKey] = baseTitle;

    final props = model.props;
    for (final prop in props) {
      final nameSnake = prop.name;
      final namePascal = nameSnake.pascalCase;
      final propKey = '$baseCamel$namePascal';

      entries[propKey] = prop.name.titleCase;
    }

    return entries;
  }
}

String _buildFreezed(ModelParam model) {
  final nameSnake = model.modelName;
  final namePascal = nameSnake.pascalCase;

  final props = model.props;

  return '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '$nameSnake.freezed.dart';

@freezed
abstract class $namePascal with _\$$namePascal {
  const factory $namePascal({
${props.map((e) => _propDefinition(e)).join('\n')}
  }) = _$namePascal;
}
''';
}

String _buildFreezedWithSerializable({
  required ModelParam model,
  List<String> otherMethods = const [],
}) {
  final nameSnake = model.modelName;
  final namePascal = nameSnake.pascalCase;
  final baseNameSnake = model.baseNameSnake;

  final sortedImports = ImportUtil.sort([
    "import 'package:freezed_annotation/freezed_annotation.dart';",
    if (otherMethods.join('').contains('fromEntity') ||
        otherMethods.join('').contains('toEntity'))
      "import '../../domain/entities/${baseNameSnake}_entity.dart';",
    if (otherMethods.join('').contains('fromParam') ||
        otherMethods.join('').contains('toParam'))
      "import '../../domain/params/${baseNameSnake}_param.dart';",
  ]);

  final props = model.props;

  return '''${sortedImports.join('\n')}

part '$nameSnake.freezed.dart';
part '$nameSnake.g.dart';

@freezed
abstract class $namePascal with _\$$namePascal {
  const $namePascal._();

  const factory $namePascal({
${props.map((e) => _propDefinition(e)).join('\n')}
  }) = _$namePascal;

  factory $namePascal.fromJson(Map<String, dynamic> json) =>
      _\$${namePascal}FromJson(json);

${otherMethods.join('\n')}
}
''';
}

String _fromMethod({required ModelParam model, required String from}) {
  final fromCamel = from.camelCase;
  final fromPascal = from.pascalCase;

  final nameSnake = model.modelName;
  final namePascal = nameSnake.pascalCase;

  final baseNamePascal = model.baseNamePascal;

  final props = model.props;
  return '''
  factory $namePascal.from$fromPascal($baseNamePascal$fromPascal $fromCamel) {
    return $namePascal(
${props.map((e) => _propFrom(e, from)).join('\n')}
    );
  }
''';
}

String _toMethod(ModelParam model, String to) {
  final toPascal = to.pascalCase;
  final baseNamePascal = model.baseNamePascal;

  final props = model.props;
  return '''
  $baseNamePascal$toPascal to$toPascal() {
    return $baseNamePascal$toPascal(
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
