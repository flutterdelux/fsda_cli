import '../../../core/extensions/app_integration_param_x.dart';
import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/logic_metadata_x.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/params/app_integration/compose_mutation_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposeMutationRiverpodTemplate {
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:${param.moduleName}/${param.moduleName}.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/failure_x.dart';

class ${param.targetPascal} extends StatelessWidget {
  const ${param.targetPascal}({super.key});

  static final _${logicFlow.objectName} = NotifierProvider<${logicFlow.className}, ${featureLogicFlowSlice.pascalCase}State>(
    () => sl<${logicFlow.className}>(),
  );

  void _${logicFlow.method}(WidgetRef ref) {
    ref.read(_${logicFlow.objectName}.notifier).${logicFlow.method}();
  }

  void _${featureLogicFlowSlice.camelCase}Listener(BuildContext context, ${featureLogicFlowSlice.pascalCase}State? previous, ${featureLogicFlowSlice.pascalCase}State next) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    
    next.maybeWhen(
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
    ${ComposeHelperTemplate.buildMutationWrapper(param).trim()}
  }

  Widget _buildContent(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    return Consumer(
      builder: (context, ref, _) {
        ref.listen(
          _${logicFlow.objectName},
          (previous, next) => _${featureLogicFlowSlice.camelCase}Listener(context, previous, next),
        );

        return AppSubmitFilledButton(
          text: ${param.moduleCamel}L10n.${featureLogicFlowSlice.camelCase}Action,
          onPressed: () => _${logicFlow.method}(ref),
        );
      },
    );    
  }

  Widget _buildOverlay(BuildContext context) {
    return Consumer(
      builder: (_, ref, _) {
        final state = ref.watch(_${logicFlow.objectName});
        return state.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          loading: () => const AppLoadingOverlay(),
        );
      },
    );
  }

  ${ComposeHelperTemplate.methodWrapper(param).trim()}
}
''';
  }
}
