import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/logic_metadata_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../core/extensions/prop_list_x.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposeMutationGetXTemplate {
  static String content({
    required ComposeParam param,
    required LogicMetadata logicFlow,
    required List<PropModel> constructorProps,
    required List<PropModel> methodProps,
  }) {
    final featureLogicFlowSlice = [
      param.featureName,
      param.logicFlowSlice,
    ].join('_');

    final uniqueProps = [
      ...constructorProps,
      ...methodProps,
    ].deduplicateProps();
    final fieldDeclarations = uniqueProps
        .map((p) => '  final ${p.type} ${p.name.camelCase};')
        .join('\n');
    final constructorParams = uniqueProps
        .map((p) {
          final fieldName = p.name.camelCase;
          final isNullable = p.type.endsWith('?');
          return isNullable ? 'this.$fieldName,' : 'required this.$fieldName,';
        })
        .join('\n    ');
    final slCall = logicFlow.buildSlCall(
      extProps: constructorProps,
      accessorPrefix: 'widget.',
    );
    final methodArg = logicFlow.buildMethodParamArg(
      extProps: methodProps,
      accessorPrefix: 'widget.',
    );

    return '''
import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:${param.moduleName}/${param.moduleName}.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/failure_x.dart';

class ${param.targetPascal} extends StatefulWidget {
  ${fieldDeclarations.isNotEmpty ? '${fieldDeclarations.trim()}\n' : ''}
  const ${param.targetPascal}({
    super.key,
    ${constructorParams.trim()}
  });

  @override
  State<${param.targetPascal}> createState() => _${param.targetPascal}State();

  ${ComposeHelperTemplate.methodWrapper(param).trim()}
}

class _${param.targetPascal}State extends State<${param.targetPascal}> {
  late final ${logicFlow.className} _${logicFlow.objectName};
  late final StreamSubscription _${logicFlow.objectName}Subscription;

  void _${logicFlow.method}(BuildContext context) {
    _${logicFlow.objectName}.${logicFlow.method}($methodArg);
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
    _${logicFlow.objectName} = Get.put($slCall);
    _${logicFlow.objectName}Subscription = _${logicFlow.objectName}.rxState.listen(_${featureLogicFlowSlice.camelCase}Listener);
  }

  @override
  void dispose() {
    _${logicFlow.objectName}Subscription.cancel();
    Get.delete<${logicFlow.className}>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ${ComposeHelperTemplate.buildMutationWrapper(param).trim()}
  }

  Widget _buildContent(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    return AppSubmitFilledButton(
      text: ${param.moduleCamel}L10n.${featureLogicFlowSlice.camelCase}Action,
      onPressed: () => _${logicFlow.method}(context),
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
