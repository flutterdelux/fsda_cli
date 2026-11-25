import '../../domain/params/gen_app_param.dart';

extension GenAppParamX on GenAppParam {
  String get projectId => appName.replaceAll('_', '').toLowerCase();
}
