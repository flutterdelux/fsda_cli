import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/params/app_integration/compose_mutation_param.dart';
import 'compose_mutation_cubit_template.dart';
import 'compose_mutation_getx_template.dart';
import 'compose_mutation_provider_template.dart';
import 'compose_mutation_riverpod_template.dart';

abstract final class ComposeMutationTemplate {
  static ArtifactGenerationModel build({
    required ComposeMutationParam param,
    required LogicMetadata logicFlow,
  }) {
    return ArtifactGenerationModel(
      name: param.targetPascal,
      path: param.targetPath,
      content: switch (logicFlow.control) {
        .cubit => ComposeMutationCubitTemplate.content(
          param: param,
          logicFlow: logicFlow,
        ),
        .getx => ComposeMutationGetXTemplate.content(
          param: param,
          logicFlow: logicFlow,
        ),
        .provider => ComposeMutationProviderTemplate.content(
          param: param,
          logicFlow: logicFlow,
        ),
        .riverpod => ComposeMutationRiverpodTemplate.content(
          param: param,
          logicFlow: logicFlow,
        ),
      },
      typesToImport: {},
      needToExport: false,
    );
  }
}
