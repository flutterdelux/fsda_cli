import '../../core/constants/rules.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/slice_param.dart';

abstract final class SliceResolverKeys {
  /// `slice`
  static const slice = 'slice';
}

abstract final class SliceResolver {
  static SliceParam resolve({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    final rawSlice = data[SliceResolverKeys.slice];
    if (rawSlice == null || (rawSlice is String && rawSlice.trim().isEmpty)) {
      throw const FormatException('Slice name is required.');
    }

    if (rawSlice is! String) {
      throw const FormatException('Slice name must be String type.');
    }

    final slice = rawSlice.trim();
    if (!Rules.sliceRegExp.hasMatch(slice)) {
      throw FormatException(
        'Invalid slice name: "$slice".\n'
        '${Rules.sliceDescription}',
      );
    }

    return SliceParam.fromFeature(feature: feature, sliceName: slice);
  }
}
