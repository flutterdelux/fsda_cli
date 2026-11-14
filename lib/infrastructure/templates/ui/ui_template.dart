import 'package:path/path.dart' as p;

import '../../../core/extensions/feature_gate_param_x.dart';
import '../../../core/extensions/module_gate_param_x.dart';
import '../../../core/extensions/slice_gate_param_x.dart';
import '../../../core/extensions/ui_gate_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/ui/ui_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class UiTemplate {
  static ArtifactGenerationModel buildContent({
    required UiParam ui,
    required List<PropModel> props,
  }) {
    final className = '${ui.featurePascal}${ui.slicePascal}Content';
    final propContent = props
        .map((e) {
          return '''
            AppInfoTile(
              title: l10n.${ui.featureCamel}${ui.slicePascal}${e.name.pascalCase}, 
              data: data.${e.name.camelCase}.toString(),
            ),
''';
        })
        .join('\n');
    return ArtifactGenerationModel(
      name: className,
      path: p.join(
        ui.featurePath,
        'ui',
        ui.sliceSnake,
        'widgets',
        '${ui.featureSnake}_${ui.sliceSnake}_content.dart',
      ),
      typesToImport: {ui.modelPascal, '${ui.modulePascal}Localizations'},
      needToExport: true,
      content:
          '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class $className extends StatelessWidget {
  final ${ui.modelPascal} data;

  const $className({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = ${ui.modulePascal}Localizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          children: [
            ${propContent.trim()}
          ],
        ),
      ],
    );
  }
}
''',
    );
  }

  static ArtifactGenerationModel buildSkeleton({
    required UiParam ui,
    required List<PropModel> props,
  }) {
    final className = '${ui.featurePascal}${ui.slicePascal}Skeleton';
    final propSkeleton = props
        .map((e) {
          return '''
            AppInfoTile(
              title: l10n.${ui.featureCamel}${ui.slicePascal}${e.name.pascalCase}, 
              data: data.${e.name.camelCase}.toString(),
            ),
''';
        })
        .join('\n');
    return ArtifactGenerationModel(
      name: className,
      path: p.join(
        ui.featurePath,
        'ui',
        ui.sliceSnake,
        'widgets',
        '${ui.featureSnake}_${ui.sliceSnake}_skeleton.dart',
      ),
      typesToImport: {'${ui.modulePascal}Localizations'},
      needToExport: true,
      content:
          '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class $className extends StatelessWidget {
  const $className({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ${ui.modulePascal}Localizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          children: [
            ${propSkeleton.trim()}
          ],
        ),        
      ],
    );
  }
}
''',
    );
  }

  static ArtifactGenerationModel buildErrorFeedback(UiParam ui) {
    final className = '${ui.featurePascal}${ui.slicePascal}ErrorFeedback';
    return ArtifactGenerationModel(
      name: className,
      path: p.join(
        ui.featurePath,
        'ui',
        ui.sliceSnake,
        'widgets',
        '${ui.featureSnake}_${ui.sliceSnake}_error_feedback.dart',
      ),
      typesToImport: {'${ui.modulePascal}Localizations', 'AppLocalizations'},
      needToExport: true,
      content:
          '''
import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class $className extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const $className({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    final l10n = ${ui.modulePascal}Localizations.of(context)!;
    return AppErrorFeedback(
      title: l10n.${ui.featureCamel}${ui.slicePascal}ErrorTitle,
      message: message,
      onRetry: onRetry,
      retryText: appL10n.retry,
    );
  }
}
''',
    );
  }

  static Map<String, dynamic> buildArbEntries(UiParam ui) {
    final entries = <String, dynamic>{};

    final prefixKey = '${ui.featureCamel}${ui.slicePascal}';
    final title = '${ui.featureTitle} ${ui.sliceTitle}';
    entries['${prefixKey}Title'] = title;
    entries['${prefixKey}ErrorTitle'] = 'Failed to load $title';

    return entries;
  }
}
