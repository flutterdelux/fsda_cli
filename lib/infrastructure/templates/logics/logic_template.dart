import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/params/logic_flow_param.dart';
import '../../../domain/params/logic_param.dart';
import 'cubit_flow_template.dart';
import 'cubit_template.dart';
import 'getx_flow_template.dart';
import 'getx_template.dart';
import 'provider_flow_template.dart';
import 'provider_template.dart';
import 'riverpod_flow_template.dart';
import 'riverpod_template.dart';

abstract final class LogicTemplate {
  static ArtifactGenerationModel build(LogicParam logic) {
    return switch (logic.control) {
      .cubit => CubitTemplate.build(logic),
      .getx => GetxTemplate.build(logic),
      .provider => ProviderTemplate.build(logic),
      .riverpod => RiverpodTemplate.build(logic),
    };
  }

  static ArtifactGenerationModel buildFlow(LogicFlowParam logic) {
    return switch (logic.control) {
      .cubit => CubitFlowTemplate.build(logic),
      .getx => GetxFlowTemplate.build(logic),
      .provider => ProviderFlowTemplate.build(logic),
      .riverpod => RiverpodFlowTemplate.build(logic),
    };
  }
}
