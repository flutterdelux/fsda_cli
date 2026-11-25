import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/logic_metadata_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposePaginationRiverpodTemplate {
  static String content({
    required ComposeParam param,
    required LogicMetadata logicFlow,
    List<PropModel> externalProps = const [],
  }) {
    final featureLogicFlowSlice = [
      param.featureName,
      param.logicFlowSlice,
    ].join('_');
    final featureUiSlice = [param.featureName, param.uiSlice].join('_');

    return '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:${param.moduleName}/${param.moduleName}.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/failure_x.dart';

class ${param.targetPascal} extends ConsumerStatefulWidget {
  const ${param.targetPascal}({super.key});

  @override
  ConsumerState<${param.targetPascal}> createState() => _${param.targetPascal}State();

  ${ComposeHelperTemplate.methodWrapper(param).trim()}
}

class _${param.targetPascal}State extends ConsumerState<${param.targetPascal}> {
  late final _${logicFlow.objectName} =
      NotifierProvider.autoDispose<${logicFlow.className}, ${featureLogicFlowSlice.pascalCase}State>(
    () => sl<${logicFlow.className}>(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(_${logicFlow.objectName}.notifier).init();
    });
  }

  Future<void> _refresh() {
    return ref.read(_${logicFlow.objectName}.notifier).refresh();
  }

  void _loadMore() {
    ref.read(_${logicFlow.objectName}.notifier).loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    ${ComposeHelperTemplate.buildWrapper(param).trim()}
  }

  Widget _buildContent(BuildContext context) {
    return Consumer(
      builder: (_, ref, _) {
        final state = ref.watch(_${logicFlow.objectName});
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
            onRetry: _refresh,
          );
        }

        if (isEmpty) {
          return ${featureUiSlice.pascalCase}EmptyFeedback(onRefresh: _refresh);
        }

        return ${featureUiSlice.pascalCase}Content(
          data: data,
          isLoadingMore: state.isLoading,
          onLoadMore: _loadMore,
          onPullRefresh: _refresh,
          onItemTap: (item) {
          
          },
        );
      },
    );
  }
}
''';
  }
}
