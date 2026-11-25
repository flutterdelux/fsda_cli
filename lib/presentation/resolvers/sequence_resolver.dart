import 'package:collection/collection.dart';

import '../../core/constants/rules.dart';
import '../../domain/enums/action.dart';
import '../../domain/enums/ds_mode.dart';
import '../../domain/enums/flow_type.dart';
import '../../domain/enums/model_type.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/sequence_param.dart';

abstract final class SequenceResolverKeys {
  /// `action`
  static const action = 'act';

  /// `uc`
  static const uc = 'uc';

  /// `method`
  static const method = 'method';

  /// `flow`
  static const flow = 'flow';

  /// `ds`
  static const ds = 'ds';

  /// `list`
  static const isList = 'list';

  /// `model`
  static const model = 'model';
}

abstract final class SequenceResolver {
  static String resolveUsecase(Map<String, dynamic> data) {
    final rawUc = data[SequenceResolverKeys.uc];
    if (rawUc == null || (rawUc is String && rawUc.trim().isEmpty)) {
      throw const FormatException('Use case name is required.');
    }
    if (rawUc is! String) {
      throw const FormatException('Use case name must be String type.');
    }

    final usecase = rawUc.trim();
    if (!Rules.usecaseRegExp.hasMatch(usecase)) {
      throw FormatException(
        'Invalid use case name: "$usecase".\n'
        '${Rules.usecaseDescription}',
      );
    }

    if (!usecase.endsWith('_use_case')) {
      throw FormatException(
        'Invalid use case name: "$usecase". Must end with "_use_case" (e.g., task_create_use_case).',
      );
    }

    return usecase;
  }

  static String resolveMethod(Map<String, dynamic> data) {
    final rawMethod = data[SequenceResolverKeys.method];
    if (rawMethod == null ||
        (rawMethod is String && rawMethod.trim().isEmpty)) {
      throw const FormatException('Method name is required.');
    }
    if (rawMethod is! String) {
      throw const FormatException('Method name must be String type.');
    }

    final method = rawMethod.trim();
    if (!Rules.methodRegExp.hasMatch(method)) {
      throw FormatException(
        'Invalid method name: "$method".\n'
        '${Rules.methodDescription}',
      );
    }

    return method;
  }

  static DsMode resolveDsMode(Map<String, dynamic> data) {
    final rawDs = data[SequenceResolverKeys.ds];
    if (rawDs == null) {
      throw const FormatException('Datasource mode is required.');
    }

    if (rawDs is! String) {
      throw const FormatException('Datasource mode must be String type.');
    }

    final dsStr = rawDs.trim().toLowerCase();
    final dsMode = DsMode.tryParse(dsStr);
    if (dsMode == null) {
      throw FormatException(
        'Invalid datasource mode: "$dsStr". Allowed: ${DsMode.values.map((e) => e.value).join(', ')}.',
      );
    }

    return dsMode;
  }

  static SequenceParam resolve({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    // ============ action ============
    final rawAction = data[SequenceResolverKeys.action];
    if (rawAction == null ||
        (rawAction is String && rawAction.trim().isEmpty)) {
      throw FormatException(
        'Action is required (${Action.values.map((e) => e.value).join(', ')}).',
      );
    }
    if (rawAction is! String) {
      throw const FormatException('Action must be String type.');
    }

    final actionStr = rawAction.trim().toLowerCase();
    final action = Action.tryParse(actionStr);
    if (action == null) {
      throw FormatException(
        'Invalid action: "$actionStr". Allowed: ${Action.values.map((e) => e.value).join(', ')}.',
      );
    }

    // ============ uc, method, ds ============
    final usecase = resolveUsecase(data);
    final method = resolveMethod(data);
    final dsMode = resolveDsMode(data);

    // ============ flow ============
    final rawFlow = data[SequenceResolverKeys.flow];
    final isFlowBlank =
        rawFlow == null || (rawFlow is String && rawFlow.trim().isEmpty);
    final effectiveRawFlow = isFlowBlank
        ? FlowType.asynchronous.value
        : rawFlow;

    if (effectiveRawFlow is! String) {
      throw const FormatException('Flow type must be String type.');
    }

    final flowStr = effectiveRawFlow.trim().toLowerCase();
    final flow = FlowType.tryParse(flowStr);
    if (flow == null) {
      throw FormatException(
        'Invalid flow type: "$flowStr". Allowed: ${FlowType.values.map((e) => e.value).join(', ')}.',
      );
    }

    // ============ list ============
    final rawList = data[SequenceResolverKeys.isList] ?? false;
    if (rawList is! bool) {
      throw const FormatException('List flag must be bool type.');
    }

    // ============ model ============
    final mappedModels = _resolveModels(data[SequenceResolverKeys.model]);

    return SequenceParam.fromFeature(
      feature: feature,
      action: action,
      usecase: usecase,
      method: method,
      flow: flow,
      dsMode: dsMode,
      isList: rawList,
      response: mappedModels[ModelType.response],
      dto: mappedModels[ModelType.dto],
      entity: mappedModels[ModelType.entity],
      request: mappedModels[ModelType.request],
      param: mappedModels[ModelType.param],
    );
  }

  /// Resolve minimal untuk `rm-sequence`
  static SequenceParam resolveRemoval({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    final usecase = resolveUsecase(data);
    final method = resolveMethod(data);
    final dsMode = resolveDsMode(data);

    return SequenceParam.fromFeature(
      feature: feature,
      action: Action.post,
      usecase: usecase,
      method: method,
      flow: FlowType.asynchronous,
      dsMode: dsMode,
    );
  }

  static Map<ModelType, String> _resolveModels(dynamic rawModels) {
    if (rawModels == null) return const {};

    if (rawModels is! List) {
      throw const FormatException('Models must be a List of model names.');
    }

    final result = <ModelType, String>{};
    final allowedSuffixes = ModelType.values
        .map((e) => '_${e.suffix}')
        .join(', ');

    for (final item in rawModels) {
      if (item is! String) {
        throw const FormatException('Each model entry must be String type.');
      }

      final modelName = item.trim();
      if (modelName.isEmpty) continue;

      final matchedType = ModelType.values.firstWhereOrNull(
        (type) => modelName.endsWith('_${type.suffix}'),
      );

      if (matchedType == null) {
        throw FormatException(
          'Invalid model name format: "$modelName". Must end with $allowedSuffixes.',
        );
      }

      if (result.containsKey(matchedType)) {
        throw FormatException(
          'Duplicate model type "_${matchedType.suffix}" specified more than once.',
        );
      }

      result[matchedType] = modelName;
    }

    // ============ Paired Model Validation ============
    final hasEntity = result.containsKey(ModelType.entity);
    final hasDto = result.containsKey(ModelType.dto);
    if (hasEntity != hasDto) {
      throw FormatException(
        hasEntity
            ? 'Model "${result[ModelType.entity]}" requires a paired "_${ModelType.dto.suffix}" model.'
            : 'Model "${result[ModelType.dto]}" requires a paired "_${ModelType.entity.suffix}" model.',
      );
    }

    final hasRequest = result.containsKey(ModelType.request);
    final hasParam = result.containsKey(ModelType.param);
    if (hasRequest != hasParam) {
      throw FormatException(
        hasRequest
            ? 'Model "${result[ModelType.request]}" requires a paired "_${ModelType.param.suffix}" model.'
            : 'Model "${result[ModelType.param]}" requires a paired "_${ModelType.request.suffix}" model.',
      );
    }

    return result;
  }
}
