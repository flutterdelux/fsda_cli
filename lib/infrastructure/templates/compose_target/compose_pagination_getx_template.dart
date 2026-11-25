import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/logic_metadata_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposePaginationGetXTemplate {
  static String content({
    required ComposeParam param,
    required LogicMetadata logicFlow,
  }) {
    final featureUiSlice = [param.featureName, param.uiSlice].join('_');

    return '''
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

  ${ComposeHelperTemplate.methodWrapper(param)}
}

class _${param.targetPascal}State extends State<${param.targetPascal}> {
  late final ${logicFlow.className} _${logicFlow.objectName};

  Future<void> _refresh() {
    return _${logicFlow.objectName}.refresh();
  }

  void _loadMore() {
    _${logicFlow.objectName}.loadMore();
  }

  @override
  void initState() {
    super.initState();
    _${logicFlow.objectName} = Get.put(sl<${logicFlow.className}>())..init();
  }

  @override
  void dispose() {
    Get.delete<${logicFlow.className}>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    ${ComposeHelperTemplate.buildWrapper(param).trim()}
  }

  Widget _buildContent(BuildContext context) {
    return Obx(
      () {
        final state = _${logicFlow.objectName}.state;
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
            onRetry: () => _refresh(),
          );
        }

        if (isEmpty) {
          return ${featureUiSlice.pascalCase}EmptyFeedback(onRefresh: () => _refresh());
        }

        return ${featureUiSlice.pascalCase}Content(
          data: data,
          isLoadingMore: state.isLoading,
          onLoadMore: () => _loadMore(),
          onPullRefresh: () => _refresh(),
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
