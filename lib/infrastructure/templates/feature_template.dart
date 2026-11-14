import '../text_modifiers/string_extension.dart';

abstract final class FeatureTemplate {
  static String initialBarrelContent() {
    return '''
// data
// domain
// logic
// ui
''';
  }

  static String startDividerArbKey(String feature) =>
      "${feature.camelCase}StartDivider";
  static String endDividerArbKey(String feature) =>
      "${feature.camelCase}EndDivider";

  static String buildArbSnippet(String feature) {
    final featureCamel = feature.camelCase;
    final featureTitle = feature.titleCase;
    return '''
  "@${startDividerArbKey(feature)}": {
    "description": "==================== Start: $featureTitle ===================="
  },
  "${startDividerArbKey(feature)}": ".",
  "${featureCamel}Label": "$featureTitle",
  "${endDividerArbKey(feature)}": ".",
  "@${endDividerArbKey(feature)}": {
    "description": "==================== End: $featureTitle ===================="
  }
''';
  }
}
