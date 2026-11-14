import 'package:collection/collection.dart';

import '../../../core/constants/default_value.dart';
import '../../../core/extensions/app_integration_param_x.dart';
import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/models/dependency_metadata.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/params/app_integration/compose_retrieval_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposeRetrievalCubitTemplate {
  static String content({
    required ComposeRetrievalParam param,
    required LogicMetadata logicFlow,
    required List<DependencyMetadata> metadatas,
  }) {
    final featureLogicFlowSlice = [
      param.featureName!,
      param.logicFlowSlice,
    ].join('_');
    final featureUiSlice = [param.featureName!, param.uiSlice].join('_');

    final skeletonMetadata = metadatas.firstWhereOrNull(
      (e) => e.className.endsWith('Skeleton'),
    );
    final skeletonParams = skeletonMetadata?.parameters ?? [];
    final skeletonParam = skeletonParams.isEmpty
        ? '()'
        : '''(
          ${skeletonParams.map((e) => e.isNamed ? '${e.name}: ${e.defaultValue ?? DefaultValue.fromType(e.type)}' : e.defaultValue ?? DefaultValue.fromType(e.type)).join(',\n          ')}
        )''';

    final contentMetadata = metadatas.firstWhereOrNull(
      (e) => e.className.endsWith('Content'),
    );
    final contentParams = contentMetadata?.parameters ?? [];
    final contentParam = contentParams.isEmpty
        ? '()'
        : '''(
          ${contentParams.map((e) {
            if (e.name == 'data') return 'data: data,';
            if ((e.type.contains('Function') || e.name.contains('Tap') || e.name.contains('Callback')) && e.type.contains('item')) {
              return '${e.name}: (item) {},';
            }
            return '${e.name}: ${e.defaultValue ?? DefaultValue.fromType(e.type)}';
          }).join('\n          ')}
        )''';

    return '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:${param.moduleName}/${param.moduleName}.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/failure_x.dart';
import '../../../../../core/mixins/page_bloc_mixin.dart';

class ${param.targetPascal} extends StatelessWidget with PageBlocMixin {
  const ${param.targetPascal}({super.key});

  void _${logicFlow.method}(BuildContext context) {
    context.read<${logicFlow.className}>().${logicFlow.method}();
  }


  @override
  Widget build(BuildContext context) {
    final ${param.moduleCamel}L10n = ${param.modulePascal}Localizations.of(context)!;
    return buildPage(
      providers: [
        BlocProvider<${logicFlow.className}>(
          create: (_) => sl<${logicFlow.className}>()..${logicFlow.method}(),
        ),        
      ],
      listeners: [],
      builder: (context) {
        ${ComposeHelperTemplate.buildWrapper(param).trim()}
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<${logicFlow.className}, ${featureLogicFlowSlice.pascalCase}State>(
      builder: (_, state) => state.maybeWhen(
        orElse: () => const ${featureUiSlice.pascalCase}Skeleton$skeletonParam,
        failure: (failure) => ${featureUiSlice.pascalCase}ErrorFeedback(
          message: failure.localizeAny(context),
          onRetry: () => _${logicFlow.method}(context),
        ),
        loaded: (data) => ${featureUiSlice.pascalCase}Content$contentParam,
      ),
    );
  }

${ComposeHelperTemplate.methodWrapper(param)}
}
''';
  }
}
