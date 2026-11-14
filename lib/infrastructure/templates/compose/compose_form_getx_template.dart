import '../../../core/extensions/app_integration_param_x.dart';
import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/logic_metadata_x.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/params/app_integration/compose_form_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposeFormGetXTemplate {
  static String content({
    required ComposeFormParam param,
    required LogicMetadata logicFlow,
    required LogicMetadata logic,
  }) {
    final featureLogicFlowSlice = [
      param.featureName!,
      param.logicFlowSlice,
    ].join('_');
    final featureUiSlice = [param.featureName!, param.uiSlice].join('_');

    return '''
import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:${param.moduleName}/${param.moduleName}.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/failure_x.dart';

class ${param.targetPascal} extends StatefulWidget {
  const ${param.targetPascal}({super.key});

  @override
  State<${param.targetPascal}> createState() => _${param.targetPascal}State();

  ${ComposeHelperTemplate.methodWrapper(param).trim()}
}

class _${param.targetPascal}State extends State<${param.targetPascal}> {
  late final ${logicFlow.className} _${logicFlow.objectName};
  late final ${logic.className} _${logic.objectName};
  late final StreamSubscription _${logicFlow.objectName}Subscription;

  void _submit(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.moduleName.pascalCase}Localizations.of(context)!;

    final formState = _${logic.objectName}.state;
    if (formState.invalidMessage != null) {
      context.showErrorSnackbar(formState.invalidMessage!);
      return;
    }

    final formStateParam = formState.param;
    if (formStateParam == null) {
      context.showErrorSnackbar(${param.moduleCamel}L10n.${featureUiSlice.camelCase}InvalidEmpty);
      return;
    }

    _${logicFlow.objectName}.${logicFlow.method}(formStateParam);
  }

  void _${featureLogicFlowSlice.camelCase}Listener(${featureLogicFlowSlice.pascalCase}State state) {
    if (!mounted) return;
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
  void initState() {
    super.initState();
    _${logicFlow.objectName} = Get.put(sl<${logicFlow.className}>());
    _${logic.objectName} = Get.put(sl<${logic.className}>());
    _${logicFlow.objectName}Subscription = _${logicFlow.objectName}.rxState.listen(_${featureLogicFlowSlice.camelCase}Listener);
  }

  @override
  void dispose() {
    _${logicFlow.objectName}Subscription.cancel();
    Get.delete<${logicFlow.className}>();
    Get.delete<${logic.className}>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    ${ComposeHelperTemplate.buildFormWrapper(param).trim()}
  }

  Widget _buildContent(BuildContext context) {
    return ${featureUiSlice.pascalCase}(
      onListen: (context, param, invalidMessage) {
        _${logic.objectName}.updateState(
          param: param,
          invalidMessage: invalidMessage,
        );
      },
    );
  }

  Widget _buildSubmit(BuildContext context) {
    final l10n = ${param.moduleName.pascalCase}Localizations.of(context)!;
    return Obx(
      () {
        final state = _${logicFlow.objectName}.state;
        final isLoading = state.maybeWhen(
          orElse: () => false,
          loading: () => true,
        );
        return AppSubmitFilledButton(
          text: l10n.${featureLogicFlowSlice.camelCase}Action,
          isLoading: isLoading,
          onPressed: () => _submit(context),
        );
      },
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Obx(
      () => _${logicFlow.objectName}.state.maybeWhen(
        orElse: () => const SizedBox.shrink(),
        loading: () => const AppLoadingOverlay(),
      ),
    );
  }
}
''';
  }
}
