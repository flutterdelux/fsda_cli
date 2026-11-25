import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../core/extensions/prop_list_x.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposeFormCubitTemplate {
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
            final args = initialProps.buildNamedArgs();
            return args.isEmpty
                ? '$resolvedInitialType(),'
                : '$resolvedInitialType(\n        $args\n      )';
          }()
        : null;

    return '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:${param.moduleName}/${param.moduleName}.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/failure_x.dart';
import '../../../../../core/mixins/page_bloc_mixin.dart';

class ${param.targetPascal} extends StatelessWidget with PageBlocMixin {
  ${fieldDeclarations.isNotEmpty ? '${fieldDeclarations.trim()}\n' : ''}
  const ${param.targetPascal}({
    super.key,
    ${constructorParams.trim()}
  });

  void _submit(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.moduleName.pascalCase}Localizations.of(context)!;

    final formState = context.read<${logic.className}>().state;
    if (formState.invalidMessage != null) {
      context.showErrorSnackbar(formState.invalidMessage!);
      return;
    }

    final formStateParam = formState.param;
    if (formStateParam == null) {
      context.showErrorSnackbar(${param.moduleCamel}L10n.${featureUiSlice.camelCase}InvalidEmpty);
      return;
    }

    context.read<${logicFlow.className}>().${logicFlow.method}(formStateParam);
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
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    return buildPage(
      providers: [
        BlocProvider<${logicFlow.className}>(create: (_) => sl<${logicFlow.className}>()),
        BlocProvider<${logic.className}>(create: (_) => sl<${logic.className}>()),
      ],
      listeners: [
        BlocListener<${logicFlow.className}, ${featureLogicFlowSlice.pascalCase}State>(
          listener: _${featureLogicFlowSlice.camelCase}Listener,
        ),
      ],
      builder: (context) {
        ${ComposeHelperTemplate.buildFormWrapper(param).trim()}
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return ${featureUiSlice.pascalCase}(
      ${initialDataArg != null ? 'initialData: $initialDataArg,' : ''}
      onListen: (context, param, invalidMessage) {
        context.read<${logic.className}>().updateState(
          param: param,
          invalidMessage: invalidMessage
        );
      },
    );
  }

  Widget _buildSubmit(BuildContext context) {
    final l10n = ${param.moduleName.pascalCase}Localizations.of(context)!;
    return BlocBuilder<${logicFlow.className}, ${featureLogicFlowSlice.pascalCase}State>(
      builder: (_, state) {
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
