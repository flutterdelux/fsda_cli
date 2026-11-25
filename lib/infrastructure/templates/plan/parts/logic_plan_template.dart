import '../../../text_modifiers/string_extension.dart';

abstract final class LogicPlanTemplate {
  static String perSlice({
    required String featureName,
    required String sliceName,
  }) {
    return switch (sliceName) {
      'list' || 'detail' || 'delete' => '',
      'create' => _createForm(featureName),
      'update' => _updateForm(featureName),
      _ => _customForm(featureName: featureName, sliceName: sliceName),
    };
  }

  static String all(String featureName) =>
      '''
  ${_createForm(featureName).trim()}
  ${_updateForm(featureName).trim()}
''';
}

String _createForm(String featureName) =>
    '''
  - slice: create_form
    control: cubit
    prop:
      - "${featureName.pascalCase}CreateParam?:param"
      - "String?:invalid_message"
''';

String _updateForm(String featureName) =>
    '''
  - slice: update_form
    control: cubit
    prop:
      - "${featureName.pascalCase}UpdateParam?:param"
      - "String?:invalid_message"
''';

String _customForm({required String featureName, required String sliceName}) =>
    '''
  - slice: ${sliceName}_form
    control: cubit
    prop:
      - "${featureName.pascalCase}${sliceName.pascalCase}Param?:param"
      - "String?:invalid_message"
''';
