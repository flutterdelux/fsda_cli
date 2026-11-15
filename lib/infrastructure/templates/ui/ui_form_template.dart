import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../../../core/constants/default_value.dart';
import '../../../core/extensions/feature_gate_param_x.dart';
import '../../../core/extensions/module_gate_param_x.dart';
import '../../../core/extensions/slice_gate_param_x.dart';
import '../../../core/extensions/ui_gate_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/ui/ui_form_param.dart';
import '../../text_modifiers/string_extension.dart';
import 'ui_compose_field_template.dart';

abstract final class UiFormTemplate {
  static ArtifactGenerationModel build({
    required UiFormParam ui,
    required List<PropModel> props,
  }) {
    final className = '${ui.featurePascal}${ui.slicePascal}';
    final hasInitial = ui.hasInitial;

    final composeFieldImports = ui.fields
        .map(
          (e) =>
              "import '../../shared/widgets/${ui.featureName}_${e.fieldName}_field.dart';",
        )
        .join('\n');

    final initialDataProp = hasInitial
        ? 'final ${ui.modelPascal} initialData;'
        : '';
    final composeFieldProps = ui.fields
        .map((e) => UiComposeFieldTemplate.prop(e))
        .join('\n');

    final initialDataParam = hasInitial ? 'required this.initialData,' : '';
    final composeFieldParams = ui.fields
        .map((e) => UiComposeFieldTemplate.param(e))
        .join('\n');

    final composeFieldVariables = ui.fields
        .map((e) => UiComposeFieldTemplate.variable(e))
        .join('\n');

    final composeFieldValidations = ui.fields
        .map(
          (e) => UiComposeFieldTemplate.validation(
            formField: e,
            feature: ui.featureName,
            hasInitial: ui.hasInitial,
          ),
        )
        .join('\n');

    // final initializeDataListen = [
    //   if (hasInitial) '      id: widget.initialData.id,',
    //   ...ui.fields.map((e) {
    //     final fieldCamel = e.fieldName.camelCase;
    //     return '      $fieldCamel: $fieldCamel,';
    //   }),
    // ].join('\n');
    final initializeDataListen = props
        .map((prop) {
          final propName = prop.name.camelCase;
          final value =
              ui.fields
                  .firstWhereOrNull((field) => field.fieldName == prop.name)
                  ?.fieldName ??
              prop.defaultValue;
          return '      $propName: ${value.isNotEmpty ? value : DefaultValue.fromType(prop.type)},';
        })
        .join('\n');

    final composeFieldInitStates = ui.fields
        .map(
          (e) => UiComposeFieldTemplate.initState(
            formField: e,
            hasInitial: ui.hasInitial,
          ),
        )
        .join();
    final composeFieldDisposes = ui.fields
        .map((e) => UiComposeFieldTemplate.dispose(e))
        .join();

    final composeFieldWidgets = ui.fields
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
        ...ui.fields.map((e) => e.valueType.replaceAll('?', '')),
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
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        ${composeFieldWidgets.trim()}
      ],
    );
  }
}
''',
    );
  }

  static Map<String, dynamic> buildArbEntries(UiFormParam ui) {
    final entries = <String, dynamic>{};
    final prefixKey = '${ui.featureCamel}${ui.slicePascal}';
    final message =
        '${ui.featureName.sentenceCase} ${ui.slice.sentenceCase} must be filled';
    entries['${prefixKey}Title'] = [
      ui.featureTitle,
      ui.sliceTitle.replaceAll('Form', '').trim(),
    ].join(' ');
    entries['${prefixKey}InvalidEmpty'] = message;
    return entries;
  }
}
