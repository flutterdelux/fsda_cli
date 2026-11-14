import 'ds_param.dart';

class RemoteDsParam extends DsParam {
  final String basePath;

  const RemoteDsParam({
    required super.featureName,
    required super.featurePath,
    required super.moduleName,
    required super.modulePath,
    required this.basePath,
  }) : super(mode: .remote);
}
