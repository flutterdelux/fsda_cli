import 'ds_param.dart';

class LocalDsParam extends DsParam {
  final String cacheKey;

  const LocalDsParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required this.cacheKey,
  }) : super(mode: .local);
}
