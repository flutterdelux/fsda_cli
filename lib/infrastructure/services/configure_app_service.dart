import 'dart:convert';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../../domain/models/infra_spec.dart';
import '../../domain/params/configure_app_param.dart';
import '../bundles/package_bundle.dart';
import '../visitors/di_function_visitor.dart';
import 'helpers/config_service.dart';
import 'helpers/directory_service.dart';
import 'helpers/file_service.dart';
import 'helpers/import_service.dart';
import 'helpers/operation_report_service.dart';
import 'helpers/process_service.dart';

class ConfigureAppService {
  final ConfigService _configService;
  final ProcessService _processService;
  final OperationReportService _reportService;
  final DirectoryService _directoryService;
  final FileService _fileService;
  final ImportService _importService;

  const ConfigureAppService({
    required ConfigService configService,
    required ProcessService processService,
    required OperationReportService reportService,
    required DirectoryService directoryService,
    required FileService fileService,
    required ImportService importService,
  }) : _configService = configService,
       _processService = processService,
       _reportService = reportService,
       _directoryService = directoryService,
       _fileService = fileService,
       _importService = importService;

  Future<void> configure({
    required ConfigureAppParam app,
    required Function(String) onProgress,
  }) async {
    onProgress('Reading FSDA configuration...');
    final config = await _configService.loadConfig();
    final infraList = config.activePackages
        .where((e) => e.startsWith('infra_'))
        .toList();

    onProgress('Adding package to app pubspec...');
    final specs = await _getInfraSpecs(app: app, infraList: infraList);

    onProgress('Injecting infra & adding dependencies to app pubspec...');
    await _injectInfraToPubspec(app: app, specs: specs);

    onProgress('Injecting external di...');
    await _injectExternalDi(app: app, specs: specs);

    onProgress('Injecting core di...');
    await _injectCoreDi(app: app, specs: specs);
  }

  // ================= Configure App Helper ========================

  Future<List<InfraSpec>> _getInfraSpecs({
    required ConfigureAppParam app,
    required List<String> infraList,
  }) async {
    final specs = <InfraSpec>[];
    for (final infra in infraList) {
      final specBase64 = packageBundle[infra]?['spec.yaml'];
      if (specBase64 == null) continue;

      final bytes = base64.decode(specBase64);
      final content = utf8.decode(bytes, allowMalformed: true);
      final yamlMap = loadYaml(content) as YamlMap?;

      final appDependenciesYaml = yamlMap?['app_dependencies'] as YamlList?;
      final appDependencies = appDependenciesYaml != null
          ? appDependenciesYaml.map((e) => e.toString()).toSet()
          : <String>{};

      final externalDiYaml = yamlMap?['external_di'] as YamlMap?;
      final externalDiImports =
          (externalDiYaml?['import'] as String?)?.split('\n') ?? [];
      final externalDiCode = externalDiYaml?['code'] as String?;

      final coreDiYaml = yamlMap?['core_di'] as YamlMap?;
      final coreDiImports =
          (coreDiYaml?['import'] as String?)?.split('\n') ?? [];
      final coreDiCode = coreDiYaml?['code'] as String?;

      specs.add(
        InfraSpec(
          name: infra,
          appDependencies: appDependencies,
          externalDiImports: externalDiImports.toSet(),
          externalDiCode: externalDiCode ?? '',
          coreDiImports: coreDiImports.toSet(),
          coreDiCode: coreDiCode ?? '',
        ),
      );
    }
    return specs;
  }

