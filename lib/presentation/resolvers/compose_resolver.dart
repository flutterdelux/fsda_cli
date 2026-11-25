import '../../core/constants/rules.dart';
import '../../domain/enums/compose_type.dart';
import '../../domain/params/app_integration/compose_param.dart';
import '../../domain/params/app_integration/reg_feature_param.dart';
import 'reg_feature_resolver.dart';

abstract final class ComposeResolverKeys {
  /// {@macro AppResolverKeys}
  static const app = RegFeatureResolverKeys.app;

  /// {@macro ModuleResolverKeys}
  static const module = RegFeatureResolverKeys.module;

  /// {@macro FeatureResolverKeys}
  static const feature = RegFeatureResolverKeys.feature;

  /// `type`
  static const type = 'type';

  /// `target`
  static const target = 'target';

  /// `logic-flow`
  static const logicFlow = 'logic-flow';

  /// `ui`
  static const ui = 'ui';

  /// `logic`
  static const logic = 'logic';

  /// `route`
  static const route = 'route';
}

abstract final class ComposeResolver {
  static ComposeParam resolve({
    required Map<String, dynamic> data,
    required RegFeatureParam regFeature,
  }) {
    // ============ type ============
    final rawType = data[ComposeResolverKeys.type];
    if (rawType == null || (rawType is String && rawType.trim().isEmpty)) {
      throw FormatException(
        'Compose type is required. Available: ${ComposeType.available}.',
      );
    }
    if (rawType is! String) {
      throw const FormatException('Compose type must be String type.');
    }

    final typeStr = rawType.trim().toLowerCase();
    final composeType = ComposeType.tryParse(typeStr);
    if (composeType == null) {
      throw FormatException(
        'Invalid compose type: "$typeStr". Available: ${ComposeType.available}.',
      );
    }

    // ============ target ============
    final rawTarget = data[ComposeResolverKeys.target];
    if (rawTarget == null ||
        (rawTarget is String && rawTarget.trim().isEmpty)) {
      throw const FormatException('Target artifact name is required.');
    }
    if (rawTarget is! String) {
      throw const FormatException('Target artifact name must be String type.');
    }

    final target = rawTarget.trim();
    if (!Rules.composeTargetRegExp.hasMatch(target)) {
      throw FormatException(
        'Invalid target name: "$target".\n'
        '${Rules.composeTargetDescription}',
      );
    }

    // ============ logic-flow ============
    final logicFlowSlice = _resolveRequiredSlice(
      data[ComposeResolverKeys.logicFlow],
      label: 'Logic flow slice',
    );

    // ============ variant-specific slices ============
    final String? uiSlice;
    final String? logicSlice;

    switch (composeType) {
      case ComposeType.mutation:
        uiSlice = null;
        logicSlice = null;
        break;
      case ComposeType.retrieval:
      case ComposeType.pagination:
        uiSlice = _resolveRequiredSlice(
          data[ComposeResolverKeys.ui],
          label: 'UI slice',
        );
        logicSlice = null;
        break;
      case ComposeType.form:
        uiSlice = _resolveRequiredSlice(
          data[ComposeResolverKeys.ui],
          label: 'UI slice',
        );
        logicSlice = _resolveRequiredSlice(
          data[ComposeResolverKeys.logic],
          label: 'Logic slice',
        );
        break;
    }

    // ============ withRoute ============
    final rawWithRoute = data[ComposeResolverKeys.route] ?? false;
    if (rawWithRoute is! bool) {
      throw const FormatException('Route must be bool type.');
    }

    return ComposeParam.fromRegFeature(
      regFeature: regFeature,
      type: composeType,
      target: target,
      logicFlowSlice: logicFlowSlice,
      uiSlice: uiSlice,
      logicSlice: logicSlice,
      withRoute: rawWithRoute,
    );
  }

  static String _resolveRequiredSlice(dynamic raw, {required String label}) {
    if (raw == null || (raw is String && raw.trim().isEmpty)) {
      throw FormatException('$label is required.');
    }
    if (raw is! String) {
      throw FormatException('$label must be String type.');
    }

    final slice = raw.trim();
    if (!Rules.sliceRegExp.hasMatch(slice)) {
      throw FormatException(
        'Invalid $label: "$slice".\n'
        '${Rules.sliceDescription}',
      );
    }

    return slice;
  }
}
