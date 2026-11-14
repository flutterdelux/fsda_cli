import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/cli_info.dart';
import '../../../domain/models/config_android_model.dart';
import '../../../domain/models/config_model.dart';
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

  String get _fsdaPath => p.join(_directoryService.currentPath, 'fsda.yaml');

  Future<String> get _fsdaContent async {
    return await _fileService.readAsString(_fsdaPath);
  }

  Future<bool> get validateWorkspaceRoot => _fileService.exists(_fsdaPath);

  Future<ConfigModel> loadConfig() async {
    if (!await validateWorkspaceRoot) {
      throw Exception(
        'Not inside an FSDA workspace. File "fsda.yaml" was not found.',
      );
    }

    final yamlMap = loadYaml(await _fsdaContent) as YamlMap?;

    final workspaceName = yamlMap?['workspace']?.toString() ?? '';
    final cliVersion = yamlMap?['fsda_cli']?.toString() ?? '';
    final sdkVersion =
        yamlMap?['sdk_version']?.toString() ?? CliInfo.sdkVersion;

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
      workspaceName: workspaceName,
      workspacePath: _directoryService.currentPath,
      cliVersion: cliVersion,
      activePackages: activePackages,
      sdkVersion: sdkVersion,
      android: android,
    );
  }

  Future<void> addPackages(List<String> packageNames) async {
    final editor = YamlEditor(await _fsdaContent);
    final currentConfig = await loadConfig();

    // Gabungkan paket lama dan paket baru
    final combined = [...currentConfig.activePackages, ...packageNames];

    // Urutkan menggunakan helper
    final sortedPackages = _sortPackages(combined);

    editor.update(['packages'], sortedPackages);
    await _fileService.writeAsString(
      path: _fsdaPath,
      content: editor.toString(),
    );
  }

  Future<void> removePackages(List<String> packageNames) async {
    final editor = YamlEditor(await _fsdaContent);
    final currentConfig = await loadConfig();

    // Filter sisa paket yang tidak dihapus
    final targetSet = packageNames.toSet();
    final remainingPackages = currentConfig.activePackages
        .where((pkg) => !targetSet.contains(pkg))
        .toList();

    // Urutkan ulang sisa paket menggunakan helper
    final sortedPackages = _sortPackages(remainingPackages);

    editor.update(['packages'], sortedPackages);
    await _fileService.writeAsString(
      path: _fsdaPath,
      content: editor.toString(),
    );
  }

  // ================== Helper ==================

  List<String> _sortPackages(List<String> packages) {
    const mandatoryPackages = ConfigTemplate.mandatoryPackages;

    // Pastikan unik (bebas duplikat) dengan mengonversi ke Set lalu ke List
    final sortedList = packages.toSet().toList();

    sortedList.sort((a, b) {
      final indexA = mandatoryPackages.indexOf(a);
      final indexB = mandatoryPackages.indexOf(b);

      final isMandatoryA = indexA != -1;
      final isMandatoryB = indexB != -1;

      // 1. Jika keduanya adalah paket wajib, urutkan sesuai posisi di mandatoryPackages
      if (isMandatoryA && isMandatoryB) {
        return indexA.compareTo(indexB);
      }
      // 2. Jika hanya A yang wajib, prioritaskan A di atas
      if (isMandatoryA) {
        return -1;
      }
      // 3. Jika hanya B yang wajib, prioritaskan B di atas
      if (isMandatoryB) {
        return 1;
      }

      // 4. Jika keduanya bukan paket wajib, urutkan secara alfabetis (A-Z)
      return a.compareTo(b);
    });

    return sortedList;
  }
}
