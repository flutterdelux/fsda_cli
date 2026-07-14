import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

import '../enums/di_class_type.dart';
import '../models/di_class_info.dart';
import '../models/di_param.dart';
import '../visitors/di_ast_visitor.dart';
import 'base_generator.dart';

class DiGenerator
    extends BaseGenerator<void, ({String feature, String module, String app})> {
  const DiGenerator({required super.logger});

  @override
  Future<void> generate(
    ({String feature, String module, String app}) args,
  ) async {
    final feature = args.feature;
    final module = args.module;
    final app = args.app;

    final featureRoot = Directory(
      p.join(
        Directory.current.path,
        'modules',
        module,
        'lib',
        'src',
        'features',
        feature,
      ),
    );

    if (!await featureRoot.exists()) {
      logger.error(
        'Feature path not found: modules/$module/lib/src/features/$feature',
      );
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

    logger.info('Scanning feature [$feature] from module [$module]...');

    final targetSubPaths = [
      p.join('data', 'datasources'),
      p.join('data', 'repositories'),
      p.join('domain', 'repositories'),
      p.join('domain', 'usecases'),
      'logic',
    ];

    final diClasses = <DiClassInfo>[];
    for (final subPath in targetSubPaths) {
      final files = await _collectDartFiles(p.join(featureRoot.path, subPath));
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

    if (diClasses.isEmpty) {
      logger.info('No DI classes detected for feature [$feature].');
      return;
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

    var diSource = await diFile.readAsString();
    final featureDiMethod = '_${feature.camelCase}Di';

    if (_containsFeatureMethod(diSource, featureDiMethod)) {
      diSource = _replaceFeatureMethod(
        source: diSource,
        methodName: featureDiMethod,
        classes: diClasses,
        featureName: feature,
      );
    } else {
      diSource = _insertFeatureMethod(
        source: diSource,
        module: module,
        methodName: featureDiMethod,
        classes: diClasses,
        featureName: feature,
      );
    }

    diSource = _insertRegisterCall(diSource, featureDiMethod);

    await diFile.writeAsString(diSource);
    logger.success('Successfully injected feature [$feature] into DI.');
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

  String _replaceFeatureMethod({
    required String source,
    required String methodName,
    required List<DiClassInfo> classes,
    required String featureName,
  }) {
    final offsets = _findMethodOffsets(source: source, methodName: methodName);
    if (offsets == null) return source;

    var replaceStart = offsets.methodStart;
    final featureComment = '  // $featureName feature';
    final commentOffset = source.lastIndexOf(
      featureComment,
      offsets.methodStart,
    );
    if (commentOffset != -1) {
      final between = source.substring(
        commentOffset + featureComment.length,
        offsets.methodStart,
      );
      if (RegExp(r'^\s*$').hasMatch(between)) {
        replaceStart = commentOffset;
      }
    }

    final methodBlock = _buildFeatureMethod(
      featureName: featureName,
      methodName: methodName,
      classes: classes,
    );

    return source.replaceRange(
      replaceStart,
      offsets.closeBrace + 1,
      methodBlock,
    );
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

  String _insertRegisterCall(String source, String methodName) {
    final registerCall = '    $methodName();';
    if (source.contains(registerCall)) return source;

    if (source.contains('// reg feature di')) {
      return source.replaceFirst(
        '// reg feature di',
        '// reg feature di\n$registerCall',
      );
    }

    final registerStartRegex = RegExp(
      r'static\s+(?:Future<void>|void)\s+register\s*\(\s*\)\s*(?:async\s*)?\{',
    );
    final match = registerStartRegex.firstMatch(source);
    if (match == null) return source;

    final openBraceOffset = source.indexOf('{', match.start);
    final closeBraceOffset = _findClosingBrace(source, openBraceOffset);
    if (closeBraceOffset == -1) return source;

    return source.replaceRange(
      closeBraceOffset,
      closeBraceOffset,
      '\n$registerCall\n  ',
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
