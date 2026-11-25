import 'package:yaml/yaml.dart';

import '../../domain/models/plan_model.dart';
import '../../domain/params/app_integration/compose_param.dart';
import '../../domain/params/ds_param.dart';
import '../../domain/params/enum_param.dart';
import '../../domain/params/failure_param.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/input_param.dart';
import '../../domain/params/logic_flow_param.dart';
import '../../domain/params/logic_param.dart';
import '../../domain/params/model_param.dart';
import '../../domain/params/sequence_param.dart';
import '../../domain/params/ui_param.dart';
import '../../domain/params/workspace_param.dart';
import 'app_resolver.dart';
import 'compose_resolver.dart';
import 'enum_resolver.dart';
import 'failure_resolver.dart';
import 'feature_resolver.dart';
import 'input_resolver.dart';
import 'local_ds_resolver.dart';
import 'logic_resolver.dart';
import 'model_resolver.dart';
import 'module_resolver.dart';
import 'reg_feature_resolver.dart';
import 'reg_module_resolver.dart';
import 'remote_ds_resolver.dart';
import 'sequence_resolver.dart';
import 'slice_resolver.dart';
import 'ui_resolver.dart';

abstract final class PlanResolverKeys {
  static const failure = 'failure';
  static const ds = 'ds';
  static const remote = 'remote';
  static const local = 'local';
  static const enumKey = 'enum';
  static const model = 'model';
  static const sequence = 'sequence';
  static const logic = 'logic';
  static const logicFlow = 'logic-flow';
  static const input = 'input';
  static const ui = 'ui';
  static const compose = 'compose';
}

abstract final class PlanResolver {
  static PlanModel resolveYaml({
    required String yamlContent,
    required WorkspaceParam workspace,
  }) {
    final dynamic loaded;
    try {
      loaded = loadYaml(yamlContent);
    } catch (e) {
      throw FormatException('Invalid YAML syntax: $e');
    }

    if (loaded == null) {
      throw const FormatException('Plan file is empty.');
    }
    if (loaded is! YamlMap) {
      throw const FormatException('Plan root must be a YAML map.');
    }

    final data = _toPlainMap(loaded);
    return resolve(data: data, workspace: workspace);
  }

  static PlanModel resolve({
    required Map<String, dynamic> data,
    required WorkspaceParam workspace,
  }) {
    final hasApp = data.containsKey(AppResolverKeys.app);
    final hasModule = data.containsKey(ModuleResolverKeys.module);
    final hasFeature = data.containsKey(FeatureResolverKeys.feature);
    final hasSlice = data.containsKey(SliceResolverKeys.slice);

    if (hasApp && !hasModule && !hasFeature && !hasSlice) {
      return _resolveAppPlan(data: data, workspace: workspace);
    }
    if (hasModule && !hasFeature && !hasSlice && !hasApp) {
      return _resolveModulePlan(data: data, workspace: workspace);
    }
    if (hasModule && hasFeature && !hasSlice && !hasApp) {
      return _resolveFeaturePlan(data: data, workspace: workspace);
    }
    if (hasModule && hasFeature && hasSlice && !hasApp) {
      return _resolveSlicePlan(data: data, workspace: workspace);
    }

    throw const FormatException(
      'Unable to determine plan type. Root must define one of:\n'
      '  - "module" (Module Plan)\n'
      '  - "module" + "feature" (Feature Plan)\n'
      '  - "module" + "feature" + "slice" (Slice Plan)\n'
      '  - "app" (App Compose Plan)',
    );
  }

  // ==================== App Compose Plan ====================
  static AppPlanModel _resolveAppPlan({
    required Map<String, dynamic> data,
    required WorkspaceParam workspace,
  }) {
    final app = AppResolver.resolve(data: data, workspace: workspace);

    final composes = _resolveListSection<ComposeParam>(
      rawSection: data[PlanResolverKeys.compose],
      sectionName: PlanResolverKeys.compose,
      itemResolver: (item) {
        final merged = {AppResolverKeys.app: app.appName, ...item};
        final regModule = RegModuleResolver.resolve(
          data: merged,
          workspace: workspace,
        );
        final regFeature = RegFeatureResolver.resolve(
          data: merged,
          regModule: regModule,
        );
        return ComposeResolver.resolve(data: merged, regFeature: regFeature);
      },
    );

    return AppPlanModel(app: app, composes: composes);
  }

