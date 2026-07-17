import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../services/logger_service.dart';
import 'compose_types.dart';

class ComposePagService {
  final LoggerService logger;

  const ComposePagService({required this.logger});

  Future<void> generate(ComposeArgs args) async {
    final root = Directory.current.path;
    final moduleFeaturePath = p.join(
      root,
      'modules',
      args.module,
      'lib',
      'src',
      'features',
      args.feature,
    );

    final logicDirPath = p.join(moduleFeaturePath, 'logic', args.slice);
    final uiSlicePath = p.join(moduleFeaturePath, 'ui', args.slice);

    final appLibPath = p.join(root, 'apps', args.app, 'lib');
    final appModulePath = p.join(appLibPath, 'modules', args.module);
    final routeFilePath = p.join(appModulePath, '${args.module}_route.dart');

    final logicTargets = await _collectLogicTargets(logicDirPath);
    if (logicTargets.isEmpty) {
      logger.error(
        'No logic class found at modules/${args.module}/lib/src/features/${args.feature}/logic/${args.slice}.',
      );
      exitCode = 1;
      return;
    }

    final primaryLogic = logicTargets.first;
    final stateShape = await _resolveStateShape(primaryLogic.statePath);

    final viewInfo = await _resolveViewInfo(uiSlicePath);
    if (viewInfo == null) {
      logger.error(
        'Slice "${args.slice}" in feature "${args.feature}" does not have a view. compose-pag requires a view scaffold.',
      );
      exitCode = 1;
      return;
    }

    final uiComponents = await _resolveUiComponents(uiSlicePath);
    if (uiComponents.content == null) {
      logger.error(
        'Pagination content widget was not found in modules/${args.module}/lib/src/features/${args.feature}/ui/${args.slice}/widgets.',
      );
      exitCode = 1;
      return;
    }

    final pageClass = args.targetPage.pascalCase;
    final pageFileName = '${args.targetPage.snakeCase}.dart';
    final pageDir = p.join(appModulePath, 'features', args.feature, 'pages');
    final pagePath = p.join(pageDir, pageFileName);

    final listItemType = _resolveListItemType(
      contentClass: uiComponents.content!,
      stateShape: stateShape,
    );

    final itemDisplayExpression = await _resolveItemDisplayExpression(
      moduleFeaturePath: moduleFeaturePath,
      entityType: listItemType,
    );

    final pageCode = _buildPageCode(
      appLibPath: appLibPath,
      module: args.module,
      feature: args.feature,
      pageClass: pageClass,
      pageDir: pageDir,
      viewInfo: viewInfo,
      logic: primaryLogic,
      stateShape: stateShape,
      uiComponents: uiComponents,
      itemType: listItemType,
      itemDisplayExpression: itemDisplayExpression,
    );

    final pageFile = File(pagePath);
    await pageFile.create(recursive: true);
    await pageFile.writeAsString(
      '${_normalizeBlankLines(pageCode).trimRight()}\n',
    );

    final routeFile = File(routeFilePath);
    if (!await routeFile.exists()) {
      logger.error('Module route file not found at: $routeFilePath');
      exitCode = 1;
      return;
    }

    await _syncRouteFile(
      routeFile: routeFile,
      pagePath: pagePath,
      pageClass: pageClass,
      targetPage: args.targetPage,
      updateBaseBuilder: true,
    );

    logger.success(
      'compose-pag generated for slice "${args.slice}" in feature "${args.feature}" (module: "${args.module}", app: "${args.app}").',
    );
    logger.info(
      'Generated page: apps/${args.app}/lib/modules/${args.module}/features/${args.feature}/pages/$pageFileName',
    );
    logger.info(
      'Updated base route + child route: apps/${args.app}/lib/modules/${args.module}/${args.module}_route.dart',
    );
  }

