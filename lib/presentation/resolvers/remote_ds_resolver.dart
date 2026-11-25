import '../../domain/params/feature_param.dart';
import '../../domain/params/remote_ds_param.dart';

abstract final class RemoteDsResolverKeys {
  /// `base-path`
  static const basePath = 'base-path';
}

abstract final class RemoteDsResolver {
  static RemoteDsParam resolve({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    // ============ base-path ============
    final rawBasePath = data[RemoteDsResolverKeys.basePath];
    if (rawBasePath == null) {
      throw const FormatException('Base path is required.');
    }
    if (rawBasePath is! String) {
      throw const FormatException('Base path must be String type.');
    }

    final basePath = rawBasePath.trim();
    if (basePath.isEmpty) {
      throw const FormatException('Base path cannot be empty.');
    }

    return RemoteDsParam.fromFeature(feature: feature, basePath: basePath);
  }
}
