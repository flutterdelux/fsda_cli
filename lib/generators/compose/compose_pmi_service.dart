import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../services/logger_service.dart';
import 'compose_types.dart';

class ComposePmiService {
  final LoggerService logger;

  const ComposePmiService({required this.logger});

  Future<void> generate(ComposeArgs args, {bool sectionMode = false}) async {
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
    final sectionWidgets = sectionMode
        ? await _resolveSectionWidgets(uiSlicePath)
        : const _SectionWidgetInfo();

    final widgetInfo = sectionMode
        ? const _PmiWidgetInfo()
        : await _resolvePmiWidgets(uiSlicePath);
    if (!sectionMode && widgetInfo.popupMenuItemClass == null) {
      logger.error(
        'Popup menu item widget was not found in modules/${args.module}/lib/src/features/${args.feature}/ui/${args.slice}/widgets.',
      );
      exitCode = 1;
      return;
    }

    final pageClass = args.targetPage.pascalCase;
    final pageFileName = '${args.targetPage.snakeCase}.dart';
    final pageDir = p.join(appModulePath, 'features', args.feature, 'pages');
    final pagePath = p.join(pageDir, pageFileName);

    final pageFile = File(pagePath);
    var createdScaffold = false;
    if (!await pageFile.exists()) {
      final scaffoldPageCode = _buildEmptyScaffoldPageCode(
        appLibPath: appLibPath,
        pageClass: pageClass,
        pageDir: pageDir,
        sectionMode: sectionMode,
      );

      await pageFile.create(recursive: true);
      await pageFile.writeAsString(
        '${_normalizeBlankLines(scaffoldPageCode).trimRight()}\n',
      );
      createdScaffold = true;
    }

    var source = await pageFile.readAsString();

    final diImport = p
        .relative(p.join(appLibPath, 'core', 'di', 'di.dart'), from: pageDir)
        .replaceAll('\\', '/');
    final failureImport = p
        .relative(
          p.join(appLibPath, 'core', 'extensions', 'failure_x.dart'),
          from: pageDir,
        )
        .replaceAll('\\', '/');

    source = _insertImport(
      source,
      "import 'package:flutter_bloc/flutter_bloc.dart';",
    );
    source = _insertImport(
      source,
      "import 'package:${args.module}/${args.module}.dart';",
    );
    source = _insertImport(source, "import '$diImport';");
    source = _insertImport(source, "import 'package:app_ui/app_ui.dart';");
    source = _insertImport(source, "import '$failureImport';");

    final executionMethod = sectionMode
        ? _selectSectionExecutionMethod(primaryLogic.methods)
        : _selectExecutionMethod(primaryLogic.methods);
    if (executionMethod == null) {
      logger.error(
        'Unable to infer execution method for ${primaryLogic.logicClass}. ${sectionMode ? 'compose-sec' : 'compose-pmi'} requires at least one invokable public method.',
      );
      exitCode = 1;
      return;
    }

    final pageFieldTypes = _parsePageFieldTypes(source);
    final executionMethodName = sectionMode
        ? '_${executionMethod.name.camelCase}'
        : '_execute${primaryLogic.logicClass.pascalCase}';
    final executionBody = await _buildExecutionCall(
      moduleFeaturePath: moduleFeaturePath,
      logicClass: primaryLogic.logicClass,
      executionMethod: executionMethod,
      pageFieldTypes: pageFieldTypes,
    );

    final providerCascade =
        sectionMode && _canInvokeWithoutArgs(executionMethod.params)
        ? '..${executionMethod.name}()'
        : '';

    final providerMap = <String, String>{
      'BlocProvider<${primaryLogic.logicClass}>':
          'BlocProvider<${primaryLogic.logicClass}>(create: (_) => sl()$providerCascade),',
    };

    final listenersMap = sectionMode
        ? const <String, String>{}
        : <String, String>{
            if (primaryLogic.stateInfo.hasVariant('success') ||
                primaryLogic.stateInfo.hasVariant('failure'))
              'BlocListener<${primaryLogic.logicClass}, ${primaryLogic.stateClass}>':
                  'BlocListener<${primaryLogic.logicClass}, ${primaryLogic.stateClass}>(listener: _${primaryLogic.logicClass.camelCase}Listener),',
          };

    final updatedProviders = _upsertBuildPageListEntries(
      source: source,
      label: 'providers',
      signatureToEntry: providerMap,
    );
    if (updatedProviders == null) {
      logger.error(
        'Unable to inject providers into target page. Ensure page uses buildPage(...) with providers/listeners lists.',
      );
      exitCode = 1;
      return;
    }
    source = updatedProviders;

    final updatedListeners = _upsertBuildPageListEntries(
      source: source,
      label: 'listeners',
      signatureToEntry: listenersMap,
    );
    if (updatedListeners == null) {
      logger.error(
        'Unable to inject listeners into target page. Ensure page uses buildPage(...) with providers/listeners lists.',
      );
      exitCode = 1;
      return;
    }
    source = updatedListeners;

    final executionMethodBlock =
        '''
  void $executionMethodName(BuildContext context) {
    $executionBody
  }''';

    final sectionMethodName = sectionMode
        ? '_${args.feature.camelCase}${args.slice.pascalCase}Section'
        : null;
    final sectionMethodBlock = !sectionMode
        ? ''
        : _buildSectionWidgetMethod(
            feature: args.feature,
            logic: primaryLogic,
            sectionWidgets: sectionWidgets,
            sectionMethodName: sectionMethodName!,
            executionMethodName: executionMethodName,
          );

    final dialogClass = widgetInfo.dialogClass;
    final showDialogMethodName = sectionMode || dialogClass == null
        ? null
        : '_show${dialogClass.pascalCase}';

    final showDialogMethodBlock = dialogClass == null
        ? ''
        : '''

  Future<void> $showDialogMethodName(BuildContext context) {
    return $dialogClass(
      onConfirm: () {
        $executionMethodName(context);
      },
    ).show(context);
  }''';

    if (!sectionMode) {
      final listenerMethod = _buildListenerMethod(
        module: args.module,
        feature: args.feature,
        slice: args.slice,
        logic: primaryLogic,
      );

      source = _upsertMethod(
        source,
        'void _${primaryLogic.logicClass.camelCase}Listener(',
        listenerMethod,
      );
    }
    source = _upsertMethod(
      source,
      'void $executionMethodName(',
      executionMethodBlock,
    );
    if (sectionMethodName != null && sectionMethodBlock.trim().isNotEmpty) {
      source = _upsertMethod(
        source,
        'Widget $sectionMethodName(',
        sectionMethodBlock,
      );
    }
    if (showDialogMethodName != null) {
      source = _upsertMethod(
        source,
        'Future<void> $showDialogMethodName(',
        showDialogMethodBlock,
      );
    }

    if (!sectionMode) {
      final popupActionCall = showDialogMethodName == null
          ? '$executionMethodName(context);'
          : '$showDialogMethodName(context);';

      final popupClassName = widgetInfo.popupMenuItemClass!;
      final withAction = _upsertPopupMenuAction(
        source: source,
        popupClassName: popupClassName,
        actionBody: popupActionCall,
      );
      if (withAction == null) {
        logger.error(
          'Unable to inject popup action into target page. compose-pmi requires an AppBar actions list or an existing PopupMenuButton.',
        );
        exitCode = 1;
        return;
      }
      source = withAction;
    }

    if (sectionMode && createdScaffold && sectionMethodName != null) {
      source = _seedSectionScaffold(
        source: source,
        pageClass: pageClass,
        sectionMethodName: sectionMethodName,
      );
    }

    await pageFile.writeAsString(
      '${_normalizeBlankLines(source).trimRight()}\n',
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
      updateBaseBuilder: false,
    );

    logger.success(
      '${sectionMode ? 'compose-sec' : 'compose-pmi'} generated for slice "${args.slice}" in feature "${args.feature}" (module: "${args.module}", app: "${args.app}").',
    );
    logger.info(
      '${createdScaffold ? 'Generated page scaffold' : 'Updated page'}: apps/${args.app}/lib/modules/${args.module}/features/${args.feature}/pages/$pageFileName',
    );
    if (sectionMode) {
      logger.info(
        'Section method generated: $sectionMethodName(). Place it manually in Scaffold/body as needed.',
      );
      logger.info('Execution trigger method: $executionMethodName(context)');
    }
    logger.info(
      'Updated child route + navigation helper: apps/${args.app}/lib/modules/${args.module}/${args.module}_route.dart',
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

      final stateImportMatch = RegExp(
        r"import\s+'([^']+_state\.dart)';",
      ).firstMatch(source);
      final statePath = stateImportMatch == null
          ? null
          : p.normalize(
              p.join(p.dirname(file.path), stateImportMatch.group(1)!),
            );

      final stateInfo = statePath == null
          ? _StateInfo.empty(stateClass)
          : await _parseStateInfo(stateClass: stateClass, statePath: statePath);

      targets.add(
        _LogicTarget(
          logicClass: logicClass,
          stateClass: stateClass,
          stateInfo: stateInfo,
          methods: methods,
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
      final params = (match.group(3) ?? '').trim();
      if (name.startsWith('_')) continue;
      if (name == 'close') continue;

      methods.add(
        _MethodCandidate(name: name, returnType: returnType, params: params),
      );
    }

    return methods;
  }

  _MethodCandidate? _selectExecutionMethod(List<_MethodCandidate> methods) {
    final candidates = methods.where((method) {
      const blockedExact = <String>{'init', 'refresh', 'loadMore'};
      if (blockedExact.contains(method.name)) return false;

      const blockedPrefixes = <String>['get', 'load', 'fetch', 'watch'];
      for (final prefix in blockedPrefixes) {
        if (method.name.startsWith(prefix)) {
          return false;
        }
      }
      return true;
    }).toList();

    if (candidates.isEmpty) return null;
    return candidates.first;
  }

  _MethodCandidate? _selectSectionExecutionMethod(
    List<_MethodCandidate> methods,
  ) {
    final zeroArgMethods = methods
        .where((method) => _canInvokeWithoutArgs(method.params))
        .toList();

    if (zeroArgMethods.isNotEmpty) {
      const preferredExact = <String>['init', 'refresh'];
      for (final methodName in preferredExact) {
        final found = zeroArgMethods.firstWhere(
          (method) => method.name == methodName,
          orElse: () => const _MethodCandidate.none(),
        );
        if (found.isValid) return found;
      }

      const preferredPrefixes = <String>['get', 'load', 'fetch', 'watch'];
      for (final prefix in preferredPrefixes) {
        final found = zeroArgMethods.firstWhere(
          (method) => method.name.startsWith(prefix),
          orElse: () => const _MethodCandidate.none(),
        );
        if (found.isValid) return found;
      }

      return zeroArgMethods.first;
    }

    if (methods.isEmpty) return null;
    return methods.first;
  }

  bool _canInvokeWithoutArgs(String params) {
    final trimmed = params.trim();
    if (trimmed.isEmpty) return true;

    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return !RegExp(r'\brequired\b').hasMatch(trimmed);
    }

    return false;
  }

  Future<_StateInfo> _parseStateInfo({
    required String stateClass,
    required String statePath,
  }) async {
    final file = File(statePath);
    if (!await file.exists()) return _StateInfo.empty(stateClass);

    final source = await file.readAsString();
    final variants = <_StateVariant>[];

    final factoryRegex = RegExp(
      r'const\s+factory\s+' +
          RegExp.escape(stateClass) +
          r'\.(\w+)\s*\(([^)]*)\)\s*=',
      multiLine: true,
      dotAll: true,
    );

    for (final match in factoryRegex.allMatches(source)) {
      final name = match.group(1)!;
      final rawParams = (match.group(2) ?? '').trim();
      final firstParam = _parseFirstParam(rawParams);

      variants.add(
        _StateVariant(
          name: name,
          firstParamType: firstParam.$1,
          firstParamName: firstParam.$2,
        ),
      );
    }

    return _StateInfo(stateClass: stateClass, variants: variants);
  }

  (String?, String?) _parseFirstParam(String rawParams) {
    if (rawParams.isEmpty) return (null, null);

    final normalized = rawParams.replaceAll('{', '').replaceAll('}', '').trim();
    if (normalized.isEmpty) return (null, null);

    final firstParam = normalized
        .split(',')
        .map((value) => value.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    if (firstParam.isEmpty) return (null, null);

    final match = RegExp(
      r'(?:required\s+)?([A-Za-z0-9_<>,? ]+)\s+([A-Za-z_]\w*)$',
    ).firstMatch(firstParam);

    if (match == null) return (null, null);

    return (match.group(1)?.trim(), match.group(2)?.trim());
  }

  Future<_PmiWidgetInfo> _resolvePmiWidgets(String uiSlicePath) async {
    final widgetsDir = Directory(p.join(uiSlicePath, 'widgets'));
    if (!await widgetsDir.exists()) return const _PmiWidgetInfo();

    String? popupMenuItemClass;
    String? dialogClass;

    await for (final entity in widgetsDir.list(recursive: true)) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;

      final source = await entity.readAsString();

      if (popupMenuItemClass == null &&
          entity.path.endsWith('_popup_menu_item.dart')) {
        final classMatch = RegExp(
          r'class\s+([A-Za-z_]\w*)\s+extends\s+PopupMenuItem',
        ).firstMatch(source);
        if (classMatch != null) {
          popupMenuItemClass = classMatch.group(1)!;
        }
      }

      if (dialogClass == null && entity.path.endsWith('_dialog.dart')) {
        final classMatch = RegExp(
          r'class\s+([A-Za-z_]\w*)\s+extends\s+StatelessWidget',
        ).firstMatch(source);
        if (classMatch != null && source.contains('required this.onConfirm')) {
          dialogClass = classMatch.group(1)!;
        }
      }
    }

    return _PmiWidgetInfo(
      popupMenuItemClass: popupMenuItemClass,
      dialogClass: dialogClass,
    );
  }

  Future<_SectionWidgetInfo> _resolveSectionWidgets(String uiSlicePath) async {
    final widgetsDir = Directory(p.join(uiSlicePath, 'widgets'));
    if (!await widgetsDir.exists()) return const _SectionWidgetInfo();

    String? sectionClass;
    String? contentClass;
    String? emptyFeedbackClass;
    String? errorFeedbackClass;
    String? skeletonClass;
    String? contentListField;

    await for (final entity in widgetsDir.list(recursive: true)) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;

      final source = await entity.readAsString();
      final classMatch = RegExp(
        r'class\s+([A-Za-z_]\w*)\s+extends\s+StatelessWidget',
      ).firstMatch(source);
      final className = classMatch?.group(1);
      if (className == null) continue;

      if (entity.path.endsWith('_section.dart')) {
        sectionClass = className;
      } else if (entity.path.endsWith('_content.dart')) {
        contentClass = className;
        final fieldMatches = RegExp(
          r'final\s+List<[^>]+>\s+([A-Za-z_]\w*)\s*;',
        ).allMatches(source);
        if (fieldMatches.isNotEmpty) {
          contentListField = fieldMatches.first.group(1);
        }
      } else if (entity.path.endsWith('_empty_feedback.dart')) {
        emptyFeedbackClass = className;
      } else if (entity.path.endsWith('_error_feedback.dart')) {
        errorFeedbackClass = className;
      } else if (entity.path.endsWith('_skeleton.dart')) {
        skeletonClass = className;
      }
    }

    return _SectionWidgetInfo(
      sectionClass: sectionClass,
      contentClass: contentClass,
      emptyFeedbackClass: emptyFeedbackClass,
      errorFeedbackClass: errorFeedbackClass,
      skeletonClass: skeletonClass,
      contentListField: contentListField,
    );
  }

