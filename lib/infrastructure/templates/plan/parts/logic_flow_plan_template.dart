abstract final class LogicFlowPlanTemplate {
  static String perSlice({
    required String featureName,
    required String sliceName,
  }) {
    return switch (sliceName) {
      'list' => _flow(featureName: featureName, sliceName: 'list', type: 'r'),
      'detail' => _flow(
        featureName: featureName,
        sliceName: 'detail',
        type: 'r',
      ),
      'create' => _flow(
        featureName: featureName,
        sliceName: 'create',
        type: 'm',
      ),
      'update' => _flow(
        featureName: featureName,
        sliceName: 'update',
        type: 'm',
      ),
      'delete' => _flow(
        featureName: featureName,
        sliceName: 'delete',
        type: 'm',
      ),
      _ => _flow(featureName: featureName, sliceName: sliceName, type: 'm'),
    };
  }

  static String all(String featureName) =>
      '''
  ${perSlice(featureName: featureName, sliceName: 'list').trim()}
  ${perSlice(featureName: featureName, sliceName: 'detail').trim()}
  ${perSlice(featureName: featureName, sliceName: 'create').trim()}
  ${perSlice(featureName: featureName, sliceName: 'update').trim()}
  ${perSlice(featureName: featureName, sliceName: 'delete').trim()}
''';
}

String _flow({
  required String featureName,
  required String sliceName,
  required String type,
}) =>
    '''
  - slice: $sliceName
    type: $type
    uc: ${featureName}_${sliceName}_use_case
    control: cubit
''';
