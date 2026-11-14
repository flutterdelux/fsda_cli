import '../../../core/extensions/logic_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/logic_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class ProviderTemplate {
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
import 'package:flutter/foundation.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends ChangeNotifier {

  ${logic.statePascal} _state = const ${logic.statePascal}();

  ${logic.statePascal} get state => _state;

  void updateState({
    ${logic.props.map((e) => _propParam(e)).join('\n').trim()}
  }) {
    _state = ${logic.statePascal}(
      ${logic.props.map((e) => _propCopyState(e)).join('\n').trim()}
    );
    notifyListeners();
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
