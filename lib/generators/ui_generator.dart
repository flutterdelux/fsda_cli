import 'dart:convert';
import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../enums/ui_code.dart';
import '../generated/bricks/ui_action_bundle.dart';
import '../generated/bricks/ui_dialog_bundle.dart';
import '../generated/bricks/ui_form_bundle.dart';
import '../generated/bricks/ui_form_dialog_bundle.dart';
import '../generated/bricks/ui_lsh_bundle.dart';
import '../generated/bricks/ui_lsv_bundle.dart';
import '../generated/bricks/ui_main_bundle.dart';
import '../generated/bricks/ui_pag_bundle.dart';
import '../generated/bricks/ui_pmi_bundle.dart';
import '../generated/bricks/ui_sec_bundle.dart';
import '../services/memory_generator_target.dart';
import '../services/operation_report_service.dart';
import 'base_generator.dart';

class UiGenerator
    extends
        BaseGenerator<
          void,
          ({
            String slice,
            String feature,
            String module,
            UiCode ui,
            String operationLabel,
            List<String> formFields,
            bool strict,
          })
        > {
  UiGenerator({
    required super.logger,
    required super.fileService,
    required super.hookService,
  });

  @override
  Future<void> generate(
    ({
      String slice,
      String feature,
      String module,
      UiCode ui,
      String operationLabel,
      List<String> formFields,
      bool strict,
    })
    args,
  ) async {
    final sliceName = args.slice;
    final featureName = args.feature;
    final moduleName = args.module;
    final uiCode = args.ui;
    final operationLabel = args.operationLabel;
    final formFields = args.formFields;
    final strict = args.strict;

    if (fileService == null) {
      logger.error('FileService is required for weaving ui template.');
      return;
    }

    logger.info(
      'Weaving UI "$sliceName" -> "$moduleName/$featureName" as ${uiCode.description} template...',
    );

    final progress = logger.progress('Baking UI "$sliceName" in memory...');
    final memoryGeneratorTarget = MemoryGeneratorTarget();
    final report = OperationReportService();

    try {
      final generator = await MasonGenerator.fromBundle(
        _resolveUiBundle(uiCode),
      );
      await generator.generate(
        memoryGeneratorTarget,
        vars: <String, dynamic>{
          'slice': sliceName,
          'feature': featureName,
          'module': moduleName,
          'ui': uiCode.code,
        },
      );

      String? uiYamlRaw;
      final standaloneFilesToSave = <String, List<int>>{};

      for (final entry in memoryGeneratorTarget.files.entries) {
        final filePath = entry.key;
        final fileBytes = entry.value;
        final fileName = p.basename(filePath);

        if (fileName == 'ui.yaml') {
          uiYamlRaw = utf8.decode(fileBytes);
          continue;
        }

        standaloneFilesToSave[filePath] = fileBytes;
      }

      if (uiYamlRaw == null) {
        throw Exception('ui.yaml not found in generated UI files.');
      }

      if ((uiCode == UiCode.form || uiCode == UiCode.formDialog) &&
          formFields.isNotEmpty) {
        final dynamicFormArtifacts = await _rewriteFormArtifactsByFields(
          moduleName: moduleName,
          featureName: featureName,
          sliceName: sliceName,
          fields: formFields,
          dialogMode: uiCode == UiCode.formDialog,
          files: standaloneFilesToSave,
        );
        standaloneFilesToSave
          ..clear()
          ..addAll(dynamicFormArtifacts.files);
        uiYamlRaw = dynamicFormArtifacts.uiYamlRaw;
      }

      final featureRoot = p.join(
        Directory.current.path,
        'modules',
        moduleName,
        'lib',
        'src',
        'features',
        featureName,
      );

      progress.update('Writing standalone UI files to disk...');
      final templateWriteResult = await fileService!.generateTemplate(
        path: featureRoot,
        files: standaloneFilesToSave,
        failOnExisting: strict,
      );

      report.addCreatedTemplateFiles(
        targetRoot: featureRoot,
        relativeFiles: templateWriteResult.writtenFiles,
      );
      report.addSkippedTemplateFiles(
        targetRoot: featureRoot,
        relativeFiles: templateWriteResult.skippedFiles,
      );

      if (templateWriteResult.skippedCount > 0) {
        logger.info(
          'Skipped ${templateWriteResult.skippedCount} existing UI file(s) to prevent overwrite.',
        );

        if (strict || templateWriteResult.abortedDueToExisting) {
          logger.error(
            'Strict mode: generation aborted because some UI files already exist.',
          );
          report.logSummary(logger, operationLabel: operationLabel);
          exitCode = 1;
          return;
        }
      }

      progress.update('Parsing UI manifest...');
      final doc = loadYaml(uiYamlRaw) as YamlMap;
      final exportMap = doc['export'] as YamlMap?;
      final arbEntries = _readArbEntries(doc['arb']);
      final postHooks = List<String>.from(
        doc['post_hooks'] as List? ?? const [],
      );

      if (exportMap != null && exportMap.isNotEmpty) {
        progress.update('Registering UI exports to feature barrel...');
        final featureBarrelPath = p.join(
          featureRoot,
          '${featureName}_feature.dart',
        );
        final barrelChanged = await _updateFeatureBarrelStructured(
          path: featureBarrelPath,
          exportMap: exportMap,
        );
        if (barrelChanged) {
          report.addUpdated(featureBarrelPath);
        }

        if (uiCode == UiCode.form || uiCode == UiCode.formDialog) {
          final removedPrivateFieldExports = await _removePrivateFieldExports(
            path: featureBarrelPath,
            featureName: featureName,
          );
          if (removedPrivateFieldExports) {
            report.addUpdated(featureBarrelPath);
          }
        }
      }

      if (arbEntries.isNotEmpty) {
        progress.update('Injecting ARB entries to all .arb files...');
        final touchedArbFiles = await _injectArbEntries(
          moduleName: moduleName,
          entries: arbEntries,
        );

        for (final arbFilePath in touchedArbFiles) {
          report.addInjected(arbFilePath);
        }
      }

      if (postHooks.isNotEmpty) {
        progress.update('Running post hooks...');
        await hookService!.runHook(
          hooks: postHooks,
          workingDirectory: p.join(
            Directory.current.path,
            'modules',
            moduleName,
          ),
        );
      }

      progress.complete(
        'UI "$sliceName" successfully woven into "$featureName" feature! 🎨',
      );
      report.logSummary(logger, operationLabel: operationLabel);
    } catch (e) {
      progress.fail('Failed to weave UI template: $e');
      exitCode = 1;
    }
  }

  Future<bool> _updateFeatureBarrelStructured({
    required String path,
    required YamlMap exportMap,
  }) async {
    final file = File(path);
    if (!await file.exists()) return false;

    final content = await file.readAsString();
    final lines = content.split('\n');
    final existingStatements = lines.map((line) => line.trim()).toSet();
    var changed = false;

    for (final layer in ['data', 'domain', 'logic', 'ui']) {
      final rawExports = exportMap[layer];
      final statements = _readExportStatements(rawExports);
      if (statements.isEmpty) continue;

      final validExports = statements
          .where((stmt) => !existingStatements.contains(stmt))
          .toList();

      if (validExports.isEmpty) continue;

      final markerIndex = lines.indexWhere((l) => l.trim() == '// $layer');

      if (markerIndex != -1) {
        lines.insertAll(markerIndex + 1, validExports);
      } else {
        lines.addAll(validExports);
      }

      existingStatements.addAll(validExports);
      changed = true;
    }

    if (!changed) {
      return false;
    }

    await file.writeAsString('${lines.join('\n')}\n');
    return true;
  }

  Future<bool> _removePrivateFieldExports({
    required String path,
    required String featureName,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      return false;
    }

    final before = await file.readAsString();
    final beforeLines = before.split('\n');
    final prefix = "export 'ui/shared/widgets/${featureName.snakeCase}_";

    final filtered = beforeLines
        .where((line) {
          final normalized = line.trim();
          if (!normalized.startsWith(prefix)) {
            return true;
          }
          return !normalized.endsWith("_field.dart';");
        })
        .toList(growable: false);

    final after = '${filtered.join('\n')}\n';
    final normalizedBefore = '${before.trimRight()}\n';
    if (after == normalizedBefore) {
      return false;
    }

    await file.writeAsString(after);
    return true;
  }

  List<String> _readExportStatements(dynamic rawExports) {
    if (rawExports == null) {
      return const [];
    }

    if (rawExports is String) {
      return rawExports
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    }

    throw const FormatException(
      'Invalid export format in ui.yaml. Expected string or list.',
    );
  }

  Map<String, dynamic> _readArbEntries(dynamic rawArb) {
    if (rawArb == null) {
      return const {};
    }

    if (rawArb is String) {
      return _parseArbFragment(rawArb);
    }

    if (rawArb is YamlMap || rawArb is Map) {
      final map = <String, dynamic>{};
      final entries = rawArb is YamlMap
          ? rawArb.entries
          : (rawArb as Map<dynamic, dynamic>).entries;
      for (final entry in entries) {
        map[entry.key.toString()] = entry.value;
      }
      return map;
    }

    throw const FormatException(
      'Invalid arb format in ui.yaml. Expected string block or map.',
    );
  }

  Map<String, dynamic> _parseArbFragment(String rawArb) {
    final trimmed = rawArb.trim();
    if (trimmed.isEmpty) {
      return const {};
    }

    final fragment = trimmed.replaceFirst(RegExp(r',\s*$'), '');
    final candidate = '{\n$fragment\n}';

    try {
      final decoded = jsonDecode(candidate);
      if (decoded is! Map) {
        throw const FormatException('ARB fragment must decode to JSON object.');
      }
      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      throw FormatException(
        'Invalid arb block in ui.yaml. Expected JSON key/value fragment, e.g. ""key": "value"". Error: $e',
      );
    }
  }

  Future<Set<String>> _injectArbEntries({
    required String moduleName,
    required Map<String, dynamic> entries,
  }) async {
    final touchedPaths = <String>{};
    final l10nDir = Directory(
      p.join(Directory.current.path, 'modules', moduleName, 'lib', 'l10n'),
    );

    if (!await l10nDir.exists()) {
      logger.info(
        'L10n directory not found in module "$moduleName", skipping arb injection.',
      );
      return touchedPaths;
    }

    final arbFiles = l10nDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.arb'))
        .toList();

    if (arbFiles.isEmpty) {
      logger.info(
        'No .arb files found in module "$moduleName", skipping arb injection.',
      );
      return touchedPaths;
    }

    const encoder = JsonEncoder.withIndent('  ');
    var touchedFiles = 0;
    var totalAdded = 0;

    for (final arbFile in arbFiles) {
      final rawJson = await arbFile.readAsString();
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) {
        throw FormatException(
          'Invalid ARB format at ${arbFile.path}: expected JSON object root.',
        );
      }

      final arbMap = Map<String, dynamic>.from(decoded);
      var added = 0;

      for (final entry in entries.entries) {
        if (arbMap.containsKey(entry.key)) {
          continue;
        }

        arbMap[entry.key] = entry.value;
        added += 1;
      }

      if (added == 0) {
        continue;
      }

      touchedFiles += 1;
      totalAdded += added;
      await arbFile.writeAsString('${encoder.convert(arbMap)}\n');
      touchedPaths.add(arbFile.path);
      final fileName = p.basename(arbFile.path);
      logger.success(
        'Injected $added ARB entr${added == 1 ? 'y' : 'ies'} into $fileName',
      );
    }

    if (totalAdded == 0) {
      logger.info(
        'ARB entries already exist in all module .arb files for "$moduleName".',
      );
      return touchedPaths;
    }

    logger.success(
      'Injected total $totalAdded ARB entr${totalAdded == 1 ? 'y' : 'ies'} across $touchedFiles .arb file${touchedFiles == 1 ? '' : 's'}.',
    );
    return touchedPaths;
  }

  Future<({Map<String, List<int>> files, String uiYamlRaw})>
  _rewriteFormArtifactsByFields({
    required String moduleName,
    required String featureName,
    required String sliceName,
    required List<String> fields,
    required bool dialogMode,
    required Map<String, List<int>> files,
  }) async {
    final formPath = files.keys.firstWhere(
      (path) =>
          path.startsWith('ui/$sliceName/widgets/') &&
          path.endsWith('_form.dart'),
      orElse: () => '',
    );
    if (formPath.isEmpty) {
      throw const FormatException(
        'Unable to resolve generated form widget file.',
      );
    }

    final formParamFields = await _readFormParamFields(
      moduleName: moduleName,
      featureName: featureName,
      sliceName: sliceName,
    );
    final canResolveParamConstructor = formParamFields.isNotEmpty;

    final nextFiles = Map<String, List<int>>.from(files);
    nextFiles.removeWhere(
      (path, _) =>
          path.startsWith('ui/shared/widgets/') && path.endsWith('_field.dart'),
    );

    for (final field in fields) {
      final fieldPath =
          'ui/shared/widgets/${featureName.snakeCase}_${field.snakeCase}_field.dart';
      nextFiles[fieldPath] = utf8.encode(
        _buildDynamicFormFieldWidget(
          moduleName: moduleName,
          featureName: featureName,
          fieldName: field,
        ),
      );
    }

    nextFiles[formPath] = utf8.encode(
      _buildDynamicFormWidget(
        moduleName: moduleName,
        featureName: featureName,
        sliceName: sliceName,
        fields: fields,
        paramFields: formParamFields,
        canResolveParamConstructor: canResolveParamConstructor,
      ),
    );

    final uiYamlRaw = _buildDynamicFormYaml(
      featureName: featureName,
      sliceName: sliceName,
      fields: fields,
      dialogMode: dialogMode,
    );

    return (files: nextFiles, uiYamlRaw: uiYamlRaw);
  }

  Future<List<({String name, String type})>> _readFormParamFields({
    required String moduleName,
    required String featureName,
    required String sliceName,
  }) async {
    final paramPath = p.join(
      Directory.current.path,
      'modules',
      moduleName,
      'lib',
      'src',
      'features',
      featureName,
      'domain',
      'params',
      '${featureName.snakeCase}_${sliceName.snakeCase}_param.dart',
    );
    final paramFile = File(paramPath);
    if (!await paramFile.exists()) {
      return const <({String name, String type})>[];
    }

    final source = await paramFile.readAsString();
    final expectedClassName =
        '${featureName.pascalCase}${sliceName.pascalCase}Param';
    final constructorMatch =
        RegExp(
          r'const\s+factory\s+' +
              RegExp.escape(expectedClassName) +
              r'\s*\(([\s\S]*?)\)\s*=\s*_',
          dotAll: true,
        ).firstMatch(source) ??
        RegExp(
          r'const\s+factory\s+[A-Za-z_]\w*Param\s*\(([\s\S]*?)\)\s*=\s*_',
          dotAll: true,
        ).firstMatch(source);

    if (constructorMatch == null) {
      return const <({String name, String type})>[];
    }

    final constructorParams = constructorMatch.group(1) ?? '';
    final fields = <({String name, String type})>[];

    for (final paramMatch in RegExp(
      r'(?:required\s+)?([A-Za-z_][A-Za-z0-9_<>,? ]*)\s+([A-Za-z_]\w*)\s*(?:,|$|[}\]])',
      multiLine: true,
    ).allMatches(constructorParams)) {
      final fieldType = paramMatch.group(1)?.trim();
      final fieldName = paramMatch.group(2)?.trim();
      if (fieldType == null || fieldType.isEmpty) {
        continue;
      }
      if (fieldName == null || fieldName.isEmpty) {
        continue;
      }
      fields.add((name: fieldName, type: fieldType));
    }

    return fields;
  }

  String _buildDynamicFormFieldWidget({
    required String moduleName,
    required String featureName,
    required String fieldName,
  }) {
    final featurePascal = featureName.pascalCase;
    final fieldPascal = fieldName.pascalCase;
    final localizationKey = '${featureName.camelCase}Field${fieldPascal}';

    return '''import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';

class ${featurePascal}${fieldPascal}Field extends StatelessWidget {
  final TextEditingController controller;
  const ${featurePascal}${fieldPascal}Field({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = ${moduleName.pascalCase}Localizations.of(context)!;
    return AppSection(
      header: AppSectionHeader(titleText: l10n.${localizationKey}Label),
      child: AppTextField(
        controller: controller,
        hintText: l10n.${localizationKey}Hint,
      ),
    );
  }
}
''';
  }

  String _buildDynamicFormWidget({
    required String moduleName,
    required String featureName,
    required String sliceName,
    required List<String> fields,
    required List<({String name, String type})> paramFields,
    required bool canResolveParamConstructor,
  }) {
    final featureSnake = featureName.snakeCase;
    final sliceSnake = sliceName.snakeCase;
    final featurePascal = featureName.pascalCase;
    final slicePascal = sliceName.pascalCase;
    final modulePascal = moduleName.pascalCase;
    final featureCamel = featureName.camelCase;

    final fieldImports = fields
        .map(
          (field) =>
              "import '../../shared/widgets/${featureSnake}_${field.snakeCase}_field.dart';",
        )
        .join('\n');

    final controllerDeclarations = fields
        .map(
          (field) =>
              '  late final TextEditingController _${field.camelCase}Controller;',
        )
        .join('\n');

    final inputValidation = StringBuffer();
    final inputByField = <String, String>{};
    final fieldByKey = <String, String>{};

    for (final field in fields) {
      final fieldCamel = field.camelCase;
      final fieldPascal = field.pascalCase;
      final inputName = '${fieldCamel}Input';

      inputByField[fieldCamel] = inputName;
      fieldByKey[fieldCamel.toLowerCase()] = field;
      fieldByKey[field.snakeCase.toLowerCase()] = field;

      inputValidation.writeln(
        '    final $inputName = _${fieldCamel}Controller.text;',
      );
      inputValidation.writeln('    if ($inputName.isEmpty) {');
      inputValidation.writeln(
        '      widget.onListen(context, null, l10n.${featureCamel}Field${fieldPascal}InvalidEmpty);',
      );
      inputValidation.writeln('      return;');
      inputValidation.writeln('    }');
      inputValidation.writeln();
    }

    final conversionStatements = StringBuffer();
    final paramAssignments = <String>[];

    for (final paramField in paramFields) {
      final paramName = paramField.name;
      final paramType = paramField.type;

      final matchedField =
          fieldByKey[paramName.toLowerCase()] ??
          fieldByKey[paramName.snakeCase.toLowerCase()] ??
          fieldByKey[paramName.camelCase.toLowerCase()];

      late final String assignmentExpression;
      if (matchedField == null) {
        assignmentExpression = _defaultExpressionForParamType(paramType);
      } else {
        final fieldPascal = matchedField.pascalCase;
        final inputName = inputByField[matchedField.camelCase]!;
        assignmentExpression = _buildAssignmentExpressionForParamType(
          paramType: paramType,
          inputName: inputName,
          variableStem: '${matchedField.camelCase}${paramName.pascalCase}',
          conversionStatements: conversionStatements,
        );

        final normalizedType = _normalizeParamType(paramType);
        if (normalizedType == 'int' ||
            normalizedType == 'double' ||
            normalizedType == 'bool') {
          if (!_isNullableParamType(paramType)) {
            conversionStatements.writeln(
              '    if ($assignmentExpression == null) {',
            );
            conversionStatements.writeln(
              '      widget.onListen(context, null, l10n.${featureCamel}Field${fieldPascal}InvalidEmpty);',
            );
            conversionStatements.writeln('      return;');
            conversionStatements.writeln('    }');
            conversionStatements.writeln();
          }
        }
      }

      paramAssignments.add('      $paramName: $assignmentExpression,');
    }

    final initControllers = fields
        .map(
          (field) =>
              '    _${field.camelCase}Controller = TextEditingController()..addListener(_onInputChanged);',
        )
        .join('\n');

    final disposeControllers = fields
        .map(
          (field) =>
              '    _${field.camelCase}Controller\n      ..removeListener(_onInputChanged)\n      ..dispose();',
        )
        .join('\n');

    final fieldWidgets = <String>[];
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      final widgetClass = '$featurePascal${field.pascalCase}Field';
      fieldWidgets.add(
        '        $widgetClass(controller: _${field.camelCase}Controller),',
      );
      if (i != fields.length - 1) {
        fieldWidgets.add('        AppGap.lg,');
      }
    }

    return '''import 'package:app_l10n/app_l10n.dart';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../../../domain/params/${featureSnake}_${sliceSnake}_param.dart';
$fieldImports

import '../../../../../generated/${moduleName.snakeCase}_localizations.dart';

class ${featurePascal}${slicePascal}Form extends StatefulWidget {
  final void Function(
    BuildContext context,
    ${featurePascal}${slicePascal}Param? param,
    String? invalidMessage,
  )
  onListen;
  const ${featurePascal}${slicePascal}Form({super.key, required this.onListen});

  @override
  State<${featurePascal}${slicePascal}Form> createState() => _${featurePascal}${slicePascal}FormState();
}

class _${featurePascal}${slicePascal}FormState extends State<${featurePascal}${slicePascal}Form> {
$controllerDeclarations

  void _onInputChanged() {
    final l10n = ${modulePascal}Localizations.of(context)!;

${inputValidation.toString().trimRight()}
${conversionStatements.toString().trimRight()}
${canResolveParamConstructor && paramAssignments.isNotEmpty ? '''    final param = ${featurePascal}${slicePascal}Param(
${paramAssignments.join('\n')}
    );''' : '''    // Keep form generation resilient when param constructor cannot be resolved.
    // Developer can map param manually later based on use case needs.
    final param = null;'''}
    widget.onListen(context, param, null);
  }

  @override
  void initState() {
    super.initState();
$initControllers
  }

  @override
  void dispose() {
$disposeControllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
${fieldWidgets.join('\n')}
      ],
    );
  }
}
''';
  }

  bool _isNullableParamType(String type) {
    return type.replaceAll(' ', '').endsWith('?');
  }

  String _normalizeParamType(String type) {
    final compact = type.replaceAll(' ', '');
    if (compact.endsWith('?')) {
      return compact.substring(0, compact.length - 1);
    }
    return compact;
  }

  String _defaultExpressionForParamType(String paramType) {
    if (_isNullableParamType(paramType)) {
      return 'null';
    }

    final normalizedType = _normalizeParamType(paramType);
    switch (normalizedType) {
      case 'String':
        return "''";
      case 'int':
        return '0';
      case 'double':
        return '0';
      case 'bool':
        return 'false';
      default:
        if (normalizedType.startsWith('List<')) {
          return 'const []';
        }
        if (normalizedType.startsWith('Map<')) {
          return 'const {}';
        }
        if (normalizedType.startsWith('Set<')) {
          return '<dynamic>{}';
        }
        return "'' as dynamic";
    }
  }

  String _buildAssignmentExpressionForParamType({
    required String paramType,
    required String inputName,
    required String variableStem,
    required StringBuffer conversionStatements,
  }) {
    final normalizedType = _normalizeParamType(paramType);
    switch (normalizedType) {
      case 'String':
        return inputName;
      case 'int':
        final parsedName = '${variableStem.camelCase}Parsed';
        conversionStatements.writeln(
          '    final $parsedName = int.tryParse($inputName);',
        );
        return parsedName;
      case 'double':
        final parsedName = '${variableStem.camelCase}Parsed';
        conversionStatements.writeln(
          '    final $parsedName = double.tryParse($inputName);',
        );
        return parsedName;
      case 'bool':
        final normalizedName = '${variableStem.camelCase}Normalized';
        final parsedName = '${variableStem.camelCase}Parsed';
        conversionStatements.writeln(
          "    final $normalizedName = $inputName.toLowerCase();",
        );
        conversionStatements.writeln(
          "    final $parsedName = $normalizedName == 'true' ? true : ($normalizedName == 'false' ? false : null);",
        );
        return parsedName;
      default:
        if (_isNullableParamType(paramType)) {
          return 'null';
        }
        return '$inputName as dynamic';
    }
  }

  String _buildDynamicFormYaml({
    required String featureName,
    required String sliceName,
    required List<String> fields,
    required bool dialogMode,
  }) {
    final featureCamel = featureName.camelCase;
    final featurePascal = featureName.pascalCase;
    final featureSnake = featureName.snakeCase;
    final slicePascal = sliceName.pascalCase;
    final sliceSnake = sliceName.snakeCase;

    final arbLines = <String>[
      '"failure${featurePascal}FormInvalid": "Please fill in all required fields correctly",',
      '"${featureCamel}${slicePascal}Title": "${sliceName.titleCase} ${featureName.titleCase}",',
      if (dialogMode)
        '"${featureCamel}${slicePascal}Description": "Please complete ${featureName.replaceAll('_', ' ')} ${sliceName.replaceAll('_', ' ')} data",',
      '"${featureCamel}${slicePascal}Action": "${sliceName.titleCase}",',
      '"${featureCamel}${slicePascal}Success": "${featureName.titleCase} created successfully",',
    ];

    for (final field in fields) {
      final fieldPascal = field.pascalCase;
      final fieldTitle = field.titleCase;
      final fieldSentence = field.replaceAll('_', ' ');
      final featureSentence = featureName.replaceAll('_', ' ');
      arbLines.add(
        '"${featureCamel}Field${fieldPascal}Label": "${fieldTitle}",',
      );
      arbLines.add(
        '"${featureCamel}Field${fieldPascal}Hint": "Enter ${featureSentence} ${fieldSentence}...",',
      );
      arbLines.add(
        '"${featureCamel}Field${fieldPascal}InvalidEmpty": "${fieldTitle} cannot be empty",',
      );
    }

    final uiExports = <String>[
      if (!dialogMode)
        "export 'ui/${sliceSnake}/views/${featureSnake}_${sliceSnake}_view.dart';",
      if (dialogMode)
        "export 'ui/${sliceSnake}/widgets/${featureSnake}_${sliceSnake}_dialog.dart';",
      "export 'ui/${sliceSnake}/widgets/${featureSnake}_${sliceSnake}_button.dart';",
      "export 'ui/${sliceSnake}/widgets/${featureSnake}_${sliceSnake}_form.dart';",
    ];

    return '''arb: |
  ${arbLines.join('\n  ')}

export:
  logic: |
    export 'logic/${sliceSnake}/${featureSnake}_${sliceSnake}_form_cubit.dart';
    export 'logic/${sliceSnake}/${featureSnake}_${sliceSnake}_form_state.dart';
  ui: |
    ${uiExports.join('\n    ')}

post_hooks:
  - flutter gen-l10n
  - dart run build_runner build --force-jit --delete-conflicting-outputs
''';
  }

  MasonBundle _resolveUiBundle(UiCode uiCode) {
    return switch (uiCode) {
      UiCode.main => uiMainBundle,
      UiCode.dialog => uiDialogBundle,
      UiCode.form => uiFormBundle,
      UiCode.formDialog => uiFormDialogBundle,
      UiCode.lsh => uiLshBundle,
      UiCode.lsv => uiLsvBundle,
      UiCode.pag => uiPagBundle,
      UiCode.pmi => uiPmiBundle,
      UiCode.action => uiActionBundle,
      UiCode.sec => uiSecBundle,
    };
  }
}
