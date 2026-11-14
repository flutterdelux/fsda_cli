import '../../core/constants/cli_info.dart';
import 'config_android_model.dart';

class ConfigModel {
  final String workspaceName;
  final String workspacePath;
  final String cliVersion;
  final List<String> activePackages;
  final String sdkVersion;
  final ConfigAndroidModel android;

  const ConfigModel({
    required this.workspaceName,
    required this.workspacePath,
    required this.cliVersion,
    this.activePackages = const [],
    this.sdkVersion = CliInfo.sdkVersion,
    this.android = const ConfigAndroidModel(),
  });
}