  // ==================== Module Plan ====================
  static ModulePlanModel _resolveModulePlan({
    required Map<String, dynamic> data,
    required WorkspaceParam workspace,
  }) {
    final module = ModuleResolver.resolve(data: data, workspace: workspace);

    final rawFailures = data[PlanResolverKeys.failure];
    final failures = rawFailures == null
        ? const <FailureParam>[]
        : FailureResolver.resolveAll(
            data: {FailureResolverKeys.failure: rawFailures},
            module: module,
          );

    return ModulePlanModel(module: module, failures: failures);
  }

  // ==================== Feature Plan ====================
  static FeaturePlanModel _resolveFeaturePlan({
    required Map<String, dynamic> data,
    required WorkspaceParam workspace,
  }) {
    final module = ModuleResolver.resolve(data: data, workspace: workspace);
    final feature = FeatureResolver.resolve(data: data, module: module);
    final sections = _resolveFeatureSections(data: data, feature: feature);

    return FeaturePlanModel(
      feature: feature,
      datasources: sections.datasources,
      enums: sections.enums,
      models: sections.models,
      sequences: sections.sequences,
      logics: sections.logics,
      logicFlows: sections.logicFlows,
      inputs: sections.inputs,
      uis: sections.uis,
    );
  }

  // ==================== Slice Plan ====================
  static SlicePlanModel _resolveSlicePlan({
    required Map<String, dynamic> data,
    required WorkspaceParam workspace,
  }) {
    final module = ModuleResolver.resolve(data: data, workspace: workspace);
    final feature = FeatureResolver.resolve(data: data, module: module);
    final slice = SliceResolver.resolve(data: data, feature: feature);
    final sections = _resolveFeatureSections(data: data, feature: slice);

    return SlicePlanModel(
      slice: slice,
      datasources: sections.datasources,
      enums: sections.enums,
      models: sections.models,
      sequences: sections.sequences,
      logics: sections.logics,
      logicFlows: sections.logicFlows,
      inputs: sections.inputs,
      uis: sections.uis,
    );
  }

