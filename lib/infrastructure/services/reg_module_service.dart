import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../../core/extensions/app_integration_param_x.dart';
import '../../domain/params/app_integration/reg_module_param.dart';
import '../templates/app_integration/app_module_di_template.dart';
import '../templates/app_integration/app_module_route_template.dart';
import '../visitors/app_router_routes_visitor.dart';
import '../visitors/failure_x_visitor.dart';
import '../visitors/init_di_visitor.dart';
import '../visitors/localization_delegates_visitor.dart';
import 'helpers/file_service.dart';
import 'helpers/import_service.dart';
import 'helpers/operation_report_service.dart';

class RegModuleService {
  final OperationReportService _reportService;
  final FileService _fileService;
  final ImportService _importService;

  const RegModuleService({
    required OperationReportService reportService,
    required FileService fileService,
    required ImportService importService,
  }) : _reportService = reportService,
       _fileService = fileService,
       _importService = importService;

  Future<void> registerModule({
    required RegModuleParam param,
    required void Function(String) onProgress,
  }) async {
    onProgress('Injecting module dependency into app pubspec.yaml...');
    await _injectPubspecDependency(param);

    onProgress('Creating app module DI wrapper file...');
    final diArtifact = AppModuleDiTemplate.build(param);
    if (!await _fileService.exists(diArtifact.path)) {
      await _fileService.writeAsString(
        path: diArtifact.path,
        content: diArtifact.content,
      );
      _reportService.addCreated(diArtifact.path);
    }

    onProgress('Creating app module Route wrapper file...');
    final routeArtifact = AppModuleRouteTemplate.build(param);
    if (!await _fileService.exists(routeArtifact.path)) {
      await _fileService.writeAsString(
        path: routeArtifact.path,
        content: routeArtifact.content,
      );
      _reportService.addCreated(routeArtifact.path);
    }

    onProgress('Injecting module localizations into main_app.dart...');
    await _injectLocalizations(param);

    onProgress('Injecting failure handling into failure_x.dart...');
    await _injectFailureX(param);

    onProgress('Injecting module DI registration into core/di/di.dart...');
    await _injectAppDi(param);

    onProgress('Injecting module route into app_router.dart...');
    await _injectAppRouter(param);
  }

  // ================= Helpers =================

