import '../../../core/extensions/sequence_param_x.dart';
import '../../../domain/enums/flow_type.dart';
import '../../../domain/params/sequence_param.dart';

abstract final class LocalDsBodyTemplate {
  static String build(SequenceParam sequence) {
    if (sequence.flow == .stream) {
      throw Exception('Stream not supported yet for local data source.');
    }

    // Async or Sync
    if (sequence.isReturn) return _buildReturn(sequence);
    if (sequence.isParam) return _buildParam(sequence);
    if (sequence.isVoid) return _buildVoid(sequence);
    throw Exception(
      'Model combination not valid for local storage: Available combinations: Return, Param, Void',
    );
  }
}

String _buildReturn(SequenceParam sequence) {
  final isSync = sequence.flow == FlowType.synchronous;
  final awaitKeyword = isSync ? '' : 'await ';

  return '''
    final jsonString = ${awaitKeyword}_localStorage.${sequence.localStorageMethod}(_cacheKey);
    if (jsonString == null || jsonString is! String) {
      return null;
    }
    
${_convertJsonDto(sequence)}
''';
}

String _buildParam(SequenceParam sequence) {
  final isSync = sequence.flow == FlowType.synchronous;
  final awaitKeyword = isSync ? '' : 'await ';

  return '''
    final jsonString = jsonEncode(request.toJson());
    ${awaitKeyword}_localStorage.${sequence.localStorageMethod}(_cacheKey, jsonString);
''';
}

String _buildVoid(SequenceParam sequence) {
  final isSync = sequence.flow == FlowType.synchronous;
  final awaitKeyword = isSync ? '' : 'await ';

  return '''
    ${awaitKeyword}_localStorage.${sequence.localStorageMethod}(_cacheKey);
''';
}

String _convertJsonDto(SequenceParam sequence) {
  if (sequence.isList) {
    return '''
      final jsonList = jsonDecode(jsonString);
      if (jsonList is! List) return null;

      return jsonList.map((e) => ${sequence.dtoPascal}.fromJson(e as Map<String, dynamic>)).toList();
''';
  }
  return '''
      final jsonMap = jsonDecode(jsonString);
      if (jsonMap is! Map) return null;

      return ${sequence.dtoPascal}.fromJson(jsonMap as Map<String, dynamic>);
''';
}