  // ==================== Shared Feature/Slice Sections ====================
  static ({
    List<DsParam> datasources,
    List<EnumParam> enums,
    List<ModelParam> models,
    List<SequenceParam> sequences,
    List<LogicParam> logics,
    List<LogicFlowParam> logicFlows,
    List<InputParam> inputs,
    List<UiParam> uis,
  })
  _resolveFeatureSections({
    required Map<String, dynamic> data,
    required FeatureParam feature,
  }) {
    // 1. Datasources
    final datasources = <DsParam>[];
    final rawDs = data[PlanResolverKeys.ds];
    if (rawDs != null) {
      if (rawDs is! Map<String, dynamic>) {
        throw const FormatException('"ds" section must be a Map.');
      }
      if (rawDs.containsKey(PlanResolverKeys.remote)) {
        final remoteData = _asMap(rawDs[PlanResolverKeys.remote], 'ds.remote');
        datasources.add(
          RemoteDsResolver.resolve(data: remoteData, feature: feature),
        );
      }
      if (rawDs.containsKey(PlanResolverKeys.local)) {
        final localData = _asMap(rawDs[PlanResolverKeys.local], 'ds.local');
        datasources.add(
          LocalDsResolver.resolve(data: localData, feature: feature),
        );
      }
    }

    // 2. Enums
    final enums = _resolveListSection<EnumParam>(
      rawSection: data[PlanResolverKeys.enumKey],
      sectionName: PlanResolverKeys.enumKey,
      itemResolver: (item) =>
          EnumResolver.resolve(data: item, feature: feature),
    );

    // 3. Models (flatten List<ModelParam>)
    final models = _resolveFlatListSection<ModelParam>(
      rawSection: data[PlanResolverKeys.model],
      sectionName: PlanResolverKeys.model,
      itemResolver: (item) =>
          ModelResolver.resolve(data: item, feature: feature),
    );

    // 4. Sequences
    final sequences = _resolveListSection<SequenceParam>(
      rawSection: data[PlanResolverKeys.sequence],
      sectionName: PlanResolverKeys.sequence,
      itemResolver: (item) =>
          SequenceResolver.resolve(data: item, feature: feature),
    );

    // 5. Logic (state)
    final logics = _resolveListSection<LogicParam>(
      rawSection: data[PlanResolverKeys.logic],
      sectionName: PlanResolverKeys.logic,
      itemResolver: (item) =>
          LogicResolver.resolve(data: item, feature: feature),
    );

    // 6. Logic Flow
    final logicFlows = _resolveListSection<LogicFlowParam>(
      rawSection: data[PlanResolverKeys.logicFlow],
      sectionName: PlanResolverKeys.logicFlow,
      itemResolver: (item) =>
          LogicResolver.resolveFlow(data: item, feature: feature),
    );

    // 7. Inputs
    final inputs = _resolveListSection<InputParam>(
      rawSection: data[PlanResolverKeys.input],
      sectionName: PlanResolverKeys.input,
      itemResolver: (item) =>
          InputResolver.resolve(data: item, feature: feature),
    );

    // 8. UIs
    final uis = _resolveListSection<UiParam>(
      rawSection: data[PlanResolverKeys.ui],
      sectionName: PlanResolverKeys.ui,
      itemResolver: (item) => UiResolver.resolve(data: item, feature: feature),
    );

    return (
      datasources: datasources,
      enums: enums,
      models: models,
      sequences: sequences,
      logics: logics,
      logicFlows: logicFlows,
      inputs: inputs,
      uis: uis,
    );
  }

  // ==================== Helpers ====================
  static List<T> _resolveListSection<T>({
    required dynamic rawSection,
    required String sectionName,
    required T Function(Map<String, dynamic> item) itemResolver,
  }) {
    if (rawSection == null) return const [];
    if (rawSection is! List) {
      throw FormatException('"$sectionName" section must be a List.');
    }

    final results = <T>[];
    for (var i = 0; i < rawSection.length; i++) {
      final entry = rawSection[i];
      if (entry is! Map<String, dynamic>) {
        throw FormatException(
          'Entry #${i + 1} in "$sectionName" must be a Map.',
        );
      }
      try {
        results.add(itemResolver(entry));
      } on FormatException catch (e) {
        throw FormatException('[$sectionName #${i + 1}] ${e.message}');
      }
    }
    return results;
  }

  static List<T> _resolveFlatListSection<T>({
    required dynamic rawSection,
    required String sectionName,
    required List<T> Function(Map<String, dynamic> item) itemResolver,
  }) {
    if (rawSection == null) return const [];
    if (rawSection is! List) {
      throw FormatException('"$sectionName" section must be a List.');
    }

    final results = <T>[];
    for (var i = 0; i < rawSection.length; i++) {
      final entry = rawSection[i];
      if (entry is! Map<String, dynamic>) {
        throw FormatException(
          'Entry #${i + 1} in "$sectionName" must be a Map.',
        );
      }
      try {
        results.addAll(itemResolver(entry));
      } on FormatException catch (e) {
        throw FormatException('[$sectionName #${i + 1}] ${e.message}');
      }
    }
    return results;
  }

  static Map<String, dynamic> _asMap(dynamic value, String label) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('"$label" must be a Map.');
  }

  static Map<String, dynamic> _toPlainMap(YamlMap yamlMap) {
    final map = <String, dynamic>{};
    for (final entry in yamlMap.entries) {
      map[entry.key.toString()] = _toPlainValue(entry.value);
    }
    return map;
  }

  static dynamic _toPlainValue(dynamic value) {
    if (value is YamlMap) return _toPlainMap(value);
    if (value is YamlList) return value.map(_toPlainValue).toList();
    return value;
  }
}
