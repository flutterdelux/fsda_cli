import '../../../core/extensions/feature_gate_param_x.dart';
import '../../../core/extensions/module_gate_param_x.dart';
import '../../../core/extensions/sequence_param_x.dart';
import '../../../domain/params/sequence_param.dart';

abstract final class RemoteDsBodyAsyncTemplate {
  static String build(SequenceParam sequence) {
    if (sequence.isReturnParam) return _asyncReturnParam(sequence);
    if (sequence.isReturn) return _asyncReturn(sequence);
    if (sequence.isParam) return _asyncParam(sequence);
    if (sequence.isVoid) return _asyncVoid(sequence);
    throw Exception(
      'Model combination not valid: Available combination for async: Return+Param, Return, Param, Void',
    );
  }
}

String _asyncReturnParam(SequenceParam sequence) {
  final queryParamStr = sequence.useBodyRequest
      ? 'body: request.toJson(),'
      : sequence.useQueryParam
      ? 'queryParameters: request.toJson(),'
      : '';

  return '''
    final path = '\$_basePath/\${request.id}';
    final apiResponse = await _apiClient.${sequence.apiClientMethod}(
      path,
      $queryParamStr
    );

    if (apiResponse.statusCode == ${sequence.httpStatus}) {
${_handleReturnData(sequence).trimRight()}

      throw CoreException.serverError(
        msg: '${sequence.featureTitle} is null',
        st: StackTrace.current,
      );
    }

    throw ${sequence.modulePascal}Exception.fromApiResponse(apiResponse, st: StackTrace.current);
''';
}

String _asyncReturn(SequenceParam sequence) {
  return '''
    final path = _basePath;
    final apiResponse = await _apiClient.${sequence.apiClientMethod}(path);

    if (apiResponse.statusCode == ${sequence.httpStatus}) {
${_handleReturnData(sequence).trimRight()}

      throw CoreException.serverError(
        msg: '${sequence.featureTitle} is null',
        st: StackTrace.current,
      );
    }

    throw ${sequence.modulePascal}Exception.fromApiResponse(apiResponse, st: StackTrace.current);
''';
}

String _asyncParam(SequenceParam sequence) {
  return '''
    final path = '\$_basePath/\${request.id}';
    final apiResponse = await _apiClient.${sequence.apiClientMethod}(
      path,
      body: request.toJson(),
    );
    if (apiResponse.statusCode == ${sequence.httpStatus}) return;
    throw ${sequence.modulePascal}Exception.fromApiResponse(apiResponse, st: StackTrace.current);
''';
}

String _asyncVoid(SequenceParam sequence) {
  return '''
    final path = _basePath;
    final apiResponse = await _apiClient.${sequence.apiClientMethod}(path);
    if (apiResponse.statusCode == ${sequence.httpStatus}) return;
    throw ${sequence.modulePascal}Exception.fromApiResponse(apiResponse, st: StackTrace.current);
''';
}

String _handleReturnData(SequenceParam sequence) {
  if (sequence.response != null) {
    return _convertResponseDto(sequence);
  }
  return _convertDirectDto(sequence);
}

String _convertResponseDto(SequenceParam sequence) {
  return '''
      final response = ${sequence.responsePascal}.fromJson(apiResponse.body);
      if (response.data != null) return response.data!;
''';
}

String _convertDirectDto(SequenceParam sequence) {
  if (sequence.isList) {
    return '''
      final data = apiResponse.body['data'];
      if (data is List) {
        return data
            .map((item) => ${sequence.dtoPascal}.fromJson(item as Map<String, dynamic>))
            .toList();
      }
''';
  }
  return '''
      final data = apiResponse.body['data'];
      if (data is Map) {
        return ${sequence.dtoPascal}.fromJson(data as Map<String, dynamic>);
      }
''';
}