  String _buildSectionWidgetMethod({
    required String feature,
    required _LogicTarget logic,
    required _SectionWidgetInfo sectionWidgets,
    required String sectionMethodName,
    required String executionMethodName,
  }) {
    final sectionClass =
        sectionWidgets.sectionClass ?? '${feature.pascalCase}Section';
    final contentClass =
        sectionWidgets.contentClass ?? '${feature.pascalCase}Content';
    final skeletonClass =
        sectionWidgets.skeletonClass ?? '${feature.pascalCase}Skeleton';
    final emptyClass =
        sectionWidgets.emptyFeedbackClass ??
        '${feature.pascalCase}EmptyFeedback';
    final errorClass =
        sectionWidgets.errorFeedbackClass ??
        '${feature.pascalCase}ErrorFeedback';
    final listField = sectionWidgets.contentListField ?? 'list';
    final tappedName = feature.pascalCase;

    return '''
  Widget $sectionMethodName() {
    return $sectionClass(
      content: BlocBuilder<${logic.logicClass}, ${logic.stateClass}>(
        builder: (context, state) {
          return state.when(
            initial: () => const $skeletonClass(),
            loading: () => const $skeletonClass(),
            failure: (failure) => $errorClass(
              message: failure.localizeAny(context),
              onRetry: () {
                $executionMethodName(context);
              },
            ),
            loaded: (data) {
              if (data.isEmpty) {
                return $emptyClass(
                  onRefresh: () {
                    $executionMethodName(context);
                  },
                );
              }
              return $contentClass(
                $listField: data,
                onItemTap: (item) {
                  context.showSuccessSnackbar(
                    '$tappedName tapped: \${item.name}',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }''';
  }

