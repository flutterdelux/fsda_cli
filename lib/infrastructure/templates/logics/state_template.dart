import '../../../core/extensions/logic_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/logic_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class StateTemplate {
  static ArtifactGenerationModel build(LogicParam logic) {
    return ArtifactGenerationModel(
      name: logic.statePascal,
      path: logic.statePath,
      content: _content(logic),
      typesToImport: {...logic.props.map((e) => e.type)},
      needToExport: true,
    );
  }
}

String _content(LogicParam logic) {
  final props = logic.props;
  return '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${logic.stateSnake}.freezed.dart';

@freezed
sealed class ${logic.statePascal} with _\$${logic.statePascal} {
  const factory ${logic.statePascal}({
${props.map((e) => _propDefinition(e)).join('\n')}
  }) = _${logic.statePascal};
}
''';
}

String _propDefinition(PropModel prop) {
  final isNullable = prop.type.endsWith('?');
  final hasDefault = prop.defaultValue.isNotEmpty;
  final isRequired = !isNullable && !hasDefault;
  return [
    "   ",
    if (hasDefault) '@Default(${prop.defaultValue})',
    if (isRequired) 'required',
    prop.type,
    '${prop.name.camelCase},',
  ].join(' ');
}
