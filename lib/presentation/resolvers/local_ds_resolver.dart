import '../../core/constants/rules.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/local_ds_param.dart';

abstract final class LocalDsResolverKeys {
  /// `cache-key`
  static const cacheKey = 'cache-key';
}

abstract final class LocalDsResolver {
  static LocalDsParam resolve({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    // ============ cache-key ============
    final rawCacheKey = data[LocalDsResolverKeys.cacheKey];
    if (rawCacheKey == null) {
      throw const FormatException('Cache key is required.');
    }
    if (rawCacheKey is! String) {
      throw const FormatException('Cache key must be String type.');
    }

    final cacheKey = rawCacheKey.trim();
    if (cacheKey.isEmpty) {
      throw const FormatException('Cache key cannot be empty.');
    }

    if (!Rules.cacheKeyRegExp.hasMatch(cacheKey)) {
      throw FormatException(
        'Invalid cache key format: "$cacheKey".\n'
        '${Rules.cacheKeyDescription}',
      );
    }

    return LocalDsParam.fromFeature(feature: feature, cacheKey: cacheKey);
  }
}