  String _seedSectionScaffold({
    required String source,
    required String pageClass,
    required String sectionMethodName,
  }) {
    final scaffoldPattern = RegExp(
      r'return\s+Scaffold\(\s*body:\s*const\s+SizedBox\.shrink\(\),\s*\);',
      multiLine: true,
    );

    final replacement =
        '''return Scaffold(
          appBar: AppBar(title: const Text('$pageClass')),
          body: ListView(children: [$sectionMethodName()]),
        );''';

    if (scaffoldPattern.hasMatch(source)) {
      return source.replaceFirst(scaffoldPattern, replacement);
    }

    return source;
  }

  Map<String, String> _parsePageFieldTypes(String source) {
    final fieldTypes = <String, String>{};
    final fieldRegex = RegExp(r'final\s+([^;=]+?)\s+([A-Za-z_]\w*)\s*;');
    for (final match in fieldRegex.allMatches(source)) {
      final type = match.group(1)?.trim();
      final name = match.group(2)?.trim();
      if (type == null || name == null || type.isEmpty || name.isEmpty) {
        continue;
      }
      fieldTypes[name] = type;
    }
    return fieldTypes;
  }

  Future<String> _buildExecutionCall({
    required String moduleFeaturePath,
    required String logicClass,
    required _MethodCandidate executionMethod,
    required Map<String, String> pageFieldTypes,
  }) async {
    if (executionMethod.params.trim().isEmpty) {
      return 'context.read<$logicClass>().${executionMethod.name}();';
    }

    final normalizedParams = executionMethod.params
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .trim();

    final firstParam = normalizedParams
        .split(',')
        .map((value) => value.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    final paramMatch = RegExp(
      r'(?:required\s+)?([A-Za-z0-9_<>,? ]+)\s+([A-Za-z_]\w*)$',
    ).firstMatch(firstParam);

    if (paramMatch == null) {
      return 'context.read<$logicClass>().${executionMethod.name}();';
    }

    final paramType = (paramMatch.group(1) ?? '').trim();
    final paramName = (paramMatch.group(2) ?? '').trim();
    final cleanParamType = paramType.replaceAll('?', '').trim();

    String argumentExpression;
    if (cleanParamType.endsWith('Param')) {
      argumentExpression = await _buildParamObjectExpression(
        moduleFeaturePath: moduleFeaturePath,
        paramType: cleanParamType,
        pageFieldTypes: pageFieldTypes,
      );
    } else {
      argumentExpression = _resolvePageFieldExpression(
        wantedName: paramName,
        wantedType: cleanParamType,
        pageFieldTypes: pageFieldTypes,
      );
    }

    return 'context.read<$logicClass>().${executionMethod.name}($argumentExpression);';
  }

  Future<String> _buildParamObjectExpression({
    required String moduleFeaturePath,
    required String paramType,
    required Map<String, String> pageFieldTypes,
  }) async {
    final paramPath = p.join(
      moduleFeaturePath,
      'domain',
      'params',
      '${paramType.snakeCase}.dart',
    );

    final paramFile = File(paramPath);
    if (!await paramFile.exists()) {
      return '$paramType()';
    }

    final source = await paramFile.readAsString();
    final constructorMatch = RegExp(
      r'const\s+factory\s+' + RegExp.escape(paramType) + r'\s*\(([^)]*)\)',
      dotAll: true,
    ).firstMatch(source);

    if (constructorMatch == null) {
      return '$paramType()';
    }

    final constructorSource = constructorMatch.group(1) ?? '';
    final fields = <({String type, String name})>[];

    final paramRegex = RegExp(
      r'(?:required\s+)?([A-Za-z0-9_<>,? ]+)\s+([A-Za-z_]\w*)',
    );
    for (final match in paramRegex.allMatches(constructorSource)) {
      final type = (match.group(1) ?? '').trim();
      final name = (match.group(2) ?? '').trim();
      if (type.isEmpty || name.isEmpty) continue;
      fields.add((type: type, name: name));
    }

    if (fields.isEmpty) {
      return '$paramType()';
    }

    final args = fields
        .map((field) {
          final expression = _resolvePageFieldExpression(
            wantedName: field.name,
            wantedType: field.type.replaceAll('?', '').trim(),
            pageFieldTypes: pageFieldTypes,
          );
          return '${field.name}: $expression,';
        })
        .join('\n      ');

    return '''$paramType(
      $args
    )''';
  }

  String _resolvePageFieldExpression({
    required String wantedName,
    required String wantedType,
    required Map<String, String> pageFieldTypes,
  }) {
    if (pageFieldTypes.containsKey(wantedName)) {
      return wantedName;
    }

    final wantedLower = wantedName.toLowerCase();
    final exactByType = pageFieldTypes.entries.where((entry) {
      final type = entry.value.replaceAll('?', '').trim();
      return type == wantedType;
    }).toList();

    if (wantedLower == 'id') {
      final idField = exactByType.firstWhere(
        (entry) => entry.key.toLowerCase().endsWith('id'),
        orElse: () => const MapEntry('', ''),
      );
      if (idField.key.isNotEmpty) {
        return idField.key;
      }
    }

    final bySuffix = pageFieldTypes.entries.firstWhere(
      (entry) => entry.key.toLowerCase() == '${wantedLower}id',
      orElse: () => const MapEntry('', ''),
    );
    if (bySuffix.key.isNotEmpty) {
      return bySuffix.key;
    }

    if (exactByType.length == 1) {
      return exactByType.first.key;
    }

    final byTypeFirst = exactByType.firstWhere(
      (_) => true,
      orElse: () => const MapEntry('', ''),
    );
    if (byTypeFirst.key.isNotEmpty) {
      return byTypeFirst.key;
    }

    return _defaultValueForType(wantedType);
  }

  String _defaultValueForType(String type) {
    final normalized = type.replaceAll(' ', '');
    if (normalized == 'String') return "''";
    if (normalized == 'int') return '0';
    if (normalized == 'double') return '0';
    if (normalized == 'bool') return 'false';
    if (normalized.startsWith('List<')) return 'const []';
    return 'null';
  }

  String _buildListenerMethod({
    required String module,
    required String feature,
    required String slice,
    required _LogicTarget logic,
  }) {
    final successVariant = logic.stateInfo.variant('success');
    final hasFailure = logic.stateInfo.hasVariant('failure');

    if (successVariant == null && !hasFailure) {
      return '';
    }

    final branches = <String>['orElse: () => null,'];
    final successKey = '${feature.camelCase}${slice.pascalCase}Success';
    final l10nClass = '${module.pascalCase}Localizations';

    if (successVariant != null) {
      if (successVariant.firstParamName == null) {
        branches.add('''success: () {
        context.showSuccessSnackbar(l10n.$successKey);
      },''');
      } else {
        branches.add('''success: (${successVariant.firstParamName}) {
        context.showSuccessSnackbar(l10n.$successKey);
      },''');
      }
    }

    if (hasFailure) {
      branches.add('''failure: (failure) {
        context.showErrorSnackbar(failure.localizeAny(context));
      },''');
    }

    return '''  void _${logic.logicClass.camelCase}Listener(
    BuildContext context,
    ${logic.stateClass} state,
  ) {
    final l10n = $l10nClass.of(context)!;
    state.maybeWhen(
      ${branches.join('\n      ')}
    );
  }''';
  }

  String _upsertMethod(String source, String signature, String methodBlock) {
    if (methodBlock.trim().isEmpty) return source;
    if (source.contains(signature)) return source;

    final overrideMatch = RegExp(r'\n\s*@override').firstMatch(source);
    if (overrideMatch == null) return source;

    final block = '\n\n${methodBlock.trimRight()}\n';
    return source.replaceRange(overrideMatch.start, overrideMatch.start, block);
  }

  String? _upsertBuildPageListEntries({
    required String source,
    required String label,
    required Map<String, String> signatureToEntry,
  }) {
    final entriesToInsert = signatureToEntry.entries
        .where((entry) => !source.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    if (entriesToInsert.isEmpty) return source;

    final pattern = RegExp('($label\\s*:\\s*\\[)([\\s\\S]*?)(\\],)');
    final match = pattern.firstMatch(source);
    if (match == null) return null;

    final content = match.group(2)!;
    final itemIndent = _resolveFirstNonEmptyIndent(
      source: content,
      fallback: '        ',
    );
    final closingIndentMatch = RegExp(r'\n([ \t]*)$').firstMatch(content);
    final closingIndent = closingIndentMatch?.group(1) ?? '      ';

    final baseContent = content.trimRight();
    final insertedLines = entriesToInsert
        .map((line) => '$itemIndent$line')
        .join('\n');

    final newContent = baseContent.trim().isEmpty
        ? '\n$insertedLines\n$closingIndent'
        : '$baseContent\n$insertedLines\n$closingIndent';

    final contentStart = match.start + match.group(1)!.length;
    final contentEnd = contentStart + content.length;

    return source.replaceRange(contentStart, contentEnd, newContent);
  }

  String? _upsertPopupMenuAction({
    required String source,
    required String popupClassName,
    required String actionBody,
  }) {
    final popupSignature = '$popupClassName(';
    if (source.contains(popupSignature)) return source;

    final actionEntry =
        '''$popupClassName(
                    onTap: () {
                      $actionBody
                    },
                  ),''';

    final popupListPattern = RegExp(
      r'(itemBuilder\s*:\s*\(context\)\s*=>\s*\[)([\s\S]*?)(\],)',
    );
    final popupListMatch = popupListPattern.firstMatch(source);
    if (popupListMatch != null) {
      final content = popupListMatch.group(2)!;
      final itemIndent = _resolveFirstNonEmptyIndent(
        source: content,
        fallback: '                  ',
      );
      final closingIndentMatch = RegExp(r'\n([ \t]*)$').firstMatch(content);
      final closingIndent = closingIndentMatch?.group(1) ?? '                ';

      final baseContent = content.trimRight();
      final inserted = actionEntry
          .split('\n')
          .map((line) => '$itemIndent$line')
          .join('\n');
      final newContent = baseContent.trim().isEmpty
          ? '\n$inserted\n$closingIndent'
          : '$baseContent\n$inserted\n$closingIndent';

      final start = popupListMatch.start + popupListMatch.group(1)!.length;
      final end = start + content.length;
      return source.replaceRange(start, end, newContent);
    }

    final actionsPattern = RegExp(r'(actions\s*:\s*\[)([\s\S]*?)(\],)');
    final actionsMatch = actionsPattern.firstMatch(source);
    if (actionsMatch == null) {
      return _injectPopupMenuIntoScaffold(
        source: source,
        popupClassName: popupClassName,
        actionBody: actionBody,
      );
    }

    final content = actionsMatch.group(2)!;
    final itemIndent = _resolveFirstNonEmptyIndent(
      source: content,
      fallback: '              ',
    );
    final closingIndentMatch = RegExp(r'\n([ \t]*)$').firstMatch(content);
    final closingIndent = closingIndentMatch?.group(1) ?? '            ';

    final popupButtonLines = [
      'PopupMenuButton(',
      '  itemBuilder: (context) => [',
      '    $popupClassName(',
      '      onTap: () {',
      '        $actionBody',
      '      },',
      '    ),',
      '  ],',
      '),',
    ].map((line) => '$itemIndent$line').join('\n');

    final baseContent = content.trimRight();
    final newContent = baseContent.trim().isEmpty
        ? '\n$popupButtonLines\n$closingIndent'
        : '$baseContent\n$popupButtonLines\n$closingIndent';

    final start = actionsMatch.start + actionsMatch.group(1)!.length;
    final end = start + content.length;

    return source.replaceRange(start, end, newContent);
  }

  String? _injectPopupMenuIntoScaffold({
    required String source,
    required String popupClassName,
    required String actionBody,
  }) {
    final next = source.replaceFirst(
      RegExp(r'const\s+Scaffold\('),
      'Scaffold(',
    );

    final scaffoldMatch = RegExp(
      r'^([ \t]*)[^\n]*Scaffold\(',
      multiLine: true,
    ).firstMatch(next);
    if (scaffoldMatch == null) {
      return null;
    }

    final insertPos = scaffoldMatch.end;
    final previewEnd = insertPos + 400 < next.length
        ? insertPos + 400
        : next.length;
    final preview = next.substring(insertPos, previewEnd);
    if (preview.contains('appBar:')) {
      return null;
    }

    final scaffoldIndent = scaffoldMatch.group(1) ?? '';
    final inner = '$scaffoldIndent  ';
    final block =
        '\n$inner'
        'appBar: AppBar(\n'
        '$inner  actions: [\n'
        '$inner    PopupMenuButton(\n'
        '$inner      itemBuilder: (context) => [\n'
        '$inner        $popupClassName(\n'
        '$inner          onTap: () {\n'
        '$inner            $actionBody\n'
        '$inner          },\n'
        '$inner        ),\n'
        '$inner      ],\n'
        '$inner    ),\n'
        '$inner  ],\n'
        '$inner),';

    return next.replaceRange(insertPos, insertPos, block);
  }

  String _buildEmptyScaffoldPageCode({
    required String appLibPath,
    required String pageClass,
    required String pageDir,
    bool sectionMode = false,
  }) {
    final mixinImport = p
        .relative(
          p.join(appLibPath, 'core', 'mixins', 'page_provider_mixin.dart'),
          from: pageDir,
        )
        .replaceAll('\\', '/');

    return '''import 'package:flutter/material.dart';

import '$mixinImport';

class $pageClass extends StatelessWidget with PageProviderMixin {
  const $pageClass({super.key});

  @override
  Widget build(BuildContext context) {
    return buildPage(
      providers: [],
      listeners: [],
      builder: (_) {
        return ${sectionMode ? '''Scaffold(
          body: const SizedBox.shrink(),
        )''' : '''Scaffold(
          appBar: AppBar(
            title: const Text('$pageClass'),
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  // compose-pmi actions go here
                ],
              ),
            ],
          ),
          body: const SizedBox.shrink(),
        )'''};
      },
    );
  }
}
''';
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
  final _StateInfo stateInfo;
  final List<_MethodCandidate> methods;

