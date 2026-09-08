import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../enums/di_class_type.dart';
import '../models/di_class_info.dart';
import '../models/di_param.dart';
import '../services/operation_report_service.dart';
import '../visitors/di_ast_visitor.dart';
import 'base_generator.dart';

class DiGenerator
    extends
        BaseGenerator<
          void,
          ({String module, String app, String? feature, bool strict})
        > {
  const DiGenerator({required super.logger});

  @override
  Future<void> generate(
    ({String module, String app, String? feature, bool strict}) args,
  ) async {
    final module = args.module;
    final app = args.app;
    final featureFilter = args.feature;
    final strict = args.strict;

    final moduleFeaturesRoot = Directory(
      p.join(
        Directory.current.path,
        'modules',
        module,
        'lib',
        'src',
        'features',
      ),
    );

    if (!await moduleFeaturesRoot.exists()) {
      logger.error(
        'Module features path not found: modules/$module/lib/src/features',
      );
      return;
    }

    final targetFeatures = await _collectTargetFeatures(
      moduleFeaturesRoot: moduleFeaturesRoot,
      module: module,
      featureFilter: featureFilter,
    );
    if (targetFeatures.isEmpty) {
      logger.info('No feature target found for module [$module].');
      return;
    }

    final diFilePath = p.join(
      Directory.current.path,
      'apps',
      app,
      'lib',
      'modules',
      module,
      '${module}_di.dart',
    );

    final diFile = File(diFilePath);
    if (!await diFile.exists()) {
      logger.error('Module DI file not found at: $diFilePath');
      return;
    }

    final isSingleFeature = featureFilter != null && featureFilter.isNotEmpty;
    logger.info(
      isSingleFeature
          ? 'Scanning feature [$featureFilter] from module [$module]...'
          : 'Scanning all features from module [$module]...',
    );

    final featureTargets = <({String feature, List<DiClassInfo> classes})>[];
    for (final feature in targetFeatures) {
      final featureRoot = p.join(moduleFeaturesRoot.path, feature);
      final classes = await _collectFeatureDiClasses(featureRoot);
      if (classes.isEmpty) {
        logger.info('No DI classes detected for feature [$feature].');
        continue;
      }
      featureTargets.add((feature: feature, classes: classes));
    }

    if (featureTargets.isEmpty) {
      logger.info(
        isSingleFeature
            ? 'No DI classes detected for feature [$featureFilter].'
            : 'No DI classes detected for all features in module [$module].',
      );
      final report = OperationReportService();
      report.addSkipped(diFilePath);
      report.logSummary(logger, operationLabel: 'fsda di');
      return;
    }

    final report = OperationReportService();
    final originalDiSource = await diFile.readAsString();
    var diSource = originalDiSource;
    var createdMethodCount = 0;
    var addedRegistrationCount = 0;
    var insertedRegisterCallCount = 0;

    for (final featureTarget in featureTargets) {
      final feature = featureTarget.feature;
      final diClasses = featureTarget.classes;
      final featureDiMethod = '_${feature.camelCase}Di';

      if (_containsFeatureMethod(diSource, featureDiMethod)) {
        final upsertResult = _appendMissingRegistrationsToFeatureMethod(
          source: diSource,
          methodName: featureDiMethod,
          classes: diClasses,
          strict: strict,
        );

        if (upsertResult.conflictMessage != null) {
          logger.error(upsertResult.conflictMessage!);
          report.addSkipped(diFilePath);
          report.logSummary(logger, operationLabel: 'fsda di');
          exitCode = 1;
          return;
        }

        diSource = upsertResult.source;
        addedRegistrationCount += upsertResult.addedCount;
      } else {
        final nextSource = _insertFeatureMethod(
          source: diSource,
          module: module,
          methodName: featureDiMethod,
          classes: diClasses,
          featureName: feature,
        );

        if (nextSource != diSource) {
          createdMethodCount += 1;
          addedRegistrationCount += _buildRegistrationLines(diClasses).length;
        }

        diSource = nextSource;
      }

      final registerResult = _insertRegisterCall(diSource, featureDiMethod);
      if (strict && registerResult.conflictMessage != null) {
        logger.error(registerResult.conflictMessage!);
        report.addSkipped(diFilePath);
        report.logSummary(logger, operationLabel: 'fsda di');
        exitCode = 1;
        return;
      }

      if (registerResult.inserted) {
        insertedRegisterCallCount += 1;
      }

      diSource = registerResult.source;
    }

    if (diSource == originalDiSource) {
      report.addSkipped(diFilePath);
      logger.info(
        isSingleFeature
            ? 'DI registration for feature [$featureFilter] is already up to date. No injection applied.'
            : 'DI registration for module [$module] is already up to date. No injection applied.',
      );
      report.logSummary(logger, operationLabel: 'fsda di');
      return;
    }

    await diFile.writeAsString(diSource);
    report.addInjected(diFilePath);

    if (createdMethodCount > 0) {
      logger.info('Created $createdMethodCount new feature DI method(s).');
    }

    if (addedRegistrationCount > 0) {
      logger.info('Injected $addedRegistrationCount new registration line(s).');
    }

    if (insertedRegisterCallCount > 0) {
      logger.info(
        'Injected $insertedRegisterCallCount missing register call(s).',
      );
    }

    logger.success(
      isSingleFeature
          ? 'Successfully synchronized feature [$featureFilter] into DI.'
          : 'Successfully synchronized module [$module] features into DI.',
    );
    report.logSummary(logger, operationLabel: 'fsda di');
  }

  Future<List<String>> _collectTargetFeatures({
    required Directory moduleFeaturesRoot,
    required String module,
    required String? featureFilter,
  }) async {
    if (featureFilter != null && featureFilter.isNotEmpty) {
      final targetDir = Directory(
        p.join(moduleFeaturesRoot.path, featureFilter),
      );
      if (!await targetDir.exists()) {
        logger.error(
          'Feature path not found: modules/$module/lib/src/features/$featureFilter',
        );
        return const <String>[];
      }
      return <String>[featureFilter];
    }

    final features = <String>[];
    await for (final entity in moduleFeaturesRoot.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final name = p.basename(entity.path);
      if (name.startsWith('.')) continue;
      features.add(name);
    }

    features.sort();
    return features;
  }

  Future<List<DiClassInfo>> _collectFeatureDiClasses(
    String featureRootPath,
  ) async {
    final targetSubPaths = [
      p.join('data', 'datasources'),
      p.join('data', 'repositories'),
      p.join('domain', 'repositories'),
      p.join('domain', 'usecases'),
      'logic',
    ];

    final diClasses = <DiClassInfo>[];
    for (final subPath in targetSubPaths) {
      final files = await _collectDartFiles(p.join(featureRootPath, subPath));
      for (final file in files) {
        final content = await file.readAsString();
        final parsed = parseString(content: content);
        final visitor = DiAstVisitor();
        parsed.unit.visitChildren(visitor);

        if (visitor.classes.isEmpty) continue;

        for (final info in visitor.classes) {
          if (info.type == null) continue;
          diClasses.add(info);
        }
      }
    }

    final orderedTypes = [
      DiClassType.datasource,
      DiClassType.repository,
      DiClassType.usecase,
      DiClassType.logic,
    ];

    diClasses.sort(
      (a, b) => orderedTypes
          .indexOf(a.type!)
          .compareTo(orderedTypes.indexOf(b.type!)),
    );

    return diClasses;
  }

  Future<List<File>> _collectDartFiles(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) return const <File>[];

    final files = <File>[];
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        files.add(entity);
      }
    }
    return files;
  }

  bool _containsFeatureMethod(String source, String methodName) {
    final methodPattern = RegExp(
      r'(?:static\s+)?void\s+' + RegExp.escape(methodName) + r'\s*\(\s*\)',
    );
    return methodPattern.hasMatch(source);
  }

  ({String source, int addedCount, String? conflictMessage})
  _appendMissingRegistrationsToFeatureMethod({
    required String source,
    required String methodName,
    required List<DiClassInfo> classes,
    required bool strict,
  }) {
    final offsets = _findMethodOffsets(source: source, methodName: methodName);
    if (offsets == null) {
      if (strict) {
        return (
          source: source,
          addedCount: 0,
          conflictMessage:
              'Strict mode: target feature DI method "$methodName" exists but could not be parsed safely for injection.',
        );
      }

      return (source: source, addedCount: 0, conflictMessage: null);
    }

    var nextSource = source;
    var addedCount = 0;
    final emittedClasses = <String>{};

    for (final cls in classes) {
      if (!emittedClasses.add(cls.className)) {
        continue;
      }

      if (_featureMethodContainsClassRegistration(
        source: nextSource,
        methodName: methodName,
        className: cls.className,
      )) {
        continue;
      }

      final line = _buildRegistrationLine(cls);
      if (line == null) {
        continue;
      }

      final updatedSource = _insertLineBeforeMethodClose(
        source: nextSource,
        methodName: methodName,
        line: line,
      );

      if (updatedSource == nextSource) {
        if (strict) {
          return (
            source: source,
            addedCount: 0,
            conflictMessage:
                'Strict mode: failed to inject registration into method "$methodName" safely.',
          );
        }
        continue;
      }

      nextSource = updatedSource;
      addedCount += 1;
    }

    return (source: nextSource, addedCount: addedCount, conflictMessage: null);
  }

  bool _featureMethodContainsClassRegistration({
    required String source,
    required String methodName,
    required String className,
  }) {
    final body = _extractMethodBody(source: source, methodName: methodName);
    if (body == null) {
      return false;
    }

    final classReferenceRegex = RegExp('\\b${RegExp.escape(className)}\\s*\\(');
    return classReferenceRegex.hasMatch(body);
  }

  String _insertLineBeforeMethodClose({
    required String source,
    required String methodName,
    required String line,
  }) {
    final offsets = _findMethodOffsets(source: source, methodName: methodName);
    if (offsets == null) {
      return source;
    }

    final closeBraceLineStart = source.lastIndexOf('\n', offsets.closeBrace);
    final insertOffset = closeBraceLineStart == -1
        ? offsets.closeBrace
        : closeBraceLineStart + 1;

    return source.replaceRange(insertOffset, insertOffset, '$line\n');
  }

  String? _extractMethodBody({
    required String source,
    required String methodName,
  }) {
    final offsets = _findMethodOffsets(source: source, methodName: methodName);
    if (offsets == null) {
      return null;
    }

    final openBraceOffset = source.indexOf('{', offsets.methodStart);
    if (openBraceOffset == -1 || openBraceOffset >= offsets.closeBrace) {
      return null;
    }

    return source.substring(openBraceOffset + 1, offsets.closeBrace);
  }

  List<String> _buildRegistrationLines(List<DiClassInfo> classes) {
    final lines = <String>[];
    final seen = <String>{};

    for (final cls in classes) {
      final line = _buildRegistrationLine(cls);
      if (line == null) {
        continue;
      }

      final normalized = line.trim();
      if (!seen.add(normalized)) {
        continue;
      }

      lines.add(line);
    }

    return lines;
  }

  ({int methodStart, int closeBrace})? _findMethodOffsets({
    required String source,
    required String methodName,
  }) {
    final methodPattern = RegExp(
      r'(?:static\s+)?void\s+' + RegExp.escape(methodName) + r'\s*\(\s*\)\s*\{',
      multiLine: true,
    );
    final match = methodPattern.firstMatch(source);
    if (match == null) return null;

    final openBraceOffset = source.indexOf('{', match.start);
    if (openBraceOffset == -1) return null;

    final closeBraceOffset = _findClosingBrace(source, openBraceOffset);
    if (closeBraceOffset == -1) return null;

    return (methodStart: match.start, closeBrace: closeBraceOffset);
  }

  ({String source, bool inserted, String? conflictMessage}) _insertRegisterCall(
    String source,
    String methodName,
  ) {
    final registerCall = '    $methodName();';
    if (source.contains(registerCall)) {
      return (source: source, inserted: false, conflictMessage: null);
    }

    if (source.contains('// reg feature di')) {
      return (
        source: source.replaceFirst(
          '// reg feature di',
          '// reg feature di\n$registerCall',
        ),
        inserted: true,
        conflictMessage: null,
      );
    }

    final registerStartRegex = RegExp(
      r'static\s+(?:Future<void>|void)\s+register\s*\(\s*\)\s*(?:async\s*)?\{',
    );
    final match = registerStartRegex.firstMatch(source);
    if (match == null) {
      return (
        source: source,
        inserted: false,
        conflictMessage:
            'Strict mode: could not find register() method or "// reg feature di" checkpoint to insert call for "$methodName".',
      );
    }

    final openBraceOffset = source.indexOf('{', match.start);
    final closeBraceOffset = _findClosingBrace(source, openBraceOffset);
    if (closeBraceOffset == -1) {
      return (
        source: source,
        inserted: false,
        conflictMessage:
            'Strict mode: could not locate closing brace of register() method for call injection.',
      );
    }

    return (
      source: source.replaceRange(
        closeBraceOffset,
        closeBraceOffset,
        '\n$registerCall\n  ',
      ),
      inserted: true,
      conflictMessage: null,
    );
  }

  int _findClosingBrace(String source, int openBraceOffset) {
    var depth = 0;
    for (var i = openBraceOffset; i < source.length; i++) {
      final char = source[i];
      if (char == '{') depth += 1;
      if (char == '}') {
        depth -= 1;
        if (depth == 0) return i;
      }
    }
    return -1;
  }

  String _insertFeatureMethod({
    required String source,
    required String module,
    required String methodName,
    required List<DiClassInfo> classes,
    required String featureName,
  }) {
    final methodBlock = _buildFeatureMethod(
      featureName: featureName,
      methodName: methodName,
      classes: classes,
    );

    final targetClass = '${module.pascalCase}Di';
    final parsed = parseString(content: source);

    for (final declaration in parsed.unit.declarations) {
      if (declaration is! ClassDeclaration) continue;
      final className = declaration.namePart.typeName.lexeme;
      if (className != targetClass) continue;

      final insertOffset = declaration.endToken.offset;
      return source.replaceRange(
        insertOffset,
        insertOffset,
        '\n\n$methodBlock\n',
      );
    }

    final fallbackOffset = source.lastIndexOf('}');
    if (fallbackOffset == -1) {
      return '$source\n\n$methodBlock\n';
    }

    return source.replaceRange(
      fallbackOffset,
      fallbackOffset,
      '\n\n$methodBlock\n',
    );
  }

  String _buildFeatureMethod({
    required String featureName,
    required String methodName,
    required List<DiClassInfo> classes,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('  // $featureName feature');
    buffer.writeln('  static void $methodName() {');

    buffer.writeln('    // Datasources');
    _writeLayer(buffer, classes, DiClassType.datasource);

    buffer.writeln('\n    // Repositories');
    _writeLayer(buffer, classes, DiClassType.repository);

    buffer.writeln('\n    // Usecases');
    _writeLayer(buffer, classes, DiClassType.usecase);

    buffer.writeln('\n    // Logic (Cubits/Blocs)');
    _writeLayer(buffer, classes, DiClassType.logic);

    buffer.writeln('  }');
    return buffer.toString().trimRight();
  }

  void _writeLayer(
    StringBuffer buffer,
    List<DiClassInfo> classes,
    DiClassType type,
  ) {
    final filtered = classes.where((e) => e.type == type);
    for (final cls in filtered) {
      final line = _buildRegistrationLine(cls);
      if (line != null) {
        buffer.writeln(line);
      }
    }
  }

  String? _buildRegistrationLine(DiClassInfo cls) {
    final type = cls.type;
    if (type == null) return null;

    final constructorArguments = cls.parameters
        .map(
          (param) => param.isNamed
              ? '${param.name}: ${_resolveNamedParameterValue(cls: cls, param: param)}'
              : 'sl()',
        )
        .join(', ');

    if (type == DiClassType.datasource || type == DiClassType.repository) {
      final interface = cls.interfaceName ?? cls.className;
      return '    sl.registerLazySingleton<$interface>(() => ${cls.className}($constructorArguments));';
    }

    if (type == DiClassType.usecase) {
      return '    sl.registerLazySingleton(() => ${cls.className}($constructorArguments));';
    }

    if (type == DiClassType.logic) {
      return '    sl.registerFactory(() => ${cls.className}($constructorArguments));';
    }

    return null;
  }

  String _resolveNamedParameterValue({
    required DiClassInfo cls,
    required DiParam param,
  }) {
    final paramType = param.typeName?.replaceAll('?', '').trim();
    if (paramType == 'AppLogger') {
      final contextName = cls.interfaceName ?? cls.className;
      return "sl(param1: '$contextName')";
    }

    return 'sl()';
  }
}
