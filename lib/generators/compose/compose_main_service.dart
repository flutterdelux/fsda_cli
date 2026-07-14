import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../../enums/compose_page_mode.dart';
import '../base_generator.dart';

class ComposeMainService
    extends
        BaseGenerator<
          void,
          ({
            String app,
            String module,
            String feature,
            String slice,
            String targetPage,
            ComposePageMode pageMode,
          })
        > {
  const ComposeMainService({required super.logger});

  @override
  Future<void> generate(
    ({
      String app,
      String module,
      String feature,
      String slice,
      String targetPage,
      ComposePageMode pageMode,
    })
    args,
  ) async {
    final app = args.app;
    final module = args.module;
    final feature = args.feature;
    final slice = args.slice;
    final targetPage = args.targetPage;
    final pageMode = args.pageMode;

    final root = Directory.current.path;

    final moduleFeaturePath = p.join(
      root,
      'modules',
      module,
      'lib',
      'src',
      'features',
      feature,
    );

    final logicDirPath = p.join(moduleFeaturePath, 'logic', slice);
    final uiSlicePath = p.join(moduleFeaturePath, 'ui', slice);

    final appLibPath = p.join(root, 'apps', app, 'lib');
    final appModulePath = p.join(appLibPath, 'modules', module);
    final routeFilePath = p.join(appModulePath, '${module}_route.dart');

    final logicTargets = await _collectLogicTargets(logicDirPath);
    if (logicTargets.isEmpty) {
      logger.error(
        'No logic class found at modules/$module/lib/src/features/$feature/logic/$slice.',
      );
      exitCode = 1;
      return;
    }

    final primaryLogic = logicTargets.first;
    final loadedPayload = _resolveLoadedPayload(primaryLogic.stateInfo);
    final itemDisplayExpression = await _resolveItemDisplayExpression(
      moduleFeaturePath: moduleFeaturePath,
      loadedPayload: loadedPayload,
    );

    final viewInfo = await _resolveViewInfo(uiSlicePath);
    final uiComponents = await _resolveUiComponents(uiSlicePath);

    final requiresView =
        pageMode == ComposePageMode.main || pageMode == ComposePageMode.form;
    if (requiresView && viewInfo == null) {
      final composeModeLabel = pageMode == ComposePageMode.form
          ? 'compose-form'
          : 'compose-main';
      logger.error(
        'Slice "$slice" in feature "$feature" does not have a view. $composeModeLabel requires a view as page scaffold.',
      );
      exitCode = 1;
      return;
    }

    final pageClass = targetPage.pascalCase;
    final pageFileName = '${targetPage.snakeCase}.dart';
    final pageDir = p.join(appModulePath, 'features', feature, 'pages');
    final pagePath = p.join(pageDir, pageFileName);

    final pageFile = File(pagePath);
    var createdInjectScaffold = false;

    if (pageMode == ComposePageMode.injectOnly) {
      if (!await pageFile.exists()) {
        final scaffoldPageCode = _buildEmptyScaffoldPageCode(
          appLibPath: appLibPath,
          pageClass: pageClass,
          pageDir: pageDir,
        );

        await pageFile.create(recursive: true);
        await pageFile.writeAsString(
          '${_normalizeBlankLines(scaffoldPageCode).trimRight()}\n',
        );
        createdInjectScaffold = true;
      }

      final existingSource = await pageFile.readAsString();
      final injected = _injectIntoExistingPage(
        source: existingSource,
        appLibPath: appLibPath,
        module: module,
        feature: feature,
        slice: slice,
        pageDir: pageDir,
        logicTargets: logicTargets,
      );

      if (injected == null) {
        logger.error(
          'Unable to inject into existing target page. Ensure page uses buildPage(...) with providers/listeners lists.',
        );
        exitCode = 1;
        return;
      }

      await pageFile.writeAsString(
        '${_normalizeBlankLines(injected).trimRight()}\n',
      );

      logger.success(
        'Compose generated for slice "$slice" in feature "$feature" (module: "$module", app: "$app").',
      );
      logger.info(
        '${createdInjectScaffold ? 'Generated page scaffold' : 'Updated page'}: apps/$app/lib/modules/$module/features/$feature/pages/$pageFileName',
      );
    } else {
      final pageCode = pageMode == ComposePageMode.form
          ? await _buildFormPageCode(
              appLibPath: appLibPath,
              module: module,
              feature: feature,
              slice: slice,
              pageClass: pageClass,
              pageDir: pageDir,
              logicTargets: logicTargets,
              viewInfo: viewInfo!,
            )
          : _buildPageCode(
              appLibPath: appLibPath,
              module: module,
              feature: feature,
              slice: slice,
              pageClass: pageClass,
              pageDir: pageDir,
              logicTargets: logicTargets,
              primaryLogic: primaryLogic,
              viewInfo: viewInfo,
              uiComponents: uiComponents,
              loadedPayload: loadedPayload,
              itemDisplayExpression: itemDisplayExpression,
            );

      if (pageCode == null) {
        exitCode = 1;
        return;
      }

      await pageFile.create(recursive: true);
      await pageFile.writeAsString(
        '${_normalizeBlankLines(pageCode).trimRight()}\n',
      );

      logger.success(
        'Compose generated for slice "$slice" in feature "$feature" (module: "$module", app: "$app").',
      );
      logger.info(
        'Generated page: apps/$app/lib/modules/$module/features/$feature/pages/$pageFileName',
      );
    }

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
      targetPage: targetPage,
      pageMode: pageMode,
    );

    if (pageMode == ComposePageMode.main || pageMode == ComposePageMode.form) {
      logger.info(
        'Updated base route + child route: apps/$app/lib/modules/$module/${module}_route.dart',
      );
    } else {
      logger.info(
        'Updated child route + navigation helper: apps/$app/lib/modules/$module/${module}_route.dart',
      );
    }
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
          bootstrapMethod: bootstrapMethod,
          methods: methods,
          stateInfo: stateInfo,
        ),
      );
    }

    targets.sort((a, b) => a.logicClass.compareTo(b.logicClass));
    return targets;
  }

  List<_MethodCandidate> _extractInvokableMethods(String source) {
    final methodRegex = RegExp(
      r'(?:Future<[^>]+>|Future<void>|void)\s+([A-Za-z_]\w*)\s*\(([^)]*)\)\s*(?:async\s*)?\{',
      multiLine: true,
    );

    final methods = <_MethodCandidate>[];
    for (final match in methodRegex.allMatches(source)) {
      final name = match.group(1)!;
      final params = match.group(2) ?? '';
      if (name.startsWith('_')) continue;
      if (name == 'close') continue;

      methods.add(
        _MethodCandidate(
          name: name,
          rawParams: params,
          hasRequiredParam: _hasRequiredParam(params),
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

  bool _hasRequiredParam(String params) {
    final trimmed = params.trim();
    if (trimmed.isEmpty) return false;

    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return RegExp(r'\brequired\b').hasMatch(trimmed);
    }

    return true;
  }

  String? _selectBootstrapMethod(List<_MethodCandidate> methods) {
    final zeroArgMethods = methods
        .where((method) => method.canInvokeWithoutArgs)
        .toList();
    if (zeroArgMethods.isEmpty) return null;

    const preferredExact = <String>['init', 'refresh'];
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

  _LoadedPayload? _resolveLoadedPayload(_StateInfo stateInfo) {
    final loaded = stateInfo.variant('loaded');
    if (loaded != null && loaded.firstParamName != null) {
      return _buildLoadedPayload('loaded', loaded);
    }

    final success = stateInfo.variant('success');
    if (success != null && success.firstParamName != null) {
      return _buildLoadedPayload('success', success);
    }

    return null;
  }

  _LoadedPayload _buildLoadedPayload(String branchName, _StateVariant variant) {
    final paramType = variant.firstParamType?.trim() ?? 'dynamic';
    final normalizedType = paramType.replaceAll(' ', '');
    final listMatch = RegExp(r'^List<(.+)>\??$').firstMatch(normalizedType);

    final isList = listMatch != null;
    final itemType = listMatch?.group(1);

    return _LoadedPayload(
      branchName: branchName,
      paramName: variant.firstParamName ?? 'data',
      paramType: paramType,
      isList: isList,
      itemType: itemType,
    );
  }

  Future<String> _resolveItemDisplayExpression({
    required String moduleFeaturePath,
    required _LoadedPayload? loadedPayload,
  }) async {
    if (loadedPayload == null || !loadedPayload.isList) {
      return 'item';
    }

    final rawType = loadedPayload.itemType;
    if (rawType == null || rawType.isEmpty) {
      return 'item';
    }

    final itemType = rawType.replaceAll('?', '').trim();
    final entityPath = p.join(
      moduleFeaturePath,
      'domain',
      'entities',
      '${itemType.snakeCase}.dart',
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

  Future<_ViewInfo?> _resolveViewInfo(String uiSlicePath) async {
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
      } else if (path.endsWith('_skeleton.dart') && skeleton == null) {
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

  Future<_FormArtifacts?> _resolveFormArtifacts({
    required String moduleFeaturePath,
    required String slice,
  }) async {
    final logicDir = Directory(p.join(moduleFeaturePath, 'logic', slice));
    final widgetsDir = Directory(
      p.join(moduleFeaturePath, 'ui', slice, 'widgets'),
    );

    String? formCubitClass;
    String? formCubitMethod;
    String? formStateClass;
    String? formParamType;

    if (await logicDir.exists()) {
      await for (final entity in logicDir.list(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (!entity.path.endsWith('_form_cubit.dart')) continue;

        final source = await entity.readAsString();

        final classMatch = RegExp(
          r'class\s+([A-Za-z_]\w*)\s+extends\s+(?:Cubit|Bloc)<\s*([A-Za-z_]\w*)',
        ).firstMatch(source);
        if (classMatch != null) {
          formCubitClass = classMatch.group(1);
          formStateClass = classMatch.group(2);
        }

        RegExpMatch? updateMethodMatch;
        final methodMatches = RegExp(
          r'void\s+([A-Za-z_]\w*)\s*\(([^)]*)\)\s*\{',
          multiLine: true,
        ).allMatches(source);
        for (final methodMatch in methodMatches) {
          if ((methodMatch.group(1) ?? '') == 'close') continue;
          updateMethodMatch = methodMatch;
          break;
        }

        if (updateMethodMatch != null) {
          formCubitMethod = updateMethodMatch.group(1);
          final params = updateMethodMatch.group(2) ?? '';
          final firstParam = params
              .split(',')
              .map((e) => e.trim())
              .firstWhere((e) => e.isNotEmpty, orElse: () => '');
          final firstParamType = RegExp(
            r'(?:required\s+)?([A-Za-z0-9_<>,? ]+)\s+[A-Za-z_]\w*$',
          ).firstMatch(firstParam)?.group(1);
          if (firstParamType != null && firstParamType.trim().isNotEmpty) {
            formParamType = firstParamType.trim().replaceAll('?', '');
          }
        }

        if (formCubitClass != null && formCubitMethod != null) {
          break;
        }
      }
    }

    String? formWidgetClass;
    if (await widgetsDir.exists()) {
      await for (final entity in widgetsDir.list(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (!entity.path.endsWith('_form.dart')) continue;

        final source = await entity.readAsString();
        final classMatch = RegExp(
          r'class\s+([A-Za-z_]\w*)\s+extends\s+StatefulWidget',
        ).firstMatch(source);
        if (classMatch != null) {
          formWidgetClass = classMatch.group(1);
          break;
        }
      }
    }

    if (formCubitClass == null ||
        formCubitMethod == null ||
        formWidgetClass == null ||
        formParamType == null) {
      return null;
    }

    return _FormArtifacts(
      formCubitClass: formCubitClass,
      formCubitMethod: formCubitMethod,
      formStateClass: formStateClass ?? '${formCubitClass}State',
      formWidgetClass: formWidgetClass,
      formParamType: formParamType,
    );
  }

  Future<String?> _buildFormPageCode({
    required String appLibPath,
    required String module,
    required String feature,
    required String slice,
    required String pageClass,
    required String pageDir,
    required List<_LogicTarget> logicTargets,
    required _ViewInfo viewInfo,
  }) async {
    final mutationLogic = logicTargets.firstWhere(
      (logic) => _isMutationLogic(logic),
      orElse: () => logicTargets.first,
    );

    final submitMethod = _selectMutationSubmitMethod(mutationLogic);
    if (submitMethod == null) {
      logger.error(
        'compose-form requires mutation logic with one public method that accepts a param object.',
      );
      return null;
    }

    final formArtifacts = await _resolveFormArtifacts(
      moduleFeaturePath: p.join(
        Directory.current.path,
        'modules',
        module,
        'lib',
        'src',
        'features',
        feature,
      ),
      slice: slice,
    );

    if (formArtifacts == null) {
      logger.error(
        'compose-form could not locate form artifacts. Ensure ui_form bundle is present (form widget + form cubit).',
      );
      return null;
    }

    final mutationMethodName = '_${submitMethod.name}';
    final listenerMethodName = '_${mutationLogic.logicClass.camelCase}Listener';
    final successKey = '${feature.camelCase}${slice.pascalCase}Success';
    final formInvalidKey = 'failure${feature.pascalCase}FormInvalid';
    final l10nClass = '${module.pascalCase}Localizations';

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

    final viewClass = viewInfo.className;
    final viewSupportsForm = viewInfo.requiredFields.contains('form');
    final viewSupportsSubmitButton = viewInfo.requiredFields.contains(
      'submitButton',
    );
    final viewSupportsContent = viewInfo.requiredFields.contains('content');

    final formParamVar = 'formStateParam';

    late String buildView;
    if (viewSupportsForm && viewSupportsSubmitButton) {
      buildView =
          '''$viewClass(
              form: ${formArtifacts.formWidgetClass}(
                onListen: (context, param, invalidMessage) {
                  context.read<${formArtifacts.formCubitClass}>().${formArtifacts.formCubitMethod}(
                    param,
                    invalidMessage,
                  );
                },
              ),
              submitButton: BlocBuilder<${mutationLogic.logicClass}, ${mutationLogic.stateClass}>(
                builder: (_, state) {
                  final isLoading = state.maybeWhen(
                    orElse: () => false,
                    loading: () => true,
                  );
                  return ${feature.pascalCase}${slice.pascalCase}Button(
                    isLoading: isLoading,
                    onPressed: () => $mutationMethodName(context),
                  );
                },
              ),
            )''';
    } else if (viewSupportsForm && !viewSupportsSubmitButton) {
      buildView =
          '''$viewClass(
              form: ${formArtifacts.formWidgetClass}(
                onListen: (context, param, invalidMessage) {
                  context.read<${formArtifacts.formCubitClass}>().${formArtifacts.formCubitMethod}(
                    param,
                    invalidMessage,
                  );
                },
              ),
            )''';
    } else if (viewSupportsContent) {
      buildView =
          '''$viewClass(
              content: ${formArtifacts.formWidgetClass}(
                onListen: (context, param, invalidMessage) {
                  context.read<${formArtifacts.formCubitClass}>().${formArtifacts.formCubitMethod}(
                    param,
                    invalidMessage,
                  );
                },
              ),
            )''';
    } else {
      buildView = '$viewClass()';
    }

    final pageCode =
        '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:$module/$module.dart';

import '$diImport';
import '$failureImport';
import '$mixinImport';

class $pageClass extends StatelessWidget with PageProviderMixin {
  const $pageClass({super.key});

  void $mutationMethodName(BuildContext context) {
    final l10n = $l10nClass.of(context)!;

    final formState = context.read<${formArtifacts.formCubitClass}>().state;
    if (formState.invalidMessage != null) {
      context.showErrorSnackbar(formState.invalidMessage!);
      return;
    }

    final ${formArtifacts.formParamType}? $formParamVar = formState.param;
    if ($formParamVar == null) {
      context.showErrorSnackbar(l10n.$formInvalidKey);
      return;
    }

    context.read<${mutationLogic.logicClass}>().${submitMethod.name}($formParamVar);
  }

  void $listenerMethodName(BuildContext context, ${mutationLogic.stateClass} state) {
    final l10n = $l10nClass.of(context)!;
    state.maybeWhen(
      orElse: () => null,
      failure: (failure) =>
          context.showErrorSnackbar(failure.localizeAny(context)),
      success: (_) {
        context.showSuccessSnackbar(l10n.$successKey);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildPage(
      providers: [
        BlocProvider<${mutationLogic.logicClass}>(create: (_) => sl()),
        BlocProvider<${formArtifacts.formCubitClass}>(create: (_) => sl()),
      ],
      listeners: [
        BlocListener<${mutationLogic.logicClass}, ${mutationLogic.stateClass}>(
          listener: $listenerMethodName,
        ),
      ],
      builder: (context) {
        return Stack(
          children: [
            $buildView,
            BlocBuilder<${mutationLogic.logicClass}, ${mutationLogic.stateClass}>(
              builder: (_, state) => state.maybeWhen(
                orElse: () => const SizedBox.shrink(),
                loading: () => const AppLoadingOverlay(),
              ),
            ),
          ],
        );
      },
    );
  }
}
''';

    return pageCode;
  }

  bool _isMutationLogic(_LogicTarget logic) {
    return logic.methods.any((method) {
      if (method.name == 'init' || method.name == 'refresh') return false;
      if (method.name.startsWith('get') ||
          method.name.startsWith('fetch') ||
          method.name.startsWith('load') ||
          method.name.startsWith('watch')) {
        return false;
      }
      return method.hasRequiredParam;
    });
  }

  _MethodCandidate? _selectMutationSubmitMethod(_LogicTarget logic) {
    final candidates = logic.methods.where((method) {
      if (method.name.startsWith('_')) return false;
      if (!method.hasRequiredParam) return false;
      if (method.name == 'close') return false;
      return true;
    }).toList();

    if (candidates.isEmpty) return null;

    final preferred = candidates.firstWhere(
      (method) =>
          method.name.startsWith('create') ||
          method.name.startsWith('save') ||
          method.name.startsWith('submit') ||
          method.name.startsWith('update') ||
          method.name.startsWith('delete'),
      orElse: () => const _MethodCandidate.none(),
    );

    if (preferred.isValid) return preferred;
    return candidates.first;
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

  String _buildPageCode({
    required String appLibPath,
    required String module,
    required String feature,
    required String slice,
    required String pageClass,
    required String pageDir,
    required List<_LogicTarget> logicTargets,
    required _LogicTarget primaryLogic,
    required _ViewInfo? viewInfo,
    required _UiComponents uiComponents,
    required _LoadedPayload? loadedPayload,
    required String itemDisplayExpression,
  }) {
    final hasView = viewInfo != null;
    final hasPrimaryAction = primaryLogic.bootstrapMethod != null;
    const primaryActionMethodName = '_runPrimaryAction';

    final includeOnItemTapMethod =
        hasView &&
        loadedPayload != null &&
        loadedPayload.isList &&
        _contentWantsOnItemTap(uiComponents.content);

    final onItemTapMethodName = includeOnItemTapMethod ? '_onItemTap' : null;
    final onItemTapEntityType =
        loadedPayload?.itemType?.replaceAll('?', '').trim() ?? 'dynamic';
    final itemDisplayInterpolation = "${r'${'}$itemDisplayExpression}";

    final providerEntries = logicTargets
        .map((logic) {
          final cascade = logic.bootstrapMethod == null
              ? ''
              : '..${logic.bootstrapMethod!}()';
          return 'BlocProvider<${logic.logicClass}>(create: (_) => sl()$cascade),';
        })
        .join('\n        ');

    final listenerTargets = hasView
        ? const <_LogicTarget>[]
        : logicTargets
              .where(
                (logic) =>
                    logic.stateInfo.hasVariant('success') ||
                    logic.stateInfo.hasVariant('failure'),
              )
              .toList();

    final listenerMethods = listenerTargets
        .map(
          (logic) => _buildListenerMethod(
            module: module,
            feature: feature,
            slice: slice,
            logic: logic,
          ),
        )
        .where((method) => method.trim().isNotEmpty)
        .join('\n\n');

    final listenersLiteral = listenerTargets.isEmpty
        ? ''
        : '\n        ${listenerTargets.map((logic) {
            final listenerName = '_${logic.logicClass.camelCase}Listener';
            return 'BlocListener<${logic.logicClass}, ${logic.stateClass}>(listener: $listenerName),';
          }).join('\n        ')}\n      ';

    final primaryActionMethod = hasPrimaryAction
        ? '''
  void $primaryActionMethodName(BuildContext context) {
    context.read<${primaryLogic.logicClass}>().${primaryLogic.bootstrapMethod!}();
  }
'''
        : '';

    final onItemTapMethod = onItemTapMethodName == null
        ? ''
        : '''
  void $onItemTapMethodName(BuildContext context, $onItemTapEntityType item) {
    context.showSuccessSnackbar('Tapped on: $itemDisplayInterpolation');
  }
''';

    final buildPrimaryContentMethod =
        hasView && _viewNeedsPrimaryContent(viewInfo)
        ? _buildPrimaryContentMethod(
            logic: primaryLogic,
            uiComponents: uiComponents,
            loadedPayload: loadedPayload,
            hasPrimaryAction: hasPrimaryAction,
            primaryActionMethodName: primaryActionMethodName,
            onItemTapMethodName: onItemTapMethodName,
          )
        : '';

    final buildLoadingOverlayMethod =
        !hasView && primaryLogic.stateInfo.hasVariant('loading')
        ? _buildLoadingOverlayMethod(primaryLogic)
        : '';

    final bodyReturn = hasView
        ? _buildViewReturn(
            viewInfo: viewInfo,
            hasPrimaryAction: hasPrimaryAction,
            primaryActionMethodName: primaryActionMethodName,
          )
        : _buildFallbackReturn(
            feature: feature,
            slice: slice,
            primaryLogic: primaryLogic,
            hasPrimaryAction: hasPrimaryAction,
            primaryActionMethodName: primaryActionMethodName,
            hasLoadingOverlay: buildLoadingOverlayMethod.isNotEmpty,
          );

    final classBody =
        '''
class $pageClass extends StatelessWidget with PageProviderMixin {
  const $pageClass({super.key});

${primaryActionMethod.isEmpty ? '' : '$primaryActionMethod\n'}${onItemTapMethod.isEmpty ? '' : '$onItemTapMethod\n'}${listenerMethods.isEmpty ? '' : '$listenerMethods\n\n'}${buildPrimaryContentMethod.isEmpty ? '' : '$buildPrimaryContentMethod\n\n'}${buildLoadingOverlayMethod.isEmpty ? '' : '$buildLoadingOverlayMethod\n\n'}  @override
  Widget build(BuildContext context) {
    return buildPage(
      providers: [
        $providerEntries
      ],
      listeners: [$listenersLiteral],
      builder: (context) {
        $bodyReturn
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

    final needsFailureX = classBody.contains('localizeAny(');
    final needsAppUi =
        classBody.contains('showSuccessSnackbar(') ||
        classBody.contains('showErrorSnackbar(') ||
        classBody.contains('AppLoading') ||
        classBody.contains('AppErrorFeedback') ||
        classBody.contains('AppGap.');

    final imports = <String>[
      if (needsAppUi) "import 'package:app_ui/app_ui.dart';",
      "import 'package:flutter/material.dart';",
      "import 'package:flutter_bloc/flutter_bloc.dart';",
      "import 'package:$module/$module.dart';",
      '',
      "import '$diImport';",
      if (needsFailureX) "import '$failureImport';",
      "import '$mixinImport';",
    ];

    return '''${imports.join('\n')}

$classBody''';
  }

  String _buildEmptyScaffoldPageCode({
    required String appLibPath,
    required String pageClass,
    required String pageDir,
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
        return const Scaffold(
          appBar: AppBar(
            title: const Text('$pageClass'),
            actions: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  // slice actions go here
                ],
              ),
            ],
          ),
          body: const SizedBox.shrink(),
        );
      },
    );
  }
}
''';
  }

  String? _injectIntoExistingPage({
    required String source,
    required String appLibPath,
    required String module,
    required String feature,
    required String slice,
    required String pageDir,
    required List<_LogicTarget> logicTargets,
  }) {
    var next = source;

    final diImport = p
        .relative(p.join(appLibPath, 'core', 'di', 'di.dart'), from: pageDir)
        .replaceAll('\\', '/');
    final failureImport = p
        .relative(
          p.join(appLibPath, 'core', 'extensions', 'failure_x.dart'),
          from: pageDir,
        )
        .replaceAll('\\', '/');

    next = _insertImport(
      next,
      "import 'package:flutter_bloc/flutter_bloc.dart';",
    );
    next = _insertImport(next, "import 'package:$module/$module.dart';");
    next = _insertImport(next, "import '$diImport';");

    final listenerTargets = logicTargets
        .where(
          (logic) =>
              logic.stateInfo.hasVariant('success') ||
              logic.stateInfo.hasVariant('failure'),
        )
        .toList();

    if (listenerTargets.isNotEmpty) {
      next = _insertImport(next, "import 'package:app_ui/app_ui.dart';");
    }

    final needsFailureImport = listenerTargets.any(
      (logic) => logic.stateInfo.hasVariant('failure'),
    );
    if (needsFailureImport) {
      next = _insertImport(next, "import '$failureImport';");
    }

    final providerMap = <String, String>{
      for (final logic in logicTargets)
        'BlocProvider<${logic.logicClass}>':
            'BlocProvider<${logic.logicClass}>(create: (_) => sl()${logic.bootstrapMethod == null ? '' : '..${logic.bootstrapMethod!}()'}),',
    };

    final listenersMap = <String, String>{
      for (final logic in listenerTargets)
        'BlocListener<${logic.logicClass}, ${logic.stateClass}>':
            'BlocListener<${logic.logicClass}, ${logic.stateClass}>(listener: _${logic.logicClass.camelCase}Listener),',
    };

    final updatedProviders = _upsertBuildPageListEntries(
      source: next,
      label: 'providers',
      signatureToEntry: providerMap,
    );
    if (updatedProviders == null) return null;
    next = updatedProviders;

    final updatedListeners = _upsertBuildPageListEntries(
      source: next,
      label: 'listeners',
      signatureToEntry: listenersMap,
    );
    if (updatedListeners == null) return null;
    next = updatedListeners;

    final methodsToInsert = <String>[];
    for (final logic in listenerTargets) {
      final signature = 'void _${logic.logicClass.camelCase}Listener(';
      if (next.contains(signature)) continue;

      methodsToInsert.add(
        _buildListenerMethod(
          module: module,
          feature: feature,
          slice: slice,
          logic: logic,
        ),
      );
    }

    if (methodsToInsert.isNotEmpty) {
      final overrideMatch = RegExp(r'\n\s*@override').firstMatch(next);
      if (overrideMatch == null) return null;

      final insertBlock = '\n\n${methodsToInsert.join('\n\n')}\n';
      next = next.replaceRange(
        overrideMatch.start,
        overrideMatch.start,
        insertBlock,
      );
    }

    return next;
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

  bool _viewNeedsPrimaryContent(_ViewInfo? viewInfo) {
    if (viewInfo == null) return false;
    return viewInfo.requiredFields.any(
      (field) => field == 'content' || field == 'form',
    );
  }

  bool _contentWantsOnItemTap(_ClassInfo? contentClass) {
    if (contentClass == null) return false;
    return contentClass.requiredFields.contains('onItemTap');
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

  String _buildPrimaryContentMethod({
    required _LogicTarget logic,
    required _UiComponents uiComponents,
    required _LoadedPayload? loadedPayload,
    required bool hasPrimaryAction,
    required String primaryActionMethodName,
    required String? onItemTapMethodName,
  }) {
    final loadingExpr = uiComponents.skeleton == null
        ? 'const AppLoading()'
        : 'const ${uiComponents.skeleton!.className}()';

    final branches = <String>['orElse: () => $loadingExpr,'];

    if (logic.stateInfo.hasVariant('loading')) {
      branches.add('loading: () => $loadingExpr,');
    }

    if (logic.stateInfo.hasVariant('failure')) {
      final retryCallback = hasPrimaryAction
          ? '() => $primaryActionMethodName(context)'
          : '() {}';

      if (uiComponents.errorFeedback != null) {
        final classInfo = uiComponents.errorFeedback!;
        final args = classInfo.requiredFields
            .map((field) {
              if (field == 'message') {
                return 'message: failure.localizeAny(context),';
              }
              if (field == 'onRetry') {
                return 'onRetry: $retryCallback,';
              }
              return '$field: ${_defaultValueForType(classInfo.fieldTypes[field])},';
            })
            .join('\n                ');

        branches.add('''failure: (failure) => ${classInfo.className}(
                $args
              ),''');
      } else {
        branches.add('''failure: (failure) => AppErrorFeedback(
                title: 'Error',
                message: failure.localizeAny(context),
                onRetry: $retryCallback,
              ),''');
      }
    }

    if (loadedPayload != null) {
      final successExpr = _buildSuccessExpression(
        uiComponents: uiComponents,
        loadedPayload: loadedPayload,
        hasPrimaryAction: hasPrimaryAction,
        primaryActionMethodName: primaryActionMethodName,
        onItemTapMethodName: onItemTapMethodName,
      );

      branches.add(
        '${loadedPayload.branchName}: (${loadedPayload.paramName}) => $successExpr,',
      );
    } else if (logic.stateInfo.hasVariant('success')) {
      final successVariant = logic.stateInfo.variant('success');
      if (successVariant != null && successVariant.firstParamName == null) {
        final successExpr = _buildSuccessExpression(
          uiComponents: uiComponents,
          loadedPayload: null,
          hasPrimaryAction: hasPrimaryAction,
          primaryActionMethodName: primaryActionMethodName,
          onItemTapMethodName: onItemTapMethodName,
        );

        branches.add('success: () => $successExpr,');
      }
    }

    return '''  Widget _buildPrimaryContent(BuildContext context) {
    return BlocBuilder<${logic.logicClass}, ${logic.stateClass}>(
      builder: (_, state) => state.maybeWhen(
        ${branches.join('\n        ')}
      ),
    );
  }''';
  }

  String _buildSuccessExpression({
    required _UiComponents uiComponents,
    required _LoadedPayload? loadedPayload,
    required bool hasPrimaryAction,
    required String primaryActionMethodName,
    required String? onItemTapMethodName,
  }) {
    final contentClass = uiComponents.content;
    if (contentClass == null) {
      return 'const SizedBox.shrink()';
    }

    final dataName = loadedPayload?.paramName;
    final contentExpr = _buildClassInstantiation(
      classInfo: contentClass,
      dataName: dataName,
      dataType: loadedPayload?.paramType,
      hasPrimaryAction: hasPrimaryAction,
      primaryActionMethodName: primaryActionMethodName,
      onItemTapMethodName: onItemTapMethodName,
    );

    if (loadedPayload != null &&
        loadedPayload.isList &&
        uiComponents.emptyFeedback != null) {
      final emptyExpr = _buildClassInstantiation(
        classInfo: uiComponents.emptyFeedback!,
        dataName: null,
        dataType: null,
        hasPrimaryAction: hasPrimaryAction,
        primaryActionMethodName: primaryActionMethodName,
        onItemTapMethodName: null,
      );

      return '${loadedPayload.paramName}.isEmpty ? $emptyExpr : $contentExpr';
    }

    return contentExpr;
  }

  String _buildClassInstantiation({
    required _ClassInfo classInfo,
    required String? dataName,
    required String? dataType,
    required bool hasPrimaryAction,
    required String primaryActionMethodName,
    required String? onItemTapMethodName,
  }) {
    if (classInfo.requiredFields.isEmpty) {
      return '${classInfo.className}()';
    }

    final args = classInfo.requiredFields
        .map((field) {
          final type = classInfo.fieldTypes[field];

          if (dataName != null &&
              _shouldUseLoadedData(
                field: field,
                type: type,
                dataName: dataName,
                dataType: dataType,
              )) {
            return '$field: $dataName,';
          }

          if (field == 'onItemTap' && onItemTapMethodName != null) {
            return '$field: (item) => $onItemTapMethodName(context, item),';
          }

          if (_isCallbackField(type: type, field: field)) {
            final returnsFuture = _returnsFutureCallback(type);
            if (_acceptsArgument(type)) {
              if (hasPrimaryAction) {
                return returnsFuture
                    ? '$field: (_) async { $primaryActionMethodName(context); },'
                    : '$field: (_) => $primaryActionMethodName(context),';
              }
              return returnsFuture
                  ? '$field: (_) async {},'
                  : '$field: (_) {},';
            }
            if (hasPrimaryAction) {
              return returnsFuture
                  ? '$field: () async { $primaryActionMethodName(context); },'
                  : '$field: () => $primaryActionMethodName(context),';
            }
            return returnsFuture ? '$field: () async {},' : '$field: () {},';
          }

          return '$field: ${_defaultValueForType(type)},';
        })
        .join('\n                  ');

    return '''${classInfo.className}(
                  $args
                )''';
  }

  bool _isDataField(String field) {
    const names = <String>{'data', 'list', 'items', 'item', 'notes'};
    return names.contains(field);
  }

  bool _shouldUseLoadedData({
    required String field,
    required String? type,
    required String dataName,
    required String? dataType,
  }) {
    if (_isDataField(field) || field == dataName) {
      return true;
    }

    if (type == null || type.trim().isEmpty) {
      return false;
    }

    if (_isCallbackField(type: type, field: field) || _isWidgetType(type)) {
      return false;
    }

    final normalizedFieldType = _stripNullableType(_normalizeType(type));
    if (_isPrimitiveType(normalizedFieldType) ||
        _isFrameworkValueType(normalizedFieldType)) {
      return false;
    }

    if (dataType == null || dataType.trim().isEmpty) {
      return false;
    }

    final normalizedDataType = _stripNullableType(_normalizeType(dataType));

    if (normalizedFieldType == normalizedDataType) {
      return true;
    }

    final fieldListItem = _extractListItemType(normalizedFieldType);
    final dataListItem = _extractListItemType(normalizedDataType);
    if (fieldListItem != null &&
        dataListItem != null &&
        _stripNullableType(fieldListItem) == _stripNullableType(dataListItem)) {
      return true;
    }

    // If both sides are non-primitive domain-ish types, prefer binding loaded data
    // over injecting a widget fallback into a required entity/data field.
    if (_looksLikeDomainType(normalizedFieldType) &&
        _looksLikeDomainType(normalizedDataType)) {
      return true;
    }

    return false;
  }

  String _normalizeType(String value) {
    return value.replaceAll(' ', '');
  }

  String _stripNullableType(String value) {
    return value.endsWith('?') ? value.substring(0, value.length - 1) : value;
  }

  String? _extractListItemType(String value) {
    final match = RegExp(r'^List<(.+)>\??$').firstMatch(value);
    return match?.group(1);
  }

  bool _isPrimitiveType(String value) {
    const primitives = <String>{
      'String',
      'int',
      'double',
      'num',
      'bool',
      'dynamic',
      'Object',
      'Map',
      'Set',
    };
    if (primitives.contains(value)) {
      return true;
    }
    if (value.startsWith('Map<') || value.startsWith('Set<')) {
      return true;
    }
    return false;
  }

  bool _isFrameworkValueType(String value) {
    if (value.startsWith('ValueNotifier<')) return true;
    if (value.endsWith('Controller')) return true;
    if (value.endsWith('Notifier')) return true;

    const frameworkTypes = <String>{
      'BuildContext',
      'Key',
      'GlobalKey',
      'FocusNode',
      'Color',
      'EdgeInsets',
      'TextStyle',
      'IconData',
      'Duration',
      'DateTime',
      'TimeOfDay',
      'ThemeData',
    };

    return frameworkTypes.contains(value);
  }

  bool _looksLikeDomainType(String value) {
    if (_isPrimitiveType(value) || _isFrameworkValueType(value)) {
      return false;
    }
    if (_isWidgetType(value)) {
      return false;
    }
    return true;
  }

  bool _isWidgetType(String? type) {
    if (type == null || type.trim().isEmpty) return false;
    final normalized = _normalizeType(type);
    return normalized.contains('Widget') ||
        normalized.contains('PreferredSizeWidget');
  }

  bool _isCallbackField({required String? type, required String field}) {
    if (field.startsWith('on')) return true;
    if (type == null) return false;
    return type.contains('VoidCallback') || type.contains('Function(');
  }

  bool _acceptsArgument(String? type) {
    if (type == null) return true;
    if (type.contains('VoidCallback')) return false;
    return type.contains('Function(') && !type.contains('Function()');
  }

  bool _returnsFutureCallback(String? type) {
    if (type == null) return false;
    final normalized = type.replaceAll(' ', '');
    if (normalized.startsWith('Future<')) return true;
    return normalized.contains('Future<') && normalized.contains('Function(');
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

  String _buildLoadingOverlayMethod(_LogicTarget primaryLogic) {
    return '''  Widget _buildLoadingOverlay(
    BuildContext context,
    ${primaryLogic.stateClass} state,
  ) {
    return state.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      loading: () => const AppLoadingOverlay(),
    );
  }''';
  }

  String _buildViewReturn({
    required _ViewInfo? viewInfo,
    required bool hasPrimaryAction,
    required String primaryActionMethodName,
  }) {
    if (viewInfo == null) {
      return 'return const SizedBox.shrink();';
    }

    if (viewInfo.requiredFields.isEmpty) {
      return 'return ${viewInfo.className}();';
    }

    final args = viewInfo.requiredFields
        .map((field) {
          final type = viewInfo.fieldTypes[field];

          if (field == 'content' || field == 'form') {
            return '$field: _buildPrimaryContent(context),';
          }

          if (_isCallbackField(type: type, field: field)) {
            final returnsFuture = _returnsFutureCallback(type);
            if (hasPrimaryAction) {
              return returnsFuture
                  ? '$field: () async { $primaryActionMethodName(context); },'
                  : '$field: () => $primaryActionMethodName(context),';
            }
            return returnsFuture ? '$field: () async {},' : '$field: () {},';
          }

          return '$field: ${_defaultValueForType(type)},';
        })
        .join('\n          ');

    return '''return ${viewInfo.className}(
          $args
        );''';
  }

  String _buildFallbackReturn({
    required String feature,
    required String slice,
    required _LogicTarget primaryLogic,
    required bool hasPrimaryAction,
    required String primaryActionMethodName,
    required bool hasLoadingOverlay,
  }) {
    final title = '${feature.pascalCase} ${slice.pascalCase}';
    final buffer = StringBuffer()
      ..writeln('return Stack(')
      ..writeln('          fit: StackFit.expand,')
      ..writeln('          children: [')
      ..writeln('            Scaffold(')
      ..writeln('              appBar: AppBar(')
      ..writeln("                title: const Text('$title'),");

    if (hasPrimaryAction) {
      buffer
        ..writeln('                actions: [')
        ..writeln(
          '                  BlocBuilder<${primaryLogic.logicClass}, ${primaryLogic.stateClass}>(',
        )
        ..writeln('                    builder: (_, state) => state.maybeWhen(')
        ..writeln('                      orElse: () => IconButton(')
        ..writeln(
          '                        onPressed: () => $primaryActionMethodName(context),',
        )
        ..writeln('                        icon: const Icon(Icons.refresh),')
        ..writeln('                      ),')
        ..writeln(
          '                      loading: () => const AppLoadingMini(),',
        )
        ..writeln('                    ),')
        ..writeln('                  ),')
        ..writeln('                  AppGap.xs,')
        ..writeln('                ],');
    }

    buffer
      ..writeln('              ),')
      ..writeln('              body: const Center(')
      ..writeln("                child: Text('$title Page'),")
      ..writeln('              ),')
      ..writeln('            ),');

    if (hasLoadingOverlay) {
      buffer
        ..writeln(
          '            BlocBuilder<${primaryLogic.logicClass}, ${primaryLogic.stateClass}>(',
        )
        ..writeln(
          '              builder: (_, state) => _buildLoadingOverlay(context, state),',
        )
        ..writeln('            ),');
    }

    buffer
      ..writeln('          ],')
      ..write('        );');

    return buffer.toString();
  }

  Future<void> _syncRouteFile({
    required File routeFile,
    required String pagePath,
    required String pageClass,
    required String targetPage,
    required ComposePageMode pageMode,
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

    if (pageMode == ComposePageMode.main || pageMode == ComposePageMode.form) {
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
  final String? bootstrapMethod;
  final List<_MethodCandidate> methods;
  final _StateInfo stateInfo;

  const _LogicTarget({
    required this.logicClass,
    required this.stateClass,
    required this.bootstrapMethod,
    required this.methods,
    required this.stateInfo,
  });
}

class _MethodCandidate {
  final String name;
  final String rawParams;
  final bool hasRequiredParam;
  final bool canInvokeWithoutArgs;
  final bool isValid;

  const _MethodCandidate({
    required this.name,
    required this.rawParams,
    required this.hasRequiredParam,
    required this.canInvokeWithoutArgs,
  }) : isValid = true;

  const _MethodCandidate.none()
    : name = '',
      rawParams = '',
      hasRequiredParam = false,
      canInvokeWithoutArgs = false,
      isValid = false;
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

class _LoadedPayload {
  final String branchName;
  final String paramName;
  final String paramType;
  final bool isList;
  final String? itemType;

  const _LoadedPayload({
    required this.branchName,
    required this.paramName,
    required this.paramType,
    required this.isList,
    required this.itemType,
  });
}

typedef _ViewInfo = _ClassInfo;

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

class _FormArtifacts {
  final String formCubitClass;
  final String formCubitMethod;
  final String formStateClass;
  final String formWidgetClass;
  final String formParamType;

  const _FormArtifacts({
    required this.formCubitClass,
    required this.formCubitMethod,
    required this.formStateClass,
    required this.formWidgetClass,
    required this.formParamType,
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