  Future<void> _injectInfraToPubspec({
    required ConfigureAppParam app,
    required List<InfraSpec> specs,
  }) async {
    final pubspecPath = p.join(app.projectPath, 'pubspec.yaml');
    if (!await _fileService.exists(pubspecPath)) return;

    // Gunakan variabel mutable agar konten YAML terus diperbarui setiap ada penambahan package
    String content = await _fileService.readAsString(pubspecPath);
    bool hasChanges = false;

    for (final infra in specs) {
      final infraName = infra.name;

      final yamlMap = loadYaml(content) as YamlMap?;
      final dependencies = yamlMap?['dependencies'] as YamlMap?;

      // Jika dependencies sudah ada, gunakan 'continue' (bukan 'return') agar lanjut ke infra berikutnya
      if (dependencies != null && dependencies.containsKey(infraName)) {
        continue;
      }

      final relativeModulePath = p.relative(
        p.join(_directoryService.currentPath, 'packages', infraName),
        from: app.projectPath,
      );

      // Gunakan YamlEditor pada konten terbaru
      final editor = YamlEditor(content);
      editor.update(
        ['dependencies', infraName],
        {'path': relativeModulePath.replaceAll(r'\', '/')},
      );

      // Perbarui content dan tandai bahwa ada perubahan
      content = editor.toString();
      hasChanges = true;
    }

    // Tulis sekali saja setelah semua infra diproses di dalam loop
    if (hasChanges) {
      await _fileService.writeAsString(path: pubspecPath, content: content);
      _reportService.addInjected(pubspecPath);
    }

    final externalDependencies = specs.expand((e) => e.appDependencies).toSet();
    if (externalDependencies.isNotEmpty) {
      await _processService.run('dart', [
        'pub',
        'add',
        ...externalDependencies,
      ], app.projectPath);
    }
  }

  Future<void> _injectExternalDi({
    required ConfigureAppParam app,
    required List<InfraSpec> specs,
  }) async {
    final path = p.join(
      app.projectPath,
      'lib',
      'core',
      'di',
      'external_di.dart',
    );

    final imports = {
      ...specs.expand((e) => e.externalDiImports).toSet(),
      "import 'di.dart';",
    };
    await _importService.injectImport(path: path, imports: imports);

    final codes = specs.map((e) => e.externalDiCode).join('\n');
    if (codes.trim().isNotEmpty) {
      final content = await _fileService.readAsString(path);
      final updatedContent = _injectCodeToDiFunction(
        fileContent: content,
        functionName: 'externalDI',
        codeToInject: codes,
      );

      await _fileService.writeAsString(path: path, content: updatedContent);
    }

    _reportService.addInjected(path);
  }

  Future<void> _injectCoreDi({
    required ConfigureAppParam app,
    required List<InfraSpec> specs,
  }) async {
    final path = p.join(app.projectPath, 'lib', 'core', 'di', 'core_di.dart');
    if (!await _fileService.exists(path)) return;

    final imports = {
      ...specs.expand((e) => e.coreDiImports).toSet(),
      "import 'package:app_core/app_core.dart';",
      "import 'di.dart';",
    };
    await _importService.injectImport(path: path, imports: imports);

    final codes =
        '''
  ${specs.map((e) => e.coreDiCode).join('\n')}
''';
    if (codes.trim().isNotEmpty) {
      final content = await _fileService.readAsString(path);
      final updatedContent = _injectCodeToDiFunction(
        fileContent: content,
        functionName: 'coreDI',
        codeToInject: codes,
      );

      await _fileService.writeAsString(path: path, content: updatedContent);
    }

    _reportService.addInjected(path);
  }

  String _injectCodeToDiFunction({
    required String fileContent,
    required String functionName,
    required String codeToInject,
  }) {
    if (codeToInject.trim().isEmpty) return fileContent;

    // 1. Bersihkan spasi kosong berlebih, lalu bagi berdasarkan baris
    final lines = codeToInject.trim().split('\n');

    // 2. Tambahkan indentasi (2 spasi) ke setiap baris agar rapi di dalam fungsi
    final indentedCode = lines
        .map((line) {
          if (line.trim().isEmpty) return '';
          return '  $line'; // Indentasi standar level 2 di dalam fungsi
        })
        .join('\n');

    final result = parseString(content: fileContent);
    final visitor = DiFunctionVisitor(functionName);
    result.unit.visitChildren(visitor);

    if (visitor.insertOffset == null) {
      throw Exception('$functionName() not found.');
    }

    final offset = visitor.insertOffset!;

    // Beri jarak baris antar kode inject jika diperlukan
    final formattedCode = '\n$indentedCode\n';

    final updatedContent =
        fileContent.substring(0, offset) +
        formattedCode +
        fileContent.substring(offset);

    return updatedContent;
  }
}