  const _LogicTarget({
    required this.logicClass,
    required this.stateClass,
    required this.stateInfo,
    required this.methods,
  });
}

class _MethodCandidate {
  final String name;
  final String returnType;
  final String params;

  const _MethodCandidate({
    required this.name,
    required this.returnType,
    required this.params,
  });

  const _MethodCandidate.none() : name = '', returnType = '', params = '';

  bool get isValid => name.isNotEmpty;
}

class _StateInfo {
  final String stateClass;
  final List<_StateVariant> variants;

  const _StateInfo({required this.stateClass, required this.variants});

  const _StateInfo.empty(this.stateClass) : variants = const <_StateVariant>[];

  bool hasVariant(String name) {
    return variants.any((variant) => variant.name == name);
  }

  _StateVariant? variant(String name) {
    for (final item in variants) {
      if (item.name == name) return item;
    }
    return null;
  }
}

class _StateVariant {
  final String name;
  final String? firstParamType;
  final String? firstParamName;

  const _StateVariant({
    required this.name,
    required this.firstParamType,
    required this.firstParamName,
  });
}

class _PmiWidgetInfo {
  final String? popupMenuItemClass;
  final String? dialogClass;

  const _PmiWidgetInfo({this.popupMenuItemClass, this.dialogClass});
}

class _SectionWidgetInfo {
  final String? sectionClass;
  final String? contentClass;
  final String? emptyFeedbackClass;
  final String? errorFeedbackClass;
  final String? skeletonClass;
  final String? contentListField;

  const _SectionWidgetInfo({
    this.sectionClass,
    this.contentClass,
    this.emptyFeedbackClass,
    this.errorFeedbackClass,
    this.skeletonClass,
    this.contentListField,
  });
}
