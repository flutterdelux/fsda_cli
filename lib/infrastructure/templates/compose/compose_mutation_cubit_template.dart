import '../../../core/extensions/app_integration_param_x.dart';
import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/params/app_integration/compose_mutation_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposeMutationCubitTemplate {
  static String content({
    required ComposeMutationParam param,
    required LogicMetadata logicFlow,
  }) {
    final featureLogicFlowSlice = [
      param.featureName!,
      param.logicFlowSlice,
    ].join('_');
    return '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:${param.moduleName}/${param.moduleName}.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/failure_x.dart';
import '../../../../../core/mixins/page_bloc_mixin.dart';

class ${param.targetPascal} extends StatelessWidget with PageBlocMixin {
  const ${param.targetPascal}({super.key});

  void _${logicFlow.method}(BuildContext context) {
    context.read<${logicFlow.className}>().${logicFlow.method}();
  }

  void _${featureLogicFlowSlice.camelCase}Listener(BuildContext context, ${featureLogicFlowSlice.pascalCase}State state) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    state.maybeWhen(
      orElse: () => null,
      failure: (failure) =>
          context.showErrorSnackbar(failure.localizeAny(context)),
      success: () {
        context.showSuccessSnackbar(${param.moduleCamel}L10n.${featureLogicFlowSlice.camelCase}Success);
        Navigator.pop(context, 'refresh');
      },
    );
  }

  @override
  Widget build(BuildContext context) {    
    return buildPage(
      providers: [
        BlocProvider<${logicFlow.className}>(create: (_) => sl<${logicFlow.className}>()),
      ],
      listeners: [
        BlocListener<${logicFlow.className}, ${featureLogicFlowSlice.pascalCase}State>(
          listener: _${featureLogicFlowSlice.camelCase}Listener,
        ),
      ],
      builder: (context) {
        ${ComposeHelperTemplate.buildMutationWrapper(param).trim()}
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    return AppSubmitFilledButton(
      text: ${param.moduleCamel}L10n.${featureLogicFlowSlice.camelCase}Action,
      onPressed: () => _${logicFlow.method}(context),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return BlocBuilder<${logicFlow.className}, ${featureLogicFlowSlice.pascalCase}State>(
      builder: (_, state) => state.maybeWhen(
        orElse: () => const SizedBox.shrink(),
        loading: () => const AppLoadingOverlay(),
      ),
    );
  }

  ${ComposeHelperTemplate.methodWrapper(param).trim()}
}
''';
  }
}