  Future<List<_LogicTarget>> _collectLogicTargets(String logicDirPath) async {
    final logicDir = Directory(logicDirPath);
    if (!await logicDir.exists()) return const <_LogicTarget>[];

    final files = <File>[];
    await for (final entity in logicDir.list(recursive: true)) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('.freezed.dart')) continue;
      files.add(entity);
    }

    final targets = <_LogicTarget>[];
    for (final file in files) {
      final source = await file.readAsString();
      final classMatch = RegExp(
        r'class\s+([A-Za-z_]\w*)\s+extends\s+(?:Cubit|Bloc)<\s*([A-Za-z_]\w*)',
      ).firstMatch(source);
      if (classMatch == null) continue;

      final logicClass = classMatch.group(1)!;
      final stateClass = classMatch.group(2)!;

      final methods = _extractInvokableMethods(source);
      final bootstrapMethod = _selectBootstrapMethod(methods);
      final refreshMethod = _selectRefreshMethod(methods);
      final loadMoreMethod = _selectLoadMoreMethod(methods);

      final stateImportMatch = RegExp(
        r"import\s+'([^']+_state\.dart)';",
      ).firstMatch(source);
      final statePath = stateImportMatch == null
          ? null
          : p.normalize(
              p.join(p.dirname(file.path), stateImportMatch.group(1)!),
            );

      targets.add(
        _LogicTarget(
          logicClass: logicClass,
          stateClass: stateClass,
          statePath: statePath,
          bootstrapMethod: bootstrapMethod,
          refreshMethod: refreshMethod,
          refreshReturnsFuture: _methodReturnsFuture(methods, refreshMethod),
          loadMoreMethod: loadMoreMethod,
        ),
      );
    }

    targets.sort((a, b) => a.logicClass.compareTo(b.logicClass));
    return targets;
  }

  List<_MethodCandidate> _extractInvokableMethods(String source) {
    final methodRegex = RegExp(
      r'(Future<[^>]+>|Future<void>|void)\s+([A-Za-z_]\w*)\s*\(([^)]*)\)\s*(?:async\s*)?\{',
      multiLine: true,
    );

    final methods = <_MethodCandidate>[];
    for (final match in methodRegex.allMatches(source)) {
      final returnType = (match.group(1) ?? '').trim();
      final name = match.group(2)!;
      final params = match.group(3) ?? '';
      if (name.startsWith('_')) continue;
      if (name == 'close') continue;

      methods.add(
        _MethodCandidate(
          name: name,
          returnType: returnType,
          canInvokeWithoutArgs: _canInvokeWithoutArgs(params),
        ),
      );
    }

    return methods;
  }

  bool _canInvokeWithoutArgs(String params) {
    final trimmed = params.trim();
    if (trimmed.isEmpty) return true;

    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return !RegExp(r'\brequired\b').hasMatch(trimmed);
    }

    return false;
  }

  String? _selectBootstrapMethod(List<_MethodCandidate> methods) {
    final zeroArgMethods = methods
        .where((method) => method.canInvokeWithoutArgs)
        .toList();
    if (zeroArgMethods.isEmpty) return null;

    const preferred = <String>['init'];
    for (final methodName in preferred) {
      final found = zeroArgMethods.firstWhere(
        (method) => method.name == methodName,
        orElse: () => const _MethodCandidate.none(),
      );
      if (found.isValid) return found.name;
    }

    return null;
  }

  String? _selectRefreshMethod(List<_MethodCandidate> methods) {
    final zeroArgMethods = methods
        .where((method) => method.canInvokeWithoutArgs)
        .toList();
    if (zeroArgMethods.isEmpty) return null;

    const preferredExact = <String>['refresh', 'init'];
    for (final methodName in preferredExact) {
      final found = zeroArgMethods.firstWhere(
        (method) => method.name == methodName,
        orElse: () => const _MethodCandidate.none(),
      );
      if (found.isValid) return found.name;
    }

    const preferredPrefixes = <String>['get', 'load', 'fetch', 'watch'];
    for (final prefix in preferredPrefixes) {
      final found = zeroArgMethods.firstWhere(
        (method) => method.name.startsWith(prefix),
        orElse: () => const _MethodCandidate.none(),
      );
      if (found.isValid) return found.name;
    }

    return zeroArgMethods.first.name;
  }

  bool _methodReturnsFuture(
    List<_MethodCandidate> methods,
    String? methodName,
  ) {
    if (methodName == null) return false;
    final target = methods.firstWhere(
      (method) => method.name == methodName,
      orElse: () => const _MethodCandidate.none(),
    );
    if (!target.isValid) return false;
    return target.returnType.startsWith('Future');
  }

  String? _selectLoadMoreMethod(List<_MethodCandidate> methods) {
    final zeroArgMethods = methods
        .where((method) => method.canInvokeWithoutArgs)
        .toList();
    if (zeroArgMethods.isEmpty) return null;

    const preferredExact = <String>['loadMore', 'fetchMore'];
    for (final methodName in preferredExact) {
      final found = zeroArgMethods.firstWhere(
        (method) => method.name == methodName,
        orElse: () => const _MethodCandidate.none(),
      );
      if (found.isValid) return found.name;
    }

    final byContains = zeroArgMethods.firstWhere(
      (method) => method.name.toLowerCase().contains('more'),
      orElse: () => const _MethodCandidate.none(),
    );
    if (byContains.isValid) return byContains.name;

    return null;
  }

  Future<_StateShape> _resolveStateShape(String? statePath) async {
    if (statePath == null) {
      return const _StateShape();
    }

    final stateFile = File(statePath);
    if (!await stateFile.exists()) {
      return const _StateShape();
    }

    final source = await stateFile.readAsString();
    final fields = <String, String>{};

    final fieldRegex = RegExp(
      r'(?:@Default\([^\)]*\)\s*)?([A-Za-z0-9_<>,? ]+)\s+([A-Za-z_]\w*)\s*,',
      multiLine: true,
    );

    for (final match in fieldRegex.allMatches(source)) {
      final type = match.group(1)?.trim();
      final name = match.group(2)?.trim();
      if (type == null || name == null || type.isEmpty || name.isEmpty) {
        continue;
      }
      fields[name] = type;
    }

    final listField = fields.entries
        .firstWhere(
          (entry) => entry.value.replaceAll(' ', '').startsWith('List<'),
          orElse: () => const MapEntry('', ''),
        )
        .key;

    final failureField = fields.entries
        .firstWhere(
          (entry) => entry.value.contains('Failure'),
          orElse: () => const MapEntry('', ''),
        )
        .key;

    final isLoadingField = fields.containsKey('isLoading')
        ? 'isLoading'
        : fields.entries
              .firstWhere(
                (entry) =>
                    entry.value.replaceAll(' ', '') == 'bool' &&
                    entry.key.toLowerCase().contains('loading'),
                orElse: () => const MapEntry('', ''),
              )
              .key;

    final isLoadingMoreField = fields.containsKey('isLoadingMore')
        ? 'isLoadingMore'
        : (isLoadingField.isEmpty ? '' : isLoadingField);

    return _StateShape(
      fields: fields,
      listField: listField,
      failureField: failureField,
      isLoadingField: isLoadingField,
      isLoadingMoreField: isLoadingMoreField,
    );
  }

  Future<_ClassInfo?> _resolveViewInfo(String uiSlicePath) async {
    final viewsDir = Directory(p.join(uiSlicePath, 'views'));
    if (!await viewsDir.exists()) return null;

    final viewFiles = <File>[];
    await for (final entity in viewsDir.list(recursive: false)) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;
      viewFiles.add(entity);
    }

    if (viewFiles.isEmpty) return null;

    viewFiles.sort((a, b) => a.path.compareTo(b.path));
    return _parseClassInfo(await viewFiles.first.readAsString());
  }

  Future<_UiComponents> _resolveUiComponents(String uiSlicePath) async {
    final widgetsDir = Directory(p.join(uiSlicePath, 'widgets'));
    if (!await widgetsDir.exists()) {
      return const _UiComponents();
    }

    final files = <File>[];
    await for (final entity in widgetsDir.list(recursive: true)) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;
      files.add(entity);
    }

    _ClassInfo? content;
    _ClassInfo? error;
    _ClassInfo? empty;
    _ClassInfo? skeleton;

    for (final file in files) {
      final path = file.path;
      final source = await file.readAsString();
      final classInfo = _parseClassInfo(source);
      if (classInfo == null) continue;

      if (path.endsWith('_content.dart') && content == null) {
        content = classInfo;
      } else if (path.endsWith('_error_feedback.dart') && error == null) {
        error = classInfo;
      } else if (path.endsWith('_empty_feedback.dart') && empty == null) {
        empty = classInfo;
      } else if (path.endsWith('_skeleton.dart') &&
          skeleton == null &&
          !path.contains('parts')) {
        skeleton = classInfo;
      }
    }

    return _UiComponents(
      content: content,
      errorFeedback: error,
      emptyFeedback: empty,
      skeleton: skeleton,
    );
  }

  _ClassInfo? _parseClassInfo(String source) {
    final classMatch = RegExp(
      r'class\s+([A-Za-z_]\w*)\s+extends\s+[A-Za-z_]\w*',
    ).firstMatch(source);
    if (classMatch == null) return null;

    final className = classMatch.group(1)!;

    final fieldTypes = <String, String>{};
    final fieldRegex = RegExp(r'final\s+([^;=]+?)\s+([A-Za-z_]\w*)\s*;');
    for (final match in fieldRegex.allMatches(source)) {
      final type = match.group(1)?.trim();
      final name = match.group(2)?.trim();
      if (type == null || type.isEmpty || name == null || name.isEmpty) {
        continue;
      }
      fieldTypes[name] = type;
    }

    final ctorMatch = RegExp(
      r'const\s+' + RegExp.escape(className) + r'\s*\(([^;]*?)\);',
      dotAll: true,
    ).firstMatch(source);

    final requiredFields = <String>[];
    if (ctorMatch != null) {
      final ctorSource = ctorMatch.group(1) ?? '';
      final requiredRegex = RegExp(r'required\s+this\.([A-Za-z_]\w*)');
      for (final req in requiredRegex.allMatches(ctorSource)) {
        final name = req.group(1);
        if (name != null && name.isNotEmpty) {
          requiredFields.add(name);
        }
      }
    }

    return _ClassInfo(
      className: className,
      requiredFields: requiredFields,
      fieldTypes: fieldTypes,
    );
  }

  String _resolveListItemType({
    required _ClassInfo contentClass,
    required _StateShape stateShape,
  }) {
    final listType = contentClass.fieldTypes['list'];
    if (listType != null) {
      final itemType = _extractListItemType(listType);
      if (itemType != null && itemType.isNotEmpty) {
        return itemType.replaceAll('?', '').trim();
      }
    }

    final stateListType = stateShape.fields[stateShape.listField];
    if (stateListType != null) {
      final itemType = _extractListItemType(stateListType);
      if (itemType != null && itemType.isNotEmpty) {
        return itemType.replaceAll('?', '').trim();
      }
    }

    return 'dynamic';
  }

  String? _extractListItemType(String value) {
    final normalized = value.replaceAll(' ', '');
    final match = RegExp(r'^List<(.+)>\??$').firstMatch(normalized);
    return match?.group(1);
  }

  Future<String> _resolveItemDisplayExpression({
    required String moduleFeaturePath,
    required String entityType,
  }) async {
    if (entityType == 'dynamic') {
      return 'item';
    }

    final entityPath = p.join(
      moduleFeaturePath,
      'domain',
      'entities',
      '${entityType.snakeCase}.dart',
    );

    final entityFile = File(entityPath);
    if (!await entityFile.exists()) {
      return 'item';
    }

    final source = await entityFile.readAsString();
    const preferredFields = <String>['title', 'name', 'label', 'id'];

    for (final field in preferredFields) {
      final hasField = RegExp(
        r'\b(?:final|required\s+[A-Za-z0-9_<>,? ]+)\s+' +
            RegExp.escape(field) +
            r'\b',
      ).hasMatch(source);
      if (hasField) {
        return 'item.$field';
      }
    }

    return 'item';
  }

  String _buildPageCode({
    required String appLibPath,
    required String module,
    required String feature,
    required String pageClass,
    required String pageDir,
    required _ClassInfo viewInfo,
    required _LogicTarget logic,
    required _StateShape stateShape,
    required _UiComponents uiComponents,
    required String itemType,
    required String itemDisplayExpression,
  }) {
    final itemDisplayInterpolation = "${r'${'}$itemDisplayExpression}";
    final refreshMethod = logic.refreshMethod ?? logic.bootstrapMethod;
    final loadMoreMethod = logic.loadMoreMethod;

    if (refreshMethod == null) {
      logger.error(
        'Unable to infer refresh method for ${logic.logicClass}. compose-pag requires at least one zero-arg public method.',
      );
      exitCode = 1;
    }

    final listField = stateShape.listField.isEmpty
        ? 'list'
        : stateShape.listField;
    final failureField = stateShape.failureField.isEmpty
        ? null
        : stateShape.failureField;
    final isLoadingField = stateShape.isLoadingField.isEmpty
        ? 'isLoading'
        : stateShape.isLoadingField;
    final isLoadingMoreField = stateShape.isLoadingMoreField.isEmpty
        ? isLoadingField
        : stateShape.isLoadingMoreField;

    final refreshMethodName = '_refresh${feature.pascalCase}s';
    final loadMoreMethodName = '_loadMore${feature.pascalCase}s';
    final onItemTapMethodName = '_on${feature.pascalCase}ItemTap';

    final refreshMethodCode = _buildRefreshMethod(
      logicClass: logic.logicClass,
      methodName: refreshMethodName,
      logicMethodName: refreshMethod ?? 'init',
      returnsFuture: logic.refreshReturnsFuture,
    );

    final loadMoreMethodCode = _buildLoadMoreMethod(
      logicClass: logic.logicClass,
      methodName: loadMoreMethodName,
      logicMethodName: loadMoreMethod,
    );

    final onItemTapMethodCode =
        '''
  void $onItemTapMethodName(BuildContext context, $itemType item) {
    context.showSuccessSnackbar('${feature.pascalCase} tapped: $itemDisplayInterpolation');
  }
''';

    final skeletonExpr = uiComponents.skeleton == null
        ? 'const SizedBox.shrink()'
        : 'const ${uiComponents.skeleton!.className}()';

    final errorExpr = uiComponents.errorFeedback == null
        ? 'AppErrorFeedback(title: \'Error\', message: failure.localizeAny(context), onRetry: () => $refreshMethodName(context))'
        : '${uiComponents.errorFeedback!.className}(message: failure.localizeAny(context), onRetry: () => $refreshMethodName(context))';

    final emptyExpr = uiComponents.emptyFeedback == null
        ? 'const SizedBox.shrink()'
        : '${uiComponents.emptyFeedback!.className}(onRefresh: () => $refreshMethodName(context))';

    final contentExpr = _buildContentInstantiation(
      contentClass: uiComponents.content!,
      listField: listField,
      isLoadingMoreField: isLoadingMoreField,
      refreshMethodName: refreshMethodName,
      loadMoreMethodName: loadMoreMethodName,
      onItemTapMethodName: onItemTapMethodName,
    );

    final viewReturn = _buildViewReturn(
      viewInfo: viewInfo,
      contentExpression: '_buildContent(context)',
    );

    final providerCascade = logic.bootstrapMethod == null
        ? ''
        : '..${logic.bootstrapMethod!}()';

    final classBody =
        '''
class $pageClass extends StatelessWidget with PageProviderMixin {
  const $pageClass({super.key});

$refreshMethodCode
$loadMoreMethodCode
$onItemTapMethodCode
  Widget _buildContent(BuildContext context) {
    return BlocBuilder<${logic.logicClass}, ${logic.stateClass}>(
      builder: (_, state) {
        final isLoading = state.$isLoadingField;
        final list = state.$listField;
        final isEmpty = list.isEmpty;
        final failure = ${failureField == null ? 'null' : 'state.$failureField'};

        if (isEmpty && isLoading) {
          return $skeletonExpr;
        }

        if (isEmpty && failure != null) {
          return $errorExpr;
        }

        if (isEmpty) {
          return $emptyExpr;
        }

        return $contentExpr;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildPage(
      providers: [BlocProvider<${logic.logicClass}>(create: (_) => sl()$providerCascade)],
      listeners: [],
      builder: (context) {
        $viewReturn
      },
    );
  }
}
''';

    final diImport = p
        .relative(p.join(appLibPath, 'core', 'di', 'di.dart'), from: pageDir)
        .replaceAll('\\', '/');
    final mixinImport = p
        .relative(
          p.join(appLibPath, 'core', 'mixins', 'page_provider_mixin.dart'),
          from: pageDir,
        )
        .replaceAll('\\', '/');
    final failureImport = p
        .relative(
          p.join(appLibPath, 'core', 'extensions', 'failure_x.dart'),
          from: pageDir,
        )
        .replaceAll('\\', '/');

    final imports = <String>[
      "import 'package:app_ui/app_ui.dart';",
      "import 'package:flutter/material.dart';",
      "import 'package:flutter_bloc/flutter_bloc.dart';",
      "import 'package:$module/$module.dart';",
      '',
      "import '$diImport';",
      "import '$failureImport';",
      "import '$mixinImport';",
    ];

    return '''${imports.join('\n')}

$classBody''';
  }

  String _buildRefreshMethod({
    required String logicClass,
    required String methodName,
    required String logicMethodName,
    required bool returnsFuture,
  }) {
    if (returnsFuture) {
      return '''
  Future<void> $methodName(BuildContext context) {
    return context.read<$logicClass>().$logicMethodName();
  }
''';
    }

    return '''
  Future<void> $methodName(BuildContext context) async {
    context.read<$logicClass>().$logicMethodName();
  }
''';
  }

  String _buildLoadMoreMethod({
    required String logicClass,
    required String methodName,
    required String? logicMethodName,
  }) {
    if (logicMethodName == null) {
      return '''
  void $methodName(BuildContext context) {}
''';
    }

    return '''
  void $methodName(BuildContext context) {
    context.read<$logicClass>().$logicMethodName();
  }
''';
  }

  String _buildContentInstantiation({
    required _ClassInfo contentClass,
    required String listField,
    required String isLoadingMoreField,
    required String refreshMethodName,
    required String loadMoreMethodName,
    required String onItemTapMethodName,
  }) {
    final args = contentClass.requiredFields
        .map((field) {
          final type = contentClass.fieldTypes[field];

          if (field == 'list') {
            return 'list: list,';
          }
          if (field == 'onPullRefresh') {
            return 'onPullRefresh: () => $refreshMethodName(context),';
          }
          if (field == 'onItemTap') {
            return 'onItemTap: (item) { $onItemTapMethodName(context, item); },';
          }
          if (field == 'isLoadingMore') {
            return 'isLoadingMore: state.$isLoadingMoreField,';
          }
          if (field == 'onLoadMore') {
            return 'onLoadMore: () => $loadMoreMethodName(context),';
          }
          if (_isCallbackField(type: type, field: field)) {
            return '$field: () {},';
          }
          if (_looksLikeListField(field)) {
            return '$field: list,';
          }

          return '$field: ${_defaultValueForType(type)},';
        })
        .join('\n          ');

    return '''${contentClass.className}(
          $args
        )''';
  }

  bool _looksLikeListField(String field) {
    const names = <String>{'data', 'list', 'items', 'item', 'notes'};
    return names.contains(field);
  }

  String _buildViewReturn({
    required _ClassInfo viewInfo,
    required String contentExpression,
  }) {
    if (viewInfo.requiredFields.isEmpty) {
      return 'return ${viewInfo.className}();';
    }

    final args = viewInfo.requiredFields
        .map((field) {
          final type = viewInfo.fieldTypes[field];

          if (field == 'content' || field == 'form') {
            return '$field: $contentExpression,';
          }

          if (_isCallbackField(type: type, field: field)) {
            return '$field: () {},';
          }

          return '$field: ${_defaultValueForType(type)},';
        })
        .join('\n          ');

    return '''return ${viewInfo.className}(
          $args
        );''';
  }

  bool _isCallbackField({required String? type, required String field}) {
    if (field.startsWith('on')) return true;
    if (type == null) return false;
    return type.contains('VoidCallback') || type.contains('Function(');
  }

  String _defaultValueForType(String? type) {
    final normalized = (type ?? '').replaceAll(' ', '');
    if (normalized == 'String') return "''";
    if (normalized == 'int') return '0';
    if (normalized == 'double') return '0';
    if (normalized == 'bool') return 'false';
    if (normalized.startsWith('List<')) return 'const []';
    if (normalized.contains('Widget')) return 'const SizedBox.shrink()';
    if (normalized.contains('VoidCallback')) return '() {}';
    if (normalized.contains('Function(')) return '(_) {}';
    return 'const SizedBox.shrink()';
  }

  Future<void> _syncRouteFile({
    required File routeFile,
    required String pagePath,
    required String pageClass,
    required String targetPage,
    required bool updateBaseBuilder,
  }) async {
    var source = await routeFile.readAsString();

    final routeDir = p.dirname(routeFile.path);
    final relativePageImport = p
        .relative(pagePath, from: routeDir)
        .replaceAll('\\', '/');
    final pageImportLine = "import '$relativePageImport';";

    source = _insertImport(source, pageImportLine);

    final routeBaseSnake = _stripPageSuffixFromSnake(targetPage.snakeCase);
    final routeBasePascal = _stripPageSuffixFromPascal(pageClass);

    final routePath = routeBaseSnake;
    final routeName = routeBaseSnake.replaceAll('_', '-');

    final constUpsert = _upsertPrivateRouteNameConst(
      source: source,
      routeConstBaseName: routeBaseSnake,
      routeName: routeName,
    );
    source = constUpsert.source;
    final routeNameConst = constUpsert.routeNameConst;

    if (updateBaseBuilder) {
      source = _syncBaseBuilder(source: source);
    }

    source = _upsertChildRoute(
      source: source,
      routePath: routePath,
      routeNameConst: routeNameConst,
      pageClass: pageClass,
    );

    source = _upsertNavigationMethod(
      source: source,
      methodName: 'to$routeBasePascal',
      routeNameConst: routeNameConst,
    );

    if (!source.contains('NotFoundPage')) {
      source = source.replaceAll(
        "import '../../core/pages/not_found_page.dart';\n",
        '',
      );
    }

    await routeFile.writeAsString(
      '${_normalizeBlankLines(source).trimRight()}\n',
    );
  }

  String _syncBaseBuilder({required String source}) {
    final builderRegex = RegExp(
      r'builder:\s*\(context,\s*state\)\s*=>\s*const\s+[A-Za-z_]\w*\s*\(\s*\)\s*,',
    );

    final constUpdated = source.replaceFirst(
      builderRegex,
      'builder: (context, state) => const NotFoundPage(),',
    );
    if (constUpdated != source) return constUpdated;

    final nonConstBuilderRegex = RegExp(
      r'builder:\s*\(context,\s*state\)\s*=>\s*[A-Za-z_]\w*\s*\(\s*\)\s*,',
    );

    return source.replaceFirst(
      nonConstBuilderRegex,
      'builder: (context, state) => const NotFoundPage(),',
    );
  }

  ({String source, String routeNameConst}) _upsertPrivateRouteNameConst({
    required String source,
    required String routeConstBaseName,
    required String routeName,
  }) {
    final existingByValue = RegExp(
      "static const\\s+(\\_[A-Za-z_]\\w*)\\s*=\\s*'${RegExp.escape(routeName)}'\\s*;",
    ).firstMatch(source);

    if (existingByValue != null) {
      return (source: source, routeNameConst: existingByValue.group(1)!);
    }

    final usedConstNames = RegExp(
      r'static const\s+(\_[A-Za-z_]\w*)\s*=\s*',
    ).allMatches(source).map((match) => match.group(1)!).toSet();

    final preferred = '_${routeConstBaseName.camelCase}';
    var routeNameConst = preferred;
    if (usedConstNames.contains(routeNameConst)) {
      final fallbackBase = preferred;
      routeNameConst = fallbackBase;
      var suffix = 2;
      while (usedConstNames.contains(routeNameConst)) {
        routeNameConst = '$fallbackBase$suffix';
        suffix++;
      }
    }

    final constLine = "  static const $routeNameConst = '$routeName';";
    if (source.contains(constLine)) {
      return (source: source, routeNameConst: routeNameConst);
    }

    final baseGetterMatch = RegExp(
      r'^\s*static RouteBase get base =>',
      multiLine: true,
    ).firstMatch(source);

    if (baseGetterMatch != null) {
      source = source.replaceRange(
        baseGetterMatch.start,
        baseGetterMatch.start,
        '$constLine\n',
      );
    } else {
      final classOpenBrace = source.indexOf('{');
      if (classOpenBrace == -1) {
        source = '${source.trimRight()}\n$constLine\n';
      } else {
        source = source.replaceRange(
          classOpenBrace + 1,
          classOpenBrace + 1,
          '\n$constLine',
        );
      }
    }

    return (source: source, routeNameConst: routeNameConst);
  }

  String _stripPageSuffixFromSnake(String value) {
    if (value.endsWith('_page')) {
      final trimmed = value.substring(0, value.length - '_page'.length);
      if (trimmed.isNotEmpty) return trimmed;
    }
    return value;
  }

  String _stripPageSuffixFromPascal(String value) {
    if (value.endsWith('Page') && value.length > 'Page'.length) {
      return value.substring(0, value.length - 'Page'.length);
    }
    return value;
  }

  String _upsertChildRoute({
    required String source,
    required String routePath,
    required String routeNameConst,
    required String pageClass,
  }) {
    if (source.contains('name: $routeNameConst')) return source;

    final pattern = RegExp(r'(routes\s*:\s*\[)([\s\S]*?)(\],)');
    final match = pattern.firstMatch(source);
    if (match == null) return source;

    final content = match.group(2)!;
    final itemIndent = _resolveFirstNonEmptyIndent(
      source: content,
      fallback: '      ',
    );
    final closingIndentMatch = RegExp(r'\n([ \t]*)$').firstMatch(content);
    final closingIndent = closingIndentMatch?.group(1) ?? '    ';

    final entry = [
      'GoRoute(',
      "  path: '$routePath',",
      '  name: $routeNameConst,',
      '  builder: (context, state) => const $pageClass(),',
      '),',
    ].map((line) => '$itemIndent$line').join('\n');

    final baseContent = content.trimRight();
    final newContent = baseContent.trim().isEmpty
        ? '\n$entry\n$closingIndent'
        : '$baseContent\n$entry\n$closingIndent';

    final contentStart = match.start + match.group(1)!.length;
    final contentEnd = contentStart + content.length;

    return source.replaceRange(contentStart, contentEnd, newContent);
  }

  String _upsertNavigationMethod({
    required String source,
    required String methodName,
    required String routeNameConst,
  }) {
    if (source.contains('$methodName(')) return source;

    final methodBlock =
        '  static Future<dynamic> $methodName(BuildContext context) {\n'
        '    return context.pushNamed($routeNameConst);\n'
        '  }';

    final classCloseIndex = source.lastIndexOf('}');
    if (classCloseIndex == -1) return source;

    final head = source.substring(0, classCloseIndex).trimRight();
    final tail = source.substring(classCloseIndex);

    return '$head\n\n$methodBlock\n$tail';
  }

  String _insertImport(String source, String importLine) {
    if (source.contains(importLine)) return source;

    final lines = source.split('\n');
    final lastImportIndex = lines.lastIndexWhere(
      (line) => line.startsWith('import '),
    );

    final insertIndex = lastImportIndex == -1 ? 0 : lastImportIndex + 1;
    lines.insert(insertIndex, importLine);

    return lines.join('\n');
  }

  String _resolveFirstNonEmptyIndent({
    required String source,
    required String fallback,
  }) {
    for (final line in source.split('\n')) {
      if (line.trim().isEmpty) continue;
      return RegExp(r'^\s*').stringMatch(line) ?? fallback;
    }
    return fallback;
  }

  String _normalizeBlankLines(String source) {
    final sanitized = source.replaceAll(RegExp(r'[ \t]+\n'), '\n');
    return sanitized.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }
}

