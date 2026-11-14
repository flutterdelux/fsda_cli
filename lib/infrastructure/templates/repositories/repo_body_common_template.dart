import '../../../core/extensions/sequence_param_x.dart';
import '../../../domain/enums/flow_type.dart';
import '../../../domain/params/sequence_param.dart';

abstract final class RepoBodyCommonTemplate {
  static String build(SequenceParam sequence) {
    if (sequence.isReturnParam) return _buildReturnParam(sequence);
    if (sequence.isReturn) return _buildReturn(sequence);
    if (sequence.isParam) return _buildParam(sequence);
    if (sequence.isVoid) return _buildVoid(sequence);
    throw Exception(
      'Model combination not valid for repo: Available combination: Return+Param, Return, Param, Void',
    );
  }

  static String _buildReturnParam(SequenceParam sequence) {
    final isSync = sequence.flow == FlowType.synchronous;
    final awaitKeyword = isSync ? '' : 'await ';

    final handleReturn = sequence.isList
        ? '''
      final dtos = $awaitKeyword${sequence.dsVar}.${sequence.methodCamel}(request);
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Result.success(entities);
'''
        : '''
      final dto = $awaitKeyword${sequence.dsVar}.${sequence.methodCamel}(request);
      final entity = dto.toEntity();
      return Result.success(entity);
''';

    return '''
    try {
      final request = ${sequence.requestPascal}.fromParam(param);
${handleReturn.trimRight()}
    } catch (e, st) {
      return handleException('${sequence.methodCamel}', e, st);
    }
''';
  }

  static String _buildReturn(SequenceParam sequence) {
    final isSync = sequence.flow == FlowType.synchronous;
    final awaitKeyword = isSync ? '' : 'await ';

    final handleReturn = sequence.isList
        ? '''
      final dtos = $awaitKeyword${sequence.dsVar}.${sequence.methodCamel}();
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Result.success(entities);
'''
        : '''
      final dto = $awaitKeyword${sequence.dsVar}.${sequence.methodCamel}();
      final entity = dto.toEntity();
      return Result.success(entity);
''';

    return '''
    try {
${handleReturn.trimRight()}
    } catch (e, st) {
      return handleException('${sequence.methodCamel}', e, st);
    }
''';
  }

  static String _buildParam(SequenceParam sequence) {
    final isSync = sequence.flow == FlowType.synchronous;
    final awaitKeyword = isSync ? '' : 'await ';

    return '''
    try {
      final request = ${sequence.requestPascal}.fromParam(param);
      $awaitKeyword${sequence.dsVar}.${sequence.methodCamel}(request);
      return const Result.success(null);
    } catch (e, st) {
      return handleException('${sequence.methodCamel}', e, st);
    }
''';
  }

  static String _buildVoid(SequenceParam sequence) {
    final isSync = sequence.flow == FlowType.synchronous;
    final awaitKeyword = isSync ? '' : 'await ';

    return '''
    try {
      $awaitKeyword${sequence.dsVar}.${sequence.methodCamel}();
      return const Result.success(null);
    } catch (e, st) {
      return handleException('${sequence.methodCamel}', e, st);
    }
''';
  }
}
