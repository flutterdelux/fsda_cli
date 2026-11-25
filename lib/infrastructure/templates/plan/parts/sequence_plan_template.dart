abstract final class SequencePlanTemplate {
  static String perSlice({
    required String featureName,
    required String sliceName,
  }) {
    return switch (sliceName) {
      'list' => _list(featureName),
      'detail' => _detail(featureName),
      'create' => _create(featureName),
      'update' => _update(featureName),
      'delete' => _delete(featureName),
      _ => _custom(featureName: featureName, sliceName: sliceName),
    };
  }

  static String all(String featureName) {
    return '''
  ${_list(featureName).trim()}
  ${_detail(featureName).trim()}
  ${_create(featureName).trim()}
  ${_update(featureName).trim()}
  ${_delete(featureName).trim()}
''';
  }
}

String _list(String featureName) {
  return '''
  - uc: ${featureName}_list_use_case
    act: get
    method: get_${featureName}_list
    flow: async
    ds: remote
    list: true
    model:
      - ${featureName}_dto
      - ${featureName}_entity
      - ${featureName}_list_response
''';
}

String _detail(String featureName) {
  return '''
  - uc: ${featureName}_detail_use_case
    act: get
    method: get_${featureName}_detail
    flow: async
    ds: remote
    model:
      - ${featureName}_dto
      - ${featureName}_entity
      - ${featureName}_detail_response
      - ${featureName}_detail_param
      - ${featureName}_detail_request
''';
}

String _create(String featureName) {
  return '''
  - uc: ${featureName}_create_use_case
    act: post
    method: create_$featureName
    flow: async
    ds: remote
    model:
      - ${featureName}_create_param
      - ${featureName}_create_request
''';
}

String _update(String featureName) {
  return '''
  - uc: ${featureName}_update_use_case
    act: put
    method: update_$featureName
    flow: async
    ds: remote
    model:
      - ${featureName}_update_param
      - ${featureName}_update_request
''';
}

String _delete(String featureName) {
  return '''
  - uc: ${featureName}_delete_use_case
    act: delete
    method: delete_$featureName
    flow: async
    ds: remote
    model:
      - ${featureName}_delete_param
      - ${featureName}_delete_request
''';
}

String _custom({required String featureName, required String sliceName}) {
  return '''
  - uc: ${featureName}_${sliceName}_use_case
    act: post
    method: ${sliceName}_$featureName
    flow: async
    ds: remote
    model:
      - ${featureName}_dto
      - ${featureName}_entity
      - ${featureName}_${sliceName}_response
      - ${featureName}_${sliceName}_param
      - ${featureName}_${sliceName}_request
''';
}
