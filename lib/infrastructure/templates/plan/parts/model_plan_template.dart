import '../../../text_modifiers/string_extension.dart';

abstract final class ModelPlanTemplate {
  static String perSlice({
    required String featureName,
    required String sliceName,
  }) {
    return switch (sliceName) {
      'list' => _listResponse(featureName),
      'detail' =>
        '${_detailResponse(featureName)}\n  ${_detailParam(featureName)}',
      'create' => _createParam(featureName),
      'update' => _updateParam(featureName),
      'delete' => _deleteParam(featureName),
      _ => _custom(featureName: featureName, sliceName: sliceName),
    };
  }

  static String all(String featureName) =>
      '''
  ${_entity(featureName).trim()}
  ${_listResponse(featureName).trim()}
  ${_detailResponse(featureName).trim()}
  ${_detailParam(featureName).trim()}
  ${_createParam(featureName).trim()}
  ${_updateParam(featureName).trim()}
  ${_deleteParam(featureName).trim()}
''';
}

String _entity(String featureName) =>
    '''
  - name: ${featureName}_entity
    with-dto: true
    l10n: true
    prop:
      - "int:id"
      - "String:title"
      - "String:description"
      - "${featureName.pascalCase}Status:status::${featureName.pascalCase}StatusConverter"
      - "DateTime:created_at::UtcDateTimeConverter"
''';

String _listResponse(String featureName) =>
    '''
  - name: ${featureName}_list_response
    prop:
      - "String:message"
      - "List<${featureName.pascalCase}Dto>?:data"
''';

String _detailResponse(String featureName) =>
    '''
  - name: ${featureName}_detail_response
    prop:
      - "String:message"
      - "${featureName.pascalCase}Dto?:data"
''';

String _detailParam(String featureName) =>
    '''
  - name: ${featureName}_detail_param
    with-request: true
    prop:
      - "int:id"
''';

String _createParam(String featureName) =>
    '''
  - name: ${featureName}_create_param
    with-request: true
    prop:
      - "String:title"
      - "String:description"
''';

String _updateParam(String featureName) =>
    '''
  - name: ${featureName}_update_param
    with-request: true
    prop:
      - "int:id"
      - "String:title"
      - "String:description"
''';

String _deleteParam(String featureName) =>
    '''
  - name: ${featureName}_delete_param
    with-request: true
    prop:
      - "int:id"
''';

String _custom({required String featureName, required String sliceName}) =>
    '''
  - name: ${featureName}_${sliceName}_param
    with-request: true
    prop:
      - "int:id"
''';
