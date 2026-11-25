import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/logic_metadata_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../core/extensions/prop_list_x.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposeFormProviderTemplate {
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
            final args = initialProps.buildNamedArgs(accessorPrefix: 'widget.');
            return args.isEmpty
                ? '$resolvedInitialType(),'
                : '$resolvedInitialType(\n        $args\n      )';
          }()
        : null;

    return '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:${param.moduleName}/${param.moduleName}.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/failure_x.dart';
import '../../../../../core/mixins/page_provider_mixin.dart';

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

class _${param.targetPascal}State extends State<${param.targetPascal}>
    with PageProviderMixin {
  late final ${logicFlow.className} _${logicFlow.objectName};
  late final ${logic.className} _${logic.objectName};

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

  void _${featureLogicFlowSlice.camelCase}Listener() {
    if (!mounted) return;
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;

    _${logicFlow.objectName}.state.maybeWhen(
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
    _${logicFlow.objectName} = sl<${logicFlow.className}>();
    _${logic.objectName} = sl<${logic.className}>();
    _${logicFlow.objectName}.addListener(_${featureLogicFlowSlice.camelCase}Listener);
  }

  @override
  void dispose() {
    _${logicFlow.objectName}.removeListener(_${featureLogicFlowSlice.camelCase}Listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    return buildPage(
      providers: [
        ChangeNotifierProvider<${logicFlow.className}>.value(
          value: _${logicFlow.objectName},
        ),
        ChangeNotifierProvider<${logic.className}>.value(
          value: _${logic.objectName},
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
        _${logic.objectName}.updateState(
          param: param,
          invalidMessage: invalidMessage,
        );
      },
    );
  }

  Widget _buildSubmit(BuildContext context) {
    final l10n = ${param.moduleName.pascalCase}Localizations.of(context)!;
    return Consumer<${logicFlow.className}>(
      builder: (_, provider, _) {
        final isLoading = provider.state.maybeWhen(
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
    return Consumer<${logicFlow.className}>(
      builder: (_, provider, _) => provider.state.maybeWhen(
        orElse: () => const SizedBox.shrink(),
        loading: () => const AppLoadingOverlay(),
      ),
    );
  }
}
''';
  }
}
