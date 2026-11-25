import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/default_value.dart';
import '../../../core/extensions/feature_param_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../core/extensions/slice_param_x.dart';
import '../../../core/extensions/ui_gate_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/ui_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'ui_compose_field_template.dart';

abstract final class UiFormTemplate {
  static ArtifactGenerationModel build({
    required UiParam ui,
    required List<PropModel> props,
  }) {
    final className = '${ui.featurePascal}${ui.slicePascal}';
    final hasInitial = ui.hasInitial;
    final fields = ui.fields!;

    final composeFieldImports = fields
        .map(
          (e) =>
              "import '../../shared/widgets/${ui.featureName}_${e.fieldName}_field.dart';",
        )
        .join('\n');

    final initialDataProp = hasInitial
        ? 'final ${ui.modelPascal} initialData;'
        : '';
    final composeFieldProps = fields
        .map((e) => UiComposeFieldTemplate.prop(e))
        .join('\n');

    final initialDataParam = hasInitial ? 'required this.initialData,' : '';
    final composeFieldParams = fields
        .map((e) => UiComposeFieldTemplate.param(e))
        .join('\n');

    final composeFieldVariables = fields
        .map((e) => UiComposeFieldTemplate.variable(e))
        .join('\n');

    final composeFieldValidations = fields
        .map(
          (e) => UiComposeFieldTemplate.validation(
            formField: e,
            feature: ui.featureName,
            hasInitial: ui.hasInitial,
          ),
        )
        .join('\n');

    final initializeDataListen = props
        .map((prop) {
          final propName = prop.name.camelCase;
          if (propName == 'id' && hasInitial) {
            return '      id: widget.initialData.id,';
          }
          final value =
              fields
                  .firstWhereOrNull((field) => field.fieldName == prop.name)
                  ?.fieldName ??
              prop.defaultValue;
          return '      $propName: ${value.isNotEmpty ? value : DefaultValue.fromType(prop.type)},';
        })
        .join('\n');

    final composeFieldInitStates = fields
        .map(
          (e) => UiComposeFieldTemplate.initState(
            formField: e,
            hasInitial: ui.hasInitial,
          ),
        )
        .join();
    final composeFieldDisposes = fields
        .map((e) => UiComposeFieldTemplate.dispose(e))
        .join();

    final composeFieldWidgets = fields
        .map(
          (e) => UiComposeFieldTemplate.widget(
            formField: e,
            feature: ui.featureName,
          ),
        )
        .join('        AppGap.lg,\n');

    final earlyListen = hasInitial
        ? '''
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onInputChanged();
    });
'''
        : '';

    return ArtifactGenerationModel(
      name: className,
      path: p.join(
        ui.featurePath,
        'ui',
        ui.sliceSnake,
        'widgets',
        '${ui.featureSnake}_${ui.sliceSnake}.dart',
      ),
      typesToImport: {
        ui.modelPascal,
        ...fields.map((e) => e.valueType.replaceAll('?', '')),
        '${ui.modulePascal}Localizations',
      },
      needToExport: true,
      content:
          '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

$composeFieldImports

class $className extends StatefulWidget {
  final void Function(
    BuildContext context,
    ${ui.modelPascal}? data,
    String? invalidMessage,
  )
  onListen;
  ${initialDataProp.trim()}
  ${composeFieldProps.trim()}
  
  const $className({
    super.key,
    required this.onListen,
    ${initialDataParam.trim()}
    ${composeFieldParams.trim()}
  });

  @override
  State<$className> createState() => _${className}State();
}

class _${className}State extends State<$className> {
$composeFieldVariables

  void _onInputChanged() {
    final l10n = ${ui.moduleName.pascalCase}Localizations.of(context)!;

    ${composeFieldValidations.trim()}

    final data = ${ui.modelPascal}(
$initializeDataListen
    );
    widget.onListen(context, data, null);
  }

  @override
  void initState() {
    super.initState();
    ${composeFieldInitStates.trim()}
    ${earlyListen.trim()}
  }

  @override
  void dispose() {
    ${composeFieldDisposes.trim()}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            ${composeFieldWidgets.trim()}
          ],
        ),
      ),
    );
  }
}
''',
    );
  }

  static Map<String, dynamic> buildArbEntries(UiParam ui) {
    final entries = <String, dynamic>{};
    final prefixKey = '${ui.featureCamel}${ui.slicePascal}';
    final message =
        '${ui.featureName.sentenceCase} ${ui.sliceName.sentenceCase} must be filled';
    entries['${prefixKey}Title'] = [
      ui.featureTitle,
      ui.sliceTitle.replaceAll('Form', '').trim(),
    ].join(' ');
    entries['${prefixKey}InvalidEmpty'] = message;
    return entries;
  }
}
