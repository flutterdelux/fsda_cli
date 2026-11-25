import '../../../core/extensions/feature_param_x.dart';
import '../../../core/extensions/module_param_x.dart';
import '../../../core/extensions/sequence_param_x.dart';
import '../../../domain/params/sequence_param.dart';

abstract final class RemoteDsBodyStreamTemplate {
  static String build(SequenceParam sequence) {
    if (sequence.isReturnParam) return _streamReturnParam(sequence);
    if (sequence.isReturn) return _streamReturn(sequence);
    throw Exception(
      'Model combination not support for stream flow. Available combination for stream: Only Return or Return+Param',
    );
  }
}

String _streamReturnParam(SequenceParam sequence) {
  final streamList =
      '''
      await for (final data in _apiClient.stream<List>(path)) {
        yield data.map((e) => ${sequence.dtoPascal}.fromJson(e as Map<String, dynamic>)).toList();
      }
''';
  final streamMap =
      '''
      await for (final data in _apiClient.stream<Map<String, dynamic>>(path)) {
        yield ${sequence.dtoPascal}.fromJson(data);
      }
''';
  return '''
    final path = '\$_basePath/\${request.id}/stream';
    try {
${(sequence.isList ? streamList : streamMap).trimRight()}
    } catch (e, st) {
      if (e is AppException) {
        if (e.message.contains('404')) {
          throw ${sequence.modulePascal}Exception.${sequence.featureCamel}NotFound(msg: e.message, st: st);
        }
      }
      throw ${sequence.modulePascal}Exception.fromException(e, st: st);
    }
''';
}

String _streamReturn(SequenceParam sequence) {
  final streamList =
      '''
      await for (final data in _apiClient.stream<List>(path)) {
        yield data.map((e) => ${sequence.dtoPascal}.fromJson(e as Map<String, dynamic>)).toList();
      }
''';
  final streamMap =
      '''
      await for (final data in _apiClient.stream<Map<String, dynamic>>(path)) {
        yield ${sequence.dtoPascal}.fromJson(data);
      }
''';
  return '''
    final path = '\$_basePath/stream';
    try {
${(sequence.isList ? streamList : streamMap).trimRight()}
    } catch (e, st) {
      if (e is AppException) {
        if (e.message.contains('404')) {
          throw ${sequence.modulePascal}Exception.${sequence.featureCamel}NotFound(msg: e.message, st: st);
        }
      }
      throw ${sequence.modulePascal}Exception.fromException(e, st: st);
    }
''';
}
