import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/logic_metadata_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../core/extensions/prop_list_x.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposeMutationRiverpodTemplate {
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
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:${param.moduleName}/${param.moduleName}.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/failure_x.dart';

class ${param.targetPascal} extends ConsumerStatefulWidget {
  ${fieldDeclarations.isNotEmpty ? '${fieldDeclarations.trim()}\n' : ''}
  const ${param.targetPascal}({
    super.key,
    ${constructorParams.trim()}
  });

  @override
  ConsumerState<${param.targetPascal}> createState() => _${param.targetPascal}State();

  ${ComposeHelperTemplate.methodWrapper(param).trim()}
}

class _${param.targetPascal}State extends ConsumerState<${param.targetPascal}> {
  late final _${logicFlow.objectName} =
      AutoDisposeNotifierProvider<${logicFlow.className}, ${featureLogicFlowSlice.pascalCase}State>(
    () => $slCall,
  );

  void _${logicFlow.method}() {
    ref.read(_${logicFlow.objectName}.notifier).${logicFlow.method}($methodArg);
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
    ref.listen(
      _${logicFlow.objectName},
      (previous, next) => _${featureLogicFlowSlice.camelCase}Listener(context, previous, next),
    );
    ${ComposeHelperTemplate.buildMutationWrapper(param).trim()}
  }

  Widget _buildContent(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    return AppSubmitFilledButton(
      text: ${param.moduleCamel}L10n.${featureLogicFlowSlice.camelCase}Action,
      onPressed: _${logicFlow.method},
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
}
''';
  }
}
