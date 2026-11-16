import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../../../core/extensions/feature_gate_param_x.dart';
import '../../../core/extensions/module_gate_param_x.dart';
import '../../../core/extensions/slice_gate_param_x.dart';
import '../../../core/extensions/ui_gate_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/ui/ui_lsh_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class UiLshTemplate {
  static ArtifactGenerationModel buildItem({
    required UiLshParam ui,
    required List<PropModel> props,
  }) {
    final className = '${ui.featurePascal}${ui.slicePascal}Item';
    final (backgroundProp, titleProp, subtitleProp) = _getMatchProps(props);
    final background = backgroundProp != null
        ? '''
            AppNetworkImage(
              url: item.${backgroundProp.name.camelCase},
              fit: BoxFit.cover,
              borderRadius: borderRadius,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: $className.borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
'''
        : 'ColoredBox(color: Colors.blue.shade100),';
    final title = titleProp != null
        ? 'item.${titleProp.name.camelCase}'
        : "'item.title'";
    final subtitle = subtitleProp != null
        ? 'item.${subtitleProp.name.camelCase}'
        : "'item.subtitle'";
    return ArtifactGenerationModel(
      name: className,
      path: p.join(
        ui.featurePath,
        'ui',
        ui.sliceSnake,
        'widgets',
        'parts',
        '${ui.featureSnake}_${ui.sliceSnake}_item.dart',
      ),
      typesToImport: {ui.modelPascal},
      needToExport: false,
      content:
          '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class $className extends StatelessWidget {
  static const aspectRatio = 10 / 16;
  static const borderRadius = BorderRadius.all(Radius.circular(16));

  final ${ui.modelPascal} item;
  final VoidCallback onTap;

  const $className({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.antiAlias,
          fit: StackFit.expand,
          alignment: Alignment.bottomLeft,
          children: [
            ${background.trim()}
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    $title,
                    maxLines: 1,
                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  AppGap.xs,
                  Text(
                    $subtitle,
                    maxLines: 1,
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
''',
    );
  }

  static ArtifactGenerationModel buildItemSkeleton(UiLshParam ui) {
    final className = '${ui.featurePascal}${ui.slicePascal}ItemSkeleton';
    final itemClassName = '${ui.featurePascal}${ui.slicePascal}Item';
    return ArtifactGenerationModel(
      name: className,
      path: p.join(
        ui.featurePath,
        'ui',
        ui.sliceSnake,
        'widgets',
        'parts',
        '${ui.featureSnake}_${ui.sliceSnake}_item_skeleton.dart',
      ),
      typesToImport: {},
      needToExport: false,
      content:
          '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '${itemClassName.snakeCase}.dart';


class $className extends StatelessWidget {
  const $className({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: $itemClassName.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: const Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppShimmer(width: 120, height: 18, radius: 4),
                  SizedBox(height: 6),
                  AppShimmer(width: 85, height: 10, radius: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
''',
    );
  }

  static ArtifactGenerationModel buildContent(UiLshParam ui) {
    final className = '${ui.featurePascal}${ui.slicePascal}Content';
    final itemClassName = '${ui.featurePascal}${ui.slicePascal}Item';
    return ArtifactGenerationModel(
      name: className,
      path: p.join(
        ui.featurePath,
        'ui',
        ui.sliceSnake,
        'widgets',
        '${ui.featureSnake}_${ui.sliceSnake}_content.dart',
      ),
      typesToImport: {ui.modelPascal},
      needToExport: true,
      content:
          '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'parts/${ui.featureSnake}_${ui.sliceSnake}_item.dart';

class $className extends StatelessWidget {
  static const height = 280.0;

  final List<${ui.modelPascal}> data;
  final void Function(${ui.modelPascal} item) onItemTap;

  const $className({
    super.key,
    required this.data,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        separatorBuilder: (context, index) => AppGap.md,
        itemBuilder: (context, index) {
          final item = data[index];
          return $itemClassName(
            item: item,
            onTap: () => onItemTap(item),
          );
        },
      ),
    );
  }
}
''',
    );
  }

  static ArtifactGenerationModel buildSkeleton(UiLshParam ui) {
    final className = '${ui.featurePascal}${ui.slicePascal}Skeleton';
    final contentClassName = '${ui.featurePascal}${ui.slicePascal}Content';
    final itemSkeletonClassName =
        '${ui.featurePascal}${ui.slicePascal}ItemSkeleton';
    return ArtifactGenerationModel(
      name: className,
      path: p.join(
        ui.featurePath,
        'ui',
        ui.sliceSnake,
        'widgets',
        '${ui.featureSnake}_${ui.sliceSnake}_skeleton.dart',
      ),
      typesToImport: {},
      needToExport: true,
      content:
          '''
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '${contentClassName.snakeCase}.dart';
import 'parts/${ui.featureSnake}_${ui.sliceSnake}_item_skeleton.dart';

class $className extends StatelessWidget {
  final int itemCount;

  const $className({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: $contentClassName.height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (context, index) => AppGap.md,
        itemBuilder: (context, index) {
          return const $itemSkeletonClassName();
        },
      ),
    );
  }
}
''',
    );
  }

  static ArtifactGenerationModel buildErrorFeedback(UiLshParam ui) {
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
      typesToImport: {'${ui.modulePascal}Localizations'},
      needToExport: true,
      content:
          '''
import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class $className extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const $className({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    final l10n = ${ui.modulePascal}Localizations.of(context)!;
    return AppErrorFeedback(
      title: l10n.${ui.featureCamel}${ui.slicePascal}ErrorTitle,
      message: message,
      retryText: appL10n.refresh,
      onRetry: onRetry,
    );
  }
}
''',
    );
  }

  static ArtifactGenerationModel buildEmptyFeedback(UiLshParam ui) {
    final className = '${ui.featurePascal}${ui.slicePascal}EmptyFeedback';
    return ArtifactGenerationModel(
      name: className,
      path: p.join(
        ui.featurePath,
        'ui',
        ui.sliceSnake,
        'widgets',
        '${ui.featureSnake}_${ui.sliceSnake}_empty_feedback.dart',
      ),
      typesToImport: {'${ui.modulePascal}Localizations'},
      needToExport: true,
      content:
          '''
import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class $className extends StatelessWidget {
  final VoidCallback onRefresh;

  const $className({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;
    final l10n = ${ui.modulePascal}Localizations.of(context)!;
    return AppEmptyFeedback(
      title: l10n.${ui.featureCamel}${ui.slicePascal}EmptyTitle,
      message: l10n.${ui.featureCamel}${ui.slicePascal}EmptyMessage,
      onRefresh: onRefresh,
      refreshText: appL10n.refresh,
    );
  }
}
''',
    );
  }

  static Map<String, dynamic> buildArbEntries(UiLshParam ui) {
    final entries = <String, dynamic>{};

    final prefixKey = '${ui.featureCamel}${ui.slicePascal}';
    final title = '${ui.featureTitle} ${ui.sliceTitle}';
    entries['${prefixKey}Title'] = title;
    entries['${prefixKey}ErrorTitle'] = 'Failed to load $title';
    entries['${prefixKey}EmptyTitle'] = 'No $title Data Available';
    entries['${prefixKey}EmptyMessage'] =
        'There are currently no items to show.';

    return entries;
  }
}

(PropModel? leading, PropModel? title, PropModel? subtitle) _getMatchProps(
  List<PropModel> props,
) {
  final backgroundAlowed = ['image_url', 'image', 'url'];
  final backgroundProp = props.firstWhereOrNull(
    (prop) => _findMatchProp(prop: prop, allowed: backgroundAlowed),
  );

  final titleAlowed = ['title', 'label', 'name'];
  final titleProp = props.firstWhereOrNull(
    (prop) => _findMatchProp(prop: prop, allowed: titleAlowed),
  );

  final subtitleAlowed = [
    'subtitle',
    'description',
    'text',
    'message',
    'content',
    'body',
    'note',
  ];
  final subtitleProp = props.firstWhereOrNull(
    (prop) => _findMatchProp(prop: prop, allowed: subtitleAlowed),
  );

  return (backgroundProp, titleProp, subtitleProp);
}

bool _findMatchProp({required PropModel prop, required List<String> allowed}) {
  final allowedProp =
      allowed.any((t) => t == prop.name) ||
      allowed.any((t) => prop.name.endsWith(t));
  return prop.type == 'String' && allowedProp;
}