  Future<void> _injectPubspecDependency(RegModuleParam param) async {
    final pubspecPath = param.appPubspecPath;
    if (!await _fileService.exists(pubspecPath)) return;

    final content = await _fileService.readAsString(pubspecPath);
    final moduleName = param.moduleSnake;

    final yamlMap = loadYaml(content) as YamlMap?;
    final dependencies = yamlMap?['dependencies'] as YamlMap?;
    if (dependencies != null && dependencies.containsKey(moduleName)) {
      return;
    }

    final relativeModulePath = p.relative(
      param.modulePath,
      from: param.appPath,
    );

    final editor = YamlEditor(content);
    editor.update(
      ['dependencies', moduleName],
      {'path': relativeModulePath.replaceAll(r'\', '/')},
    );

    await _fileService.writeAsString(
      path: pubspecPath,
      content: editor.toString(),
    );
    _reportService.addInjected(pubspecPath);
  }

  Future<void> _injectLocalizations(RegModuleParam param) async {
    final path = param.mainAppPath;
    if (!await _fileService.exists(path)) return;

    String content = await _fileService.readAsString(path);
    final locName = '${param.modulePascal}Localizations';

    if (content.contains(locName)) return;

    final importLine =
        "import 'package:${param.moduleSnake}/${param.moduleSnake}.dart';";
    if (!content.contains(importLine)) {
      await _importService.injectImport(path: path, imports: {importLine});
      content = await _fileService.readAsString(path);
    }

    final unit = parseString(content: content).unit;
    int? insertOffset;

    unit.visitChildren(
      LocalizationsDelegatesVisitor((offset) {
        insertOffset = offset;
      }),
    );

    if (insertOffset != null) {
      // Ambil karakter tepat sebelum posisi insertOffset
      final precedingChar = content.substring(0, insertOffset).trimRight();
      final hasComma = precedingChar.endsWith(',');

      // Jika sudah ada koma, cukup buat baris baru. Jika belum, tambahkan koma dulu.
      final separator = hasComma ? '\n' : ',\n';
      final codeToInject =
          '$separator        ...$locName.localizationsDelegates\n';

      content =
          '${content.substring(0, insertOffset!)}$codeToInject${content.substring(insertOffset!)}';
      await _fileService.writeAsString(path: path, content: content);
      _reportService.addInjected(path);
    }
  }

  Future<void> _injectFailureX(RegModuleParam param) async {
    final path = param.failureXPath;
    if (!await _fileService.exists(path)) return;

    String content = await _fileService.readAsString(path);
    final failureName = '${param.modulePascal}Failure';

    if (content.contains(failureName)) return;

    final importLine =
        "import 'package:${param.moduleSnake}/${param.moduleSnake}.dart';";
    if (!content.contains(importLine)) {
      await _importService.injectImport(path: path, imports: {importLine});
      content = await _fileService.readAsString(path);
    }

    final unit = parseString(content: content).unit;
    int? insertOffset;

    unit.visitChildren(
      FailureXVisitor((offset) {
        insertOffset = offset;
      }),
    );

    if (insertOffset != null) {
      final codeToInject =
          '''if (this is $failureName) {
      return (this as $failureName).localize(context);
    }
''';
      content =
          '${content.substring(0, insertOffset!)}$codeToInject\n    ${content.substring(insertOffset!)}';
      await _fileService.writeAsString(path: path, content: content);
      _reportService.addInjected(path);
    }
  }

  Future<void> _injectAppDi(RegModuleParam param) async {
    final path = param.appDiPath;
    if (!await _fileService.exists(path)) return;

    String content = await _fileService.readAsString(path);
    final diName = '${param.modulePascal}Di';

    if (content.contains(diName)) return;

    final importLine =
        "import '../../modules/${param.moduleSnake}/${param.moduleSnake}_di.dart';";
    if (!content.contains(importLine)) {
      await _importService.injectImport(path: path, imports: {importLine});
      content = await _fileService.readAsString(path);
    }

    final unit = parseString(content: content).unit;
    int? insertOffset;

    unit.visitChildren(
      InitDiVisitor((offset) {
        insertOffset = offset;
      }),
    );

    if (insertOffset != null) {
      final codeToInject = '  $diName.register();\n';
      content =
          '${content.substring(0, insertOffset!)}$codeToInject${content.substring(insertOffset!)}';
      await _fileService.writeAsString(path: path, content: content);
      _reportService.addInjected(path);
    }
  }

  Future<void> _injectAppRouter(RegModuleParam param) async {
    final path = param.appRouterPath;
    if (!await _fileService.exists(path)) return;

    String content = await _fileService.readAsString(path);
    final routeName = '${param.modulePascal}Route';
    final routeInjectionCode = '$routeName.base';

    if (content.contains(routeInjectionCode)) return;

    final relativeRoutePath = p.relative(
      param.appModuleRoutePath,
      from: p.dirname(path),
    );
    final importLine = "import '${relativeRoutePath.replaceAll(r'\', '/')}';";

    if (!content.contains(importLine)) {
      await _importService.injectImport(path: path, imports: {importLine});
      content = await _fileService.readAsString(path);
    }

    final unit = parseString(content: content).unit;
    int? insertOffset;

    unit.visitChildren(
      AppRouterRoutesVisitor((offset) {
        insertOffset = offset;
      }),
    );

    if (insertOffset != null) {
      final preceding = content.substring(0, insertOffset).trimRight();
      final comma = preceding.endsWith(',') ? '' : ',';

      final codeToInject = '$comma\n        $routeName.base';

      content =
          '${content.substring(0, insertOffset!)}$codeToInject${content.substring(insertOffset!)}';
      await _fileService.writeAsString(path: path, content: content);
      _reportService.addInjected(path);
    }
  }
}
