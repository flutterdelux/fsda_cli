import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import 'compose_pagination_cubit_template.dart';
import 'compose_pagination_getx_template.dart';
import 'compose_pagination_provider_template.dart';
import 'compose_pagination_riverpod_template.dart';

abstract final class ComposePaginationTemplate {
  static ArtifactGenerationModel build({
    required ComposeParam param,
    required LogicMetadata logicFlow,
  }) {
    return ArtifactGenerationModel(
      name: param.targetPascal,
      path: param.targetPath,
      content: switch (logicFlow.control) {
        .cubit => ComposePaginationCubitTemplate.content(
          param: param,
          logicFlow: logicFlow,
        ),
        .getx => ComposePaginationGetXTemplate.content(
          param: param,
          logicFlow: logicFlow,
        ),
        .provider => ComposePaginationProviderTemplate.content(
          param: param,
          logicFlow: logicFlow,
        ),
        .riverpod => ComposePaginationRiverpodTemplate.content(
          param: param,
          logicFlow: logicFlow,
        ),
      },
      typesToImport: {},
      needToExport: false,
    );
  }
}
