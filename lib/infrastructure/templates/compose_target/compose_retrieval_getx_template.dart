import 'package:collection/collection.dart';

import '../../../core/constants/default_value.dart';
import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/logic_metadata_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../core/extensions/prop_list_x.dart';
import '../../../domain/models/dependency_metadata.dart';
import '../../../domain/models/logic_metadata.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'compose_helper_template.dart';

abstract final class ComposeRetrievalGetXTemplate {
  static String content({
    required ComposeParam param,
    required LogicMetadata logicFlow,
    required List<DependencyMetadata> uiMetadatas,
    required List<PropModel> constructorProps,
    required List<PropModel> methodProps,
  }) {
    final featureUiSlice = [param.featureName, param.uiSlice].join('_');

    final skeletonMetadata = uiMetadatas.firstWhereOrNull(
      (e) => e.className.endsWith('Skeleton'),
    );
    final skeletonParams = skeletonMetadata?.parameters ?? [];
    final skeletonParam = skeletonParams.isEmpty
        ? '()'
        : '''(
          ${skeletonParams.map((e) => e.isNamed ? '${e.name}: ${e.defaultValue ?? DefaultValue.fromType(e.type)}' : e.defaultValue ?? DefaultValue.fromType(e.type)).join(',\n          ')}
        )''';

    final contentMetadata = uiMetadatas.firstWhereOrNull(
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

  ${ComposeHelperTemplate.methodWrapper(param)}
}

class _${param.targetPascal}State extends State<${param.targetPascal}> {
  late final ${logicFlow.className} _${logicFlow.objectName};

  void _${logicFlow.method}() {
    _${logicFlow.objectName}.${logicFlow.method}($methodArg);
  }

  @override
  void initState() {
    super.initState();    
    _${logicFlow.objectName} = Get.put($slCall);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _${logicFlow.method}();
    });
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
      () => _${logicFlow.objectName}.state.maybeWhen(
        orElse: () => const ${featureUiSlice.pascalCase}Skeleton$skeletonParam,
        loading: () => const ${featureUiSlice.pascalCase}Skeleton(),
        failure: (failure) => ${featureUiSlice.pascalCase}ErrorFeedback(
          message: failure.localizeAny(context),
          onRetry: _${logicFlow.method},
        ),
        loaded: (data) => ${featureUiSlice.pascalCase}Content$contentParam,
      ),
    );
  }
}
''';
  }
}
