import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/params/app_integration/compose_form_param.dart';
import 'compose_form_cubit_template.dart';
import 'compose_form_getx_template.dart';
import 'compose_form_provider_template.dart';
import 'compose_form_riverpod_template.dart';

abstract final class ComposeFormTemplate {
  static ArtifactGenerationModel build({
    required ComposeFormParam param,
    required LogicMetadata logicFlow,
    required LogicMetadata logic,
  }) {
    return ArtifactGenerationModel(
      name: param.targetPascal,
      path: param.targetPath,
      content: switch (logicFlow.control) {
        .cubit => ComposeFormCubitTemplate.content(
          param: param,
          logicFlow: logicFlow,
          logic: logic,
        ),
        .getx => ComposeFormGetXTemplate.content(
          param: param,
          logicFlow: logicFlow,
          logic: logic,
        ),
        .provider => ComposeFormProviderTemplate.content(
          param: param,
          logicFlow: logicFlow,
          logic: logic,
        ),

        .riverpod => ComposeFormRiverpodTemplate.content(
          param: param,
          logicFlow: logicFlow,
          logic: logic,
        ),
      },
      typesToImport: {},
      needToExport: false,
    );
  }
}
