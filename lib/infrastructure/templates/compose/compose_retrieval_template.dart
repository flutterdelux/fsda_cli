import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/dependency_metadata.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/params/app_integration/compose_retrieval_param.dart';
import 'compose_retrieval_cubit_template.dart';
import 'compose_retrieval_getx_template.dart';
import 'compose_retrieval_provider_template.dart';
import 'compose_retrieval_riverpod_template.dart';

abstract final class ComposeRetrievalTemplate {
  static ArtifactGenerationModel build({
    required ComposeRetrievalParam param,
    required LogicMetadata logicFlow,
    required List<DependencyMetadata> metadatas,
  }) {
    return ArtifactGenerationModel(
      name: param.targetPascal,
      path: param.targetPath,
      content: switch (logicFlow.control) {
        .getx => ComposeRetrievalGetXTemplate.content(
          param: param,
          metadatas: metadatas,
          logicFlow: logicFlow,
        ),
        .provider => ComposeRetrievalProviderTemplate.content(
          param: param,
          metadatas: metadatas,
          logicFlow: logicFlow,
        ),
        .riverpod => ComposeRetrievalRiverpodTemplate.content(
          param: param,
          metadatas: metadatas,
          logicFlow: logicFlow,
        ),
        .cubit => ComposeRetrievalCubitTemplate.content(
          param: param,
          metadatas: metadatas,
          logicFlow: logicFlow,
        ),
      },
      typesToImport: {},
      needToExport: false,
    );
  }
}
