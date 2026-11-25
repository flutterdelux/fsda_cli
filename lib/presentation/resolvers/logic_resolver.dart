import '../../core/extensions/prop_model_x.dart';
import '../../domain/enums/logic_flow_type.dart';
import '../../domain/enums/state_control.dart';
import '../../domain/models/prop_model.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/logic_flow_param.dart';
import '../../domain/params/logic_param.dart';
import 'prop_resolver.dart';
import 'sequence_resolver.dart';
import 'slice_resolver.dart';

abstract final class LogicResolverKeys {
  /// `slice`
  static const slice = SliceResolverKeys.slice;

  /// `prop`
  static const prop = 'prop';

  /// `control`
  static const control = 'control';

  /// `type`
  static const type = 'type';

  /// `uc`
  static const uc = SequenceResolverKeys.uc;
}

abstract final class LogicResolver {
  static StateControl resolveControl(Map<String, dynamic> data) {
    final rawControl = data[LogicResolverKeys.control];
    final isBlank =
        rawControl == null ||
        (rawControl is String && rawControl.trim().isEmpty);
    final effectiveRawControl = isBlank ? StateControl.cubit.value : rawControl;

    if (effectiveRawControl is! String) {
      throw const FormatException('State control must be String type.');
    }

    final controlStr = effectiveRawControl.trim().toLowerCase();
    final control = StateControl.tryParse(controlStr);
    if (control == null) {
      throw FormatException(
        'Invalid state control: "$controlStr". Available: ${StateControl.available}.',
      );
    }

    return control;
  }

  static LogicParam resolve({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    // ============ slice ============
    final slice = SliceResolver.resolve(data: data, feature: feature);

    // ============ control ============
    final control = resolveControl(data);

    // ============ prop ============
    final rawProps = data[LogicResolverKeys.prop];
    if (rawProps == null) {
      throw const FormatException('At least one property is required.');
    }
    if (rawProps is! List || rawProps.isEmpty) {
      throw const FormatException('Logic properties must be a non-empty List.');
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

    final props = parsedProps.map((e) => e.noConverter).toList(growable: false);

    return LogicParam.fromSliceGate(
      slice: slice,
      props: props,
      control: control,
    );
  }

  static LogicFlowParam resolveFlow({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    // ============ slice ============
    final slice = SliceResolver.resolve(data: data, feature: feature);

    // ============ type ============
    final rawType = data[LogicResolverKeys.type];
    if (rawType == null || (rawType is String && rawType.trim().isEmpty)) {
      final allowed = LogicFlowType.values.map((e) => e.value).join(', ');
      throw FormatException('Logic flow type is required ($allowed).');
    }
    if (rawType is! String) {
      throw const FormatException('Logic flow type must be String type.');
    }

    final typeStr = rawType.trim().toLowerCase();
    final logicType = LogicFlowType.tryParse(typeStr);
    if (logicType == null) {
      final allowed = LogicFlowType.values.map((e) => e.value).join(', ');
      throw FormatException(
        'Invalid logic flow type: "$typeStr". Allowed: $allowed.',
      );
    }

    // ============ uc ============
    final uc = SequenceResolver.resolveUsecase(data);

    // ============ control ============
    final control = resolveControl(data);

    return LogicFlowParam.fromSlice(
      slice: slice,
      type: logicType,
      uc: uc,
      control: control,
    );
  }
}
