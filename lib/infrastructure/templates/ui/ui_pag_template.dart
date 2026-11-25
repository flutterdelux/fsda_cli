import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../../../core/extensions/feature_param_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../core/extensions/slice_param_x.dart';
import '../../../core/extensions/ui_gate_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/ui_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class UiPagTemplate {
  static ArtifactGenerationModel buildItem({
    required UiParam ui,
    required List<PropModel> props,
  }) {
    final className = '${ui.featurePascal}${ui.slicePascal}Item';
    final (leadingProp, titleProp, subtitleProp) = _getMatchProps(props);
    final leading = leadingProp != null
        ? '''
      AppNetworkImage(
        url: item.${leadingProp.name.camelCase},
        width: 60,
        height: 60,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      )
'''
        : 'AppLeadingIndex(number: index + 1)';
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
  final int index;
  final ${ui.modelPascal} item;
  final void Function() onTap;

  const $className({
    super.key,
    required this.index,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: $leading,
      title: $title,
      subtitle: $subtitle,
      includeChevron: true,
      onTap: onTap,      
    );
  }
}
''',
    );
  }

  static ArtifactGenerationModel buildItemSkeleton(UiParam ui) {
    final className = '${ui.featurePascal}${ui.slicePascal}ItemSkeleton';
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

class $className extends StatelessWidget {
  const $className({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppListTileSkeleton();
  }
}
''',
    );
  }

  static ArtifactGenerationModel buildContent(UiParam ui) {
    final className = '${ui.featurePascal}${ui.slicePascal}Content';
    final stateClassName = '${ui.featurePascal}${ui.slicePascal}ContentState';
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

class $className extends StatefulWidget {
  final Future<void> Function() onPullRefresh;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final List<${ui.modelPascal}> data;
  final void Function(${ui.modelPascal} item) onItemTap;

  const $className({
    super.key,
    required this.data,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onPullRefresh,
    required this.onItemTap,
  });

  @override
  State<$className> createState() => $stateClassName();
}

class $stateClassName extends State<$className> {
  static const _thresholdLoadMore = 0.9; // 90% of the scroll extent

  late final ScrollController _scrollController;

  void _onScroll() {
    if (_isReachThreshold) {
      widget.onLoadMore();
    }
  }

  bool get _isReachThreshold {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * _thresholdLoadMore) && maxScroll > 0;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: widget.onPullRefresh,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: widget.data.length,
        padding: const EdgeInsets.only(bottom: 80),
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final item = widget.data[index];
          final tile = $itemClassName(
            item: item,
            index: index,
            onTap: () => widget.onItemTap.call(item),
          );
          if (index == widget.data.length - 1) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [tile, if (widget.isLoadingMore) const AppLoading()],
            );
          }
          return tile;
        },
      ),
    );
  }
}
''',
    );
  }

  static ArtifactGenerationModel buildSkeleton(UiParam ui) {
    final className = '${ui.featurePascal}${ui.slicePascal}Skeleton';
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

import 'parts/${ui.featureSnake}_${ui.sliceSnake}_item_skeleton.dart';

class $className extends StatelessWidget {
  final int itemCount;

  const $className({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        AppSpacing.screen + padding.bottom,
      ),
      itemBuilder: (context, index) {
        return const $itemSkeletonClassName();
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: itemCount,
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

  static ArtifactGenerationModel buildEmptyFeedback(UiParam ui) {
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

  static Map<String, dynamic> buildArbEntries(UiParam ui) {
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
  final leadingAlowed = ['image_url', 'image', 'icon', 'url'];
  final leadingProp = props.firstWhereOrNull(
    (prop) => _findMatchProp(prop: prop, allowed: leadingAlowed),
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

  return (leadingProp, titleProp, subtitleProp);
}

bool _findMatchProp({required PropModel prop, required List<String> allowed}) {
  final allowedProp =
      allowed.any((t) => t == prop.name) ||
      allowed.any((t) => prop.name.endsWith(t));
  return prop.type == 'String' && allowedProp;
}