class _LogicTarget {
  final String logicClass;
  final String stateClass;
  final String? statePath;
  final String? bootstrapMethod;
  final String? refreshMethod;
  final bool refreshReturnsFuture;
  final String? loadMoreMethod;

  const _LogicTarget({
    required this.logicClass,
    required this.stateClass,
    required this.statePath,
    required this.bootstrapMethod,
    required this.refreshMethod,
    required this.refreshReturnsFuture,
    required this.loadMoreMethod,
  });
}

class _MethodCandidate {
  final String name;
  final String returnType;
  final bool canInvokeWithoutArgs;
  final bool isValid;

  const _MethodCandidate({
    required this.name,
    required this.returnType,
    required this.canInvokeWithoutArgs,
  }) : isValid = true;

  const _MethodCandidate.none()
    : name = '',
      returnType = '',
      canInvokeWithoutArgs = false,
      isValid = false;
}

class _ClassInfo {
  final String className;
  final List<String> requiredFields;
  final Map<String, String> fieldTypes;

  const _ClassInfo({
    required this.className,
    required this.requiredFields,
    required this.fieldTypes,
  });
}

class _UiComponents {
  final _ClassInfo? content;
  final _ClassInfo? errorFeedback;
  final _ClassInfo? emptyFeedback;
  final _ClassInfo? skeleton;

  const _UiComponents({
    this.content,
    this.errorFeedback,
    this.emptyFeedback,
    this.skeleton,
  });
}

class _StateShape {
  final Map<String, String> fields;
  final String listField;
  final String failureField;
  final String isLoadingField;
  final String isLoadingMoreField;

  const _StateShape({
    this.fields = const <String, String>{},
    this.listField = '',
    this.failureField = '',
    this.isLoadingField = '',
    this.isLoadingMoreField = '',
  });
}
