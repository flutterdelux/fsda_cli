import '../../core/constants/rules.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/module_param.dart';

abstract final class FeatureResolverKeys {
  /// {@template FeatureResolverKeys}
  /// `feature`
  /// {@endtemplate}
  static const feature = 'feature';
}

abstract final class FeatureResolver {
  static FeatureParam resolve({
    required Map<String, dynamic> data,
    required ModuleParam module,
  }) {
    // ============ feature ============
    final rawFeature = data[FeatureResolverKeys.feature];
    if (rawFeature == null) {
      throw const FormatException('Feature name is required.');
    }
    if (rawFeature is! String) {
      throw const FormatException('Feature name must be String type.');
    }

    final featureName = rawFeature.trim();
    if (featureName.isEmpty) {
      throw const FormatException('Feature name cannot be empty.');
    }

    if (!Rules.featureRegExp.hasMatch(featureName)) {
      throw FormatException(
        'Invalid feature name: "$featureName".\n'
        '${Rules.featureDescription}',
      );
    }

    return FeatureParam.fromModule(module: module, featureName: featureName);
  }
}
