import '../../core/extensions/failure_param_x.dart';
import '../../core/extensions/module_gate_param_x.dart';
import '../../domain/params/failure_param.dart';

abstract final class FailureTemplate {
  static String startDividerArbKey() => "failureStartDivider";
  static String endDividerArbKey() => "failureEndDivider";

  static String buildFactory(FailureParam failure) {
    return '''
  const factory ${failure.modulePascal}Exception.${failure.nameCamel}({
    String? msg,
    StackTrace? st,
  }) = _${failure.namePascal};
''';
  }

  static String buildMessage(FailureParam failure) {
    return "${failure.nameCamel}: (msg, _) => msg ?? '${failure.message}'";
  }

  static String buildToFailure(FailureParam failure) {
    return '${failure.nameCamel}: (msg, _) => ${failure.modulePascal}Failure.${failure.nameCamel}';
  }

  static String buildCodeResponse(FailureParam failure) {
    return '''
        '${failure.nameCode}' => ${failure.modulePascal}Exception.${failure.nameCamel}(
          msg: message,
          st: st,
        ),
''';
  }

  static String buildEnumValue(FailureParam failure) {
    return '${failure.nameCamel},';
  }

  static String buildItemLocalizeX(FailureParam failure) {
    return '${failure.modulePascal}Failure.${failure.nameCamel} => l10n.failure${failure.namePascal}';
  }

  static Map<String, dynamic> buildArbEntries(FailureParam failure) {
    final entries = <String, dynamic>{};
    entries['failure${failure.namePascal}'] = failure.message;
    return entries;
  }
}
