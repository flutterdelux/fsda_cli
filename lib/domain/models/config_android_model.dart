import '../../core/constants/app_config.dart';

class ConfigAndroidModel {
  final int minSdk;
  final int targetSdk;
  final int compileSdk;

  const ConfigAndroidModel({
    this.minSdk = AppConfig.androidMinSdk,
    this.targetSdk = AppConfig.androidTargetSdk,
    this.compileSdk = AppConfig.androidCompileSdk,
  });
}
