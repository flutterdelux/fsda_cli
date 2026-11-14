import '../enums/ds_mode.dart';

class DsParam {
  final String featureName;
  final String featurePath;
  final String moduleName;
  final String modulePath;
  final DsMode mode;

  const DsParam({
    required this.featureName,
    required this.featurePath,
    required this.moduleName,
    required this.modulePath,
    required this.mode,
  });
}
