import '../../../core/extensions/sequence_param_x.dart';
import '../../../domain/enums/ds_mode.dart';
import '../../../domain/enums/flow_type.dart';
import '../../../domain/params/sequence_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class DataSourceTemplate {
  static String interfaceClass({
    required String feature,
    required DsMode mode,
  }) {
    final featurePascal = feature.pascalCase;
    final modePascal = mode.value.pascalCase;
    final dsPascal = '$featurePascal${modePascal}DataSource';
    final content =
        '''
abstract interface class $dsPascal {}
''';
    return content;
  }

  static String remoteImplClass({
    required String feature,
    required String basePath,
  }) {
    final featurePascal = feature.pascalCase;

    final dsSnake = '${feature}_remote_data_source';
    final dsPascal = '${featurePascal}RemoteDataSource';

    final content =
        '''import 'package:app_core/app_core.dart';

import '$dsSnake.dart';

class ${dsPascal}Impl implements $dsPascal {
  static const _basePath = '$basePath';

  final ApiClient _apiClient;

  const ${dsPascal}Impl({required ApiClient apiClient})
    : _apiClient = apiClient;
}
''';
    return content;
  }

  static String localImplClass({
    required String feature,
    required String cacheKey,
  }) {
    final featurePascal = feature.pascalCase;

    final dsSnake = '${feature}_local_data_source';
    final dsPascal = '${featurePascal}LocalDataSource';

    final content =
        '''
import 'package:app_core/app_core.dart';

import '$dsSnake.dart';

class ${dsPascal}Impl implements $dsPascal {
  static const _cacheKey = '$cacheKey';

  final LocalStorage _localStorage;

  const ${dsPascal}Impl({
    required LocalStorage localStorage,
  }) : _localStorage = localStorage;  

}
''';
    return content;
  }

  static String interfaceMethod(SequenceParam sequence) {
    final returnType = _buildReturn(
      flowType: sequence.flow,
      dto: sequence.dto,
      isList: sequence.isList,
    );
    final request = _buildRequest(sequence.request);
    return '  $returnType ${sequence.methodCamel}($request);';
  }

  static String implMethod({
    required SequenceParam sequence,
    required String body,
  }) {
    final returnType = _buildReturn(
      flowType: sequence.flow,
      dto: sequence.dto,
      isList: sequence.isList,
    );
    final request = _buildRequest(sequence.request);
    final modifier = _buildModifier(sequence.flow);
    final content =
        '''
  @override
  $returnType ${sequence.methodCamel}($request) $modifier{
${body.trimRight()}
  }
''';
    return content.trimRight();
  }
}

String _buildReturn({
  required FlowType flowType,
  required String? dto,
  required bool isList,
}) {
  final dtoPascal = dto?.pascalCase;
  return switch (flowType) {
    .synchronous => [
      if (isList) 'List<',
      dtoPascal ?? 'void',
      if (isList) '>',
    ].join(''),
    .asynchronous => [
      'Future<',
      if (isList) 'List<',
      dtoPascal ?? 'void',
      if (isList) '>',
      '>',
    ].join(''),
    .stream => [
      'Stream<',
      if (isList) 'List<',
      dtoPascal ?? 'void',
      if (isList) '>',
      '>',
    ].join(''),
  };
}

String _buildRequest(String? request) {
  final requestPascal = request?.pascalCase;
  if (request == null) return '';
  return '$requestPascal request';
}

String _buildModifier(FlowType methodType) {
  return switch (methodType) {
    .synchronous => '',
    .asynchronous => 'async ',
    .stream => 'async* ',
  };
}
