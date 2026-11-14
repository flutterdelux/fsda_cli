import '../../../core/extensions/logic_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/logic_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class GetxTemplate {
  static ArtifactGenerationModel build(LogicParam logic) {
    return ArtifactGenerationModel(
      name: logic.controllerPascal,
      path: logic.controllerPath,
      content: _content(logic),
      typesToImport: {...logic.props.map((e) => e.type)},
      needToExport: true,
    );
  }
}

String _content(LogicParam logic) {
  return '''
import 'package:get/get.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends GetxController {
  final Rx<${logic.statePascal}> _state = const ${logic.statePascal}().obs;
  ${logic.statePascal} get state => _state.value;

  void updateState({
    ${logic.props.map((e) => _propParam(e)).join('\n').trim()}
  }) {
    _state.value = ${logic.statePascal}(
      ${logic.props.map((e) => _propCopyState(e)).join('\n').trim()}
    );
  }
}
''';
}

String _propParam(PropModel prop) {
  return ['    ', prop.type, ' ', prop.name.camelCase, ','].join();
}

String _propCopyState(PropModel prop) {
  return ['      ', prop.name.camelCase, ': ', prop.name.camelCase, ','].join();
}
