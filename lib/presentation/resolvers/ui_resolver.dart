import '../../core/constants/rules.dart';
import '../../domain/enums/ui_type.dart';
import '../../domain/models/form_field_model.dart';
import '../../domain/params/feature_param.dart';

import '../../domain/params/ui_param.dart';
import 'form_field_resolver.dart';
import 'slice_resolver.dart';

abstract final class UiResolverKeys {
  /// `slice`
  static const slice = SliceResolverKeys.slice;

  /// `type`
  static const type = 'type';

  /// `model`
  static const model = 'model';

  /// `field`
  static const field = 'field';

  /// `initial`
  static const initial = 'initial';
}

abstract final class UiResolver {
  static const defaultUiType = UiType.standard;

  static UiParam resolve({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    // ============ slice ============
    final slice = SliceResolver.resolve(data: data, feature: feature);

    // ============ type ============
    final rawType = data[UiResolverKeys.type];
    final isTypeBlank =
        rawType == null || (rawType is String && rawType.trim().isEmpty);
    final effectiveRawType = isTypeBlank ? defaultUiType.value : rawType;

    if (effectiveRawType is! String) {
      throw const FormatException('UI type must be String type.');
    }

    final typeStr = effectiveRawType.trim().toLowerCase();
    final uiType = UiType.tryParse(typeStr);
    if (uiType == null) {
      throw FormatException(
        'Invalid UI type: "$typeStr". Available: ${UiType.available}.',
      );
    }

    // ============ model ============
    final rawModel = data[UiResolverKeys.model];
    if (rawModel == null || (rawModel is String && rawModel.trim().isEmpty)) {
      throw const FormatException('Model name is required.');
    }
    if (rawModel is! String) {
      throw const FormatException('Model name must be String type.');
    }

    final model = rawModel.trim();
    if (!Rules.modelTypeRegExp.hasMatch(model) ||
        !(model.endsWith('_entity') || model.endsWith('_param'))) {
      throw FormatException(
        'Invalid object model: "$model".\n'
        '${Rules.modelTypeDescription}',
      );
    }

    // ============ form-specific options ============
    List<FormFieldModel>? fields;
    var hasInitial = false;

    if (uiType == UiType.form) {
      final rawFields = data[UiResolverKeys.field];
      if (rawFields == null) {
        throw const FormatException('At least one form field is required.');
      }
      if (rawFields is! List || rawFields.isEmpty) {
        throw const FormatException('Form fields must be a non-empty List.');
      }

      fields = rawFields
          .map((item) {
            final mapData = item is String
                ? FormFieldResolver.fromDelimiter(item)
                : item is Map<String, dynamic>
                ? item
                : throw const FormatException(
                    'Each field must be a String ("input_type:value_type:name[:default]") or a Map.',
                  );
            return FormFieldResolver.resolve(data: mapData);
          })
          .toList(growable: false);

      final rawInitial = data[UiResolverKeys.initial] ?? false;
      if (rawInitial is! bool) {
        throw const FormatException('Initial flag must be bool type.');
      }
      hasInitial = rawInitial;
    }

    return UiParam.fromSlice(
      slice: slice,
      type: uiType,
      model: model,
      fields: fields,
      hasInitial: hasInitial,
    );
  }
}
