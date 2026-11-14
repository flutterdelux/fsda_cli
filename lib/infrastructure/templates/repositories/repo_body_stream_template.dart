import '../../../core/extensions/sequence_param_x.dart';
import '../../../domain/params/sequence_param.dart';

abstract final class RepoBodyStreamTemplate {
  static String build(SequenceParam sequence) {
    if (sequence.isReturnParam) return _streamReturnParam(sequence);
    if (sequence.isReturn) return _streamReturn(sequence);
    throw Exception(
      'Model combination not support for stream flow. Available combination for stream: Only Return or Return+Param',
    );
  }

  static String _streamReturnParam(SequenceParam sequence) {
    final streamList = '''
      await for (final dtos in stream) {
        final entities = dtos.map((e) => e.toEntity()).toList();
        yield Result.success(entities);
      }
''';
    final streamMap = '''
      await for (final dto in stream) {
        final entity = dto.toEntity();
        yield Result.success(entity);
      }
''';
    return '''
    try {
      final request = ${sequence.requestPascal}.fromParam(param);
      final stream = ${sequence.dsVar}.${sequence.methodCamel}(request);
${(sequence.isList ? streamList : streamMap).trimRight()}
    } catch (e, st) {
      yield handleException('${sequence.methodCamel}', e, st);
    }
''';
  }

  static String _streamReturn(SequenceParam sequence) {
    final streamList = '''
      await for (final dtos in stream) {
        final entities = dtos.map((e) => e.toEntity()).toList();
        yield Result.success(entities);
      }
''';
    final streamMap = '''
      await for (final dto in stream) {
        final entity = dto.toEntity();
        yield Result.success(entity);
      }
''';
    return '''
    try {
      final stream = ${sequence.dsVar}.${sequence.methodCamel}();
${(sequence.isList ? streamList : streamMap).trimRight()}
    } catch (e, st) {
      yield handleException('${sequence.methodCamel}', e, st);
    }
''';
  }
}
