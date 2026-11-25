import '../../core/constants/rules.dart';
import '../../core/extensions/prop_model_x.dart';
import '../../domain/enums/model_type.dart';
import '../../domain/models/prop_model.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/model_param.dart';
import 'prop_resolver.dart';

abstract final class ModelResolverKeys {
  /// `name`
  static const name = 'name';

  /// `prop`
  static const prop = 'prop';

  /// `l10n`
  static const isL10n = 'l10n';

  /// `with-dto`
  static const isWithDto = 'with-dto';

  /// `with-request`
  static const isWithRequest = 'with-request';
}

abstract final class ModelResolver {
  static ({String modelName, ModelType modelType, List<String> parts})
  resolveName(Map<String, dynamic> data) {
    final rawName = data[ModelResolverKeys.name];
    if (rawName == null) {
      throw const FormatException('Model name with type suffix is required.');
    }
    if (rawName is! String) {
      throw const FormatException('Model name must be String type.');
    }

    final modelName = rawName.trim();
    if (!Rules.modelRegExp.hasMatch(modelName)) {
      throw FormatException(
        'Invalid model name format: "$modelName".\n'
        '${Rules.modelDescription}',
      );
    }

    final parts = modelName.split('_');
    if (parts.length < 2) {
      throw FormatException(
        'Invalid model name: "$modelName". '
        'Model name must include a base name and a valid type suffix (e.g., task_entity, user_profile_dto).',
      );
    }

    final typeStr = parts.last;
    final modelType = ModelType.tryParse(typeStr);
    if (modelType == null) {
      throw FormatException(
        'Invalid model type suffix: "$typeStr". '
        'Supported type suffixes: ${ModelType.values.map((e) => e.suffix).join(', ')}.',
      );
    }

    return (modelName: modelName, modelType: modelType, parts: parts);
  }

  static List<ModelParam> resolve({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    // ============ name ============
    final (:modelName, :modelType, :parts) = resolveName(data);

    // ============ prop ============
    final rawProps = data[ModelResolverKeys.prop];
    if (rawProps == null) {
      throw const FormatException('At least one property is required.');
    }
    if (rawProps is! List || rawProps.isEmpty) {
      throw const FormatException('Model properties must be a non-empty List.');
    }

    final parsedProps = <PropModel>[];
    for (final item in rawProps) {
      final mapData = item is String
          ? PropResolver.fromDelimiter(item)
          : item is Map<String, dynamic>
          ? item
          : throw const FormatException(
              'Each property must be a String ("Type:name") or a Map.',
            );

      parsedProps.add(PropResolver.resolve(data: mapData));
    }
    final props = modelType == .entity || modelType == .param
        ? parsedProps.map((e) => e.noConverter).toList(growable: false)
        : parsedProps;

    // ============ l10n ============
    final rawL10n = data[ModelResolverKeys.isL10n] ?? false;
    if (rawL10n is! bool) {
      throw const FormatException(
        'Option "${ModelResolverKeys.isL10n}" must be bool type.',
      );
    }
    final isL10n = rawL10n && modelType == .entity;

    // ============ with-dto ============
    final isWithDto = data[ModelResolverKeys.isWithDto] ?? false;
    if (isWithDto is! bool) {
      throw const FormatException(
        'Option "${ModelResolverKeys.isWithDto}" must be bool type.',
      );
    }

    if (isWithDto && modelType != ModelType.entity) {
      throw const FormatException(
        'Invalid option "${ModelResolverKeys.isWithDto}": Only allowed for entity model type.',
      );
    }

    // ============ with-request ============
    final isWithRequest = data[ModelResolverKeys.isWithRequest] ?? false;
    if (isWithRequest is! bool) {
      throw const FormatException(
        'Option "${ModelResolverKeys.isWithRequest}" must be bool type.',
      );
    }

    if (isWithRequest && modelType != ModelType.param) {
      throw const FormatException(
        'Invalid option "${ModelResolverKeys.isWithRequest}": Only allowed for param model type.',
      );
    }

    final pairedModelType = isWithDto
        ? ModelType.dto
        : isWithRequest
        ? ModelType.request
        : null;

    return [
      ModelParam.fromFeature(
        feature: feature,
        type: modelType,
        modelName: modelName,
        props: props,
        isL10n: isL10n,
      ),
      if (pairedModelType != null)
        ModelParam.fromFeature(
          feature: feature,
          type: pairedModelType,
          modelName:
              '${parts.sublist(0, parts.length - 1).join('_')}_${pairedModelType.suffix}',
          props: parsedProps,
          isL10n: isL10n,
        ),
    ];
  }
}
