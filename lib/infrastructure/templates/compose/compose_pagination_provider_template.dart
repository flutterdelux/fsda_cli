import '../../../core/extensions/app_integration_param_x.dart';
import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/params/app_integration/compose_pagination_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposePaginationProviderTemplate {
  static String content({
    required ComposePaginationParam param,
    required LogicMetadata logicFlow,
  }) {
    final featureUiSlice = [param.featureName!, param.uiSlice].join('_');
    return '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:${param.moduleName}/${param.moduleName}.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/failure_x.dart';
import '../../../../../core/mixins/page_provider_mixin.dart';

class ${param.targetPascal} extends StatelessWidget with PageProviderMixin {
  const ${param.targetPascal}({super.key});

  Future<void> _refresh(BuildContext context) {
    return context.read<${logicFlow.className}>().refresh();
  }

  void _loadMore(BuildContext context) {
    context.read<${logicFlow.className}>().loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    return buildPage(
      providers: [
        ChangeNotifierProvider<${logicFlow.className}>(
          create: (_) => sl<${logicFlow.className}>()..init(),
        ),
      ],
      builder: (context) {
        ${ComposeHelperTemplate.buildWrapper(param).trim()}
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<${logicFlow.className}>(
      builder: (_, provider, _) {
        final state = provider.state;
        final isLoading = state.isLoading;
        final data = state.data;
        final isEmpty = data.isEmpty;
        final failure = state.failure;

        if (isEmpty && isLoading) {
          return const ${featureUiSlice.pascalCase}Skeleton();
        }

        if (isEmpty && failure != null) {
          return ${featureUiSlice.pascalCase}ErrorFeedback(
            message: failure.localizeAny(context),
            onRetry: () => _refresh(context),
          );
        }

        if (isEmpty) {
          return ${featureUiSlice.pascalCase}EmptyFeedback(onRefresh: () => _refresh(context));
        }

        return ${featureUiSlice.pascalCase}Content(
          data: data,
          isLoadingMore: state.isLoading,
          onLoadMore: () => _loadMore(context),
          onPullRefresh: () => _refresh(context),
          onItemTap: (item) {
          
          },
        );
      },
    );
  }

  ${ComposeHelperTemplate.methodWrapper(param).trim()}
}
''';
  }
}
