import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/cli_info.dart';
import '../../../domain/models/config_android_model.dart';
import '../../../domain/models/config_model.dart';
import '../../../domain/params/workspace_param.dart';
import '../../templates/config_template.dart';
import 'directory_service.dart';
import 'file_service.dart';

class ConfigService {
  final DirectoryService _directoryService;
  final FileService _fileService;

  const ConfigService({
    required DirectoryService directoryService,
    required FileService fileService,
  }) : _directoryService = directoryService,
       _fileService = fileService;

  String get fsdaDirPath =>
      p.join(_directoryService.currentPath, CliInfo.fsdaDirName);
  String get plansDirPath => p.join(fsdaDirPath, CliInfo.plansDirName);
  String get configPath => p.join(fsdaDirPath, CliInfo.configFileName);

  Future<String> get _configContent async {
    return await _fileService.readAsString(configPath);
  }

  Future<WorkspaceParam?> get fsdaWorkspace async {
    final exists = await _fileService.exists(configPath);
    if (exists) {
      final rootPath = _directoryService.currentPath;
      return WorkspaceParam(
        workspaceName: p.basename(rootPath),
        workspacePath: rootPath,
      );
    }
    return null;
  }

  Future<ConfigModel> loadConfig() async {
    final workspace = await fsdaWorkspace;
    if (workspace == null) {
      throw Exception(
        'Not inside an FSDA workspace. File "${CliInfo.fsdaDirName}/${CliInfo.configFileName}" was not found.',
      );
    }

    final yamlMap = loadYaml(await _configContent) as YamlMap?;

    final cliVersion = yamlMap?['fsda_cli']?.toString() ?? '';
    final sdkVersion = yamlMap?['dart_sdk']?.toString() ?? CliInfo.dartSdk;

    final packagesYaml = yamlMap?['packages'] as YamlList?;
    final activePackages = packagesYaml != null
        ? packagesYaml.map((e) => e.toString()).toList()
        : <String>[];

    final androidMap = yamlMap?['android'] as YamlMap?;
    final android = androidMap != null
        ? ConfigAndroidModel(
            compileSdk:
                (androidMap['compile_sdk'] as num?)?.toInt() ??
                AppConfig.androidCompileSdk,
            minSdk:
                (androidMap['min_sdk'] as num?)?.toInt() ??
                AppConfig.androidMinSdk,
            targetSdk:
                (androidMap['target_sdk'] as num?)?.toInt() ??
                AppConfig.androidTargetSdk,
          )
        : const ConfigAndroidModel();

    return ConfigModel(
      workspaceName: workspace.workspaceName,
      workspacePath: workspace.workspacePath,
      cliVersion: cliVersion,
      activePackages: activePackages,
      dartSdk: sdkVersion,
      android: android,
    );
  }

  Future<void> addPackages(List<String> packageNames) async {
    final editor = YamlEditor(await _configContent);
    final currentConfig = await loadConfig();

    final combined = [...currentConfig.activePackages, ...packageNames];
    final sortedPackages = _sortPackages(combined);

    editor.update(['packages'], sortedPackages);
    await _fileService.writeAsString(
      path: configPath,
      content: editor.toString(),
    );
  }

  Future<void> removePackages(List<String> packageNames) async {
    final editor = YamlEditor(await _configContent);
    final currentConfig = await loadConfig();

    final targetSet = packageNames.toSet();
    final remainingPackages = currentConfig.activePackages
        .where((pkg) => !targetSet.contains(pkg))
        .toList();

    final sortedPackages = _sortPackages(remainingPackages);

    editor.update(['packages'], sortedPackages);
    await _fileService.writeAsString(
      path: configPath,
      content: editor.toString(),
    );
  }

  // ================== Helper ==================

  List<String> _sortPackages(List<String> packages) {
    const mandatoryPackages = ConfigTemplate.mandatoryPackages;

    final sortedList = packages.toSet().toList();

    sortedList.sort((a, b) {
      final indexA = mandatoryPackages.indexOf(a);
      final indexB = mandatoryPackages.indexOf(b);

      final isMandatoryA = indexA != -1;
      final isMandatoryB = indexB != -1;

      if (isMandatoryA && isMandatoryB) {
        return indexA.compareTo(indexB);
      }
      if (isMandatoryA) {
        return -1;
      }
      if (isMandatoryB) {
        return 1;
      }

      return a.compareTo(b);
    });

    return sortedList;
  }
}
