import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/dependency_metadata.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import 'compose_retrieval_cubit_template.dart';
import 'compose_retrieval_getx_template.dart';
import 'compose_retrieval_provider_template.dart';
import 'compose_retrieval_riverpod_template.dart';

abstract final class ComposeRetrievalTemplate {
  static ArtifactGenerationModel build({
    required ComposeParam param,
    required LogicMetadata logicFlow,
    required List<DependencyMetadata> uiMetadatas,
    required List<PropModel> constructorProps,
    required List<PropModel> methodProps,
  }) {
    return ArtifactGenerationModel(
      name: param.targetPascal,
      path: param.targetPath,
      content: switch (logicFlow.control) {
        .getx => ComposeRetrievalGetXTemplate.content(
          param: param,
          uiMetadatas: uiMetadatas,
          logicFlow: logicFlow,
          constructorProps: constructorProps,
          methodProps: methodProps,
        ),
        .provider => ComposeRetrievalProviderTemplate.content(
          param: param,
          uiMetadatas: uiMetadatas,
          logicFlow: logicFlow,
          constructorProps: constructorProps,
          methodProps: methodProps,
        ),
        .riverpod => ComposeRetrievalRiverpodTemplate.content(
          param: param,
          uiMetadatas: uiMetadatas,
          logicFlow: logicFlow,
          constructorProps: constructorProps,
          methodProps: methodProps,
        ),
        .cubit => ComposeRetrievalCubitTemplate.content(
          param: param,
          uiMetadatas: uiMetadatas,
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
