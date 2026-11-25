abstract final class UiPlanTemplate {
  static String perSlice({
    required String featureName,
    required String sliceName,
  }) {
    return switch (sliceName) {
      'list' => _list(featureName),
      'detail' => _detail(featureName),
      'create' => _createForm(featureName),
      'update' => _updateForm(featureName),
      'delete' => '',
      _ => _custom(featureName: featureName, sliceName: sliceName),
    };
  }

  static String all(String featureName) =>
      '''
  ${_list(featureName).trim()}
  ${_detail(featureName).trim()}
  ${_createForm(featureName).trim()}
  ${_updateForm(featureName).trim()}
''';
}

String _list(String featureName) =>
    '''
  - slice: list
    type: lsv
    model: ${featureName}_entity
''';

String _detail(String featureName) =>
    '''
  - slice: detail
    type: standard
    model: ${featureName}_entity
''';

String _createForm(String featureName) =>
    '''
  - slice: create_form
    type: form
    model: ${featureName}_create_param
    field:
      - "text:String:title"
      - "text_area:String:description"
''';

String _updateForm(String featureName) =>
    '''
  - slice: update_form
    type: form
    model: ${featureName}_update_param
    initial: true
    field:
      - "text:String:title"
      - "text_area:String:description"
''';

String _custom({required String featureName, required String sliceName}) =>
    '''
  - slice: $sliceName
    type: standard
    model: ${featureName}_entity
''';
