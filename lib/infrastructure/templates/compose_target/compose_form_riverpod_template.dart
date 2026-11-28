import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/logic_metadata_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../core/extensions/prop_list_x.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposeFormRiverpodTemplate {
  static String content({
    required ComposeParam param,
    required LogicMetadata logicFlow,
    required LogicMetadata logic,
    String? initialDataType,
    List<PropModel> initialProps = const [],
  }) {
    final featureLogicFlowSlice = [
      param.featureName,
      param.logicFlowSlice,
    ].join('_');
    final featureLogicSlice = [param.featureName, param.logicSlice].join('_');
    final featureUiSlice = [param.featureName, param.uiSlice].join('_');

    final fieldDeclarations = initialProps
        .map((p) => '  final ${p.type} ${p.name.camelCase};')
        .join('\n');
    final constructorParams = initialProps
        .map((p) {
          final fieldName = p.name.camelCase;
          final isNullable = p.type.endsWith('?');
          return isNullable ? 'this.$fieldName,' : 'required this.$fieldName,';
        })
        .join('\n    ');

    final resolvedInitialType = initialDataType;
    final initialDataArg = resolvedInitialType != null
        ? () {
            final args = initialProps.buildNamedArgs(accessorPrefix: 'widget.');
            return args.isEmpty
                ? '$resolvedInitialType(),'
                : '$resolvedInitialType(\n        $args\n      )';
          }()
        : null;

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
    () => sl<${logicFlow.className}>(),
  );

  late final _${logic.objectName} =
      AutoDisposeNotifierProvider<${logic.className}, ${featureLogicSlice.pascalCase}State>(
    () => sl<${logic.className}>(),
  );

  void _submit(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.moduleName.pascalCase}Localizations.of(context)!;

    final formState = ref.read(_${logic.objectName});
    if (formState.invalidMessage != null) {
      context.showErrorSnackbar(formState.invalidMessage!);
      return;
    }

    final formStateParam = formState.param;
    if (formStateParam == null) {
      context.showErrorSnackbar(${param.moduleCamel}L10n.${featureUiSlice.camelCase}InvalidEmpty);
      return;
    }

    ref.read(_${logicFlow.objectName}.notifier).${logicFlow.method}(formStateParam);
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
  void initState() {
    super.initState();
    ref.listenManual(_${logic.objectName}, (_, _) {});
  }

  @override
  Widget build(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    ref.listen(
      _${logicFlow.objectName},
      (previous, next) => _${featureLogicFlowSlice.camelCase}Listener(context, previous, next),
    );
    ${ComposeHelperTemplate.buildFormWrapper(param).trim()}
  }

  Widget _buildContent(BuildContext context) {
    return ${featureUiSlice.pascalCase}(
      ${initialDataArg != null ? 'initialData: $initialDataArg,' : ''}
      onListen: (context, param, invalidMessage) {
        ref.read(_${logic.objectName}.notifier).updateState(
          param: param,
          invalidMessage: invalidMessage,
        );
      },
    );
  }

  Widget _buildSubmit(BuildContext context) {
    final l10n = ${param.moduleName.pascalCase}Localizations.of(context)!;
    return Consumer(
      builder: (_, ref, _) {
        final state = ref.watch(_${logicFlow.objectName});
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
