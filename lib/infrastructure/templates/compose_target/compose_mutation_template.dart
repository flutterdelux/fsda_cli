import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import 'compose_mutation_cubit_template.dart';
import 'compose_mutation_getx_template.dart';
import 'compose_mutation_provider_template.dart';
import 'compose_mutation_riverpod_template.dart';

abstract final class ComposeMutationTemplate {
  static ArtifactGenerationModel build({
    required ComposeParam param,
    required LogicMetadata logicFlow,
    required List<PropModel> constructorProps,
    required List<PropModel> methodProps,
  }) {
    return ArtifactGenerationModel(
      name: param.targetPascal,
      path: param.targetPath,
      content: switch (logicFlow.control) {
        .cubit => ComposeMutationCubitTemplate.content(
          param: param,
          logicFlow: logicFlow,
          constructorProps: constructorProps,
          methodProps: methodProps,
        ),
        .getx => ComposeMutationGetXTemplate.content(
          param: param,
          logicFlow: logicFlow,
          constructorProps: constructorProps,
          methodProps: methodProps,
        ),
        .provider => ComposeMutationProviderTemplate.content(
          param: param,
          logicFlow: logicFlow,
          constructorProps: constructorProps,
          methodProps: methodProps,
        ),
        .riverpod => ComposeMutationRiverpodTemplate.content(
          param: param,
          logicFlow: logicFlow,
          constructorProps: constructorProps,
          methodProps: methodProps,
        ),
      },
      typesToImport: {},
      needToExport: false,
    );
  }
}
