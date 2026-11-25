import '../../core/constants/app_config.dart';
import '../../core/constants/cli_info.dart';

abstract final class ConfigTemplate {
  static const mandatoryPackages = [
    'app_core',
    'app_l10n',
    'app_ui',
    'infra_logging',
  ];

  static String buildConfig({
    required String workspaceName,
    required List<String> packages,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('''
name: $workspaceName

fsda_cli: "${CliInfo.version}"

# Dart SDK for pubspec in (packages, modules, apps)
dart_sdk: ${CliInfo.dartSdk}

android:
  min_sdk: ${AppConfig.androidMinSdk}
  target_sdk: ${AppConfig.androidTargetSdk}
  compile_sdk: ${AppConfig.androidCompileSdk}

# app_core, app_l10n, and app_ui are mandatory for some generation like gen-module
packages:''');

    for (final pkg in mandatoryPackages) {
      if (packages.contains(pkg)) {
        buffer.writeln('  - $pkg');
      }
    }

    return buffer.toString();
  }
}
