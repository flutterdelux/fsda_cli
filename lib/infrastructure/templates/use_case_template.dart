import '../../core/extensions/feature_param_x.dart';
import '../../core/extensions/sequence_param_x.dart';
import '../../domain/enums/flow_type.dart';
import '../../domain/params/sequence_param.dart';
import '../text_modifiers/string_extension.dart';

abstract final class UseCaseTemplate {
  static String build({required SequenceParam sequence}) {
    final returnType = _buildReturn(
      flow: sequence.flow,
      entity: sequence.entity,
      isList: sequence.isList,
    );

    final param = _buildParam(sequence.param);
    final paramArg = _buildParamArg(sequence.param);

    final extendsUseCase = _buildExtensUseCase(
      flow: sequence.flow,
      entity: sequence.entity,
      isList: sequence.isList,
      param: sequence.param,
    );

    return '''import 'package:app_core/app_core.dart';
import '../repositories/${sequence.featureSnake}_repository.dart';

class ${sequence.ucPascal} extends $extendsUseCase {
  final ${sequence.featurePascal}Repository _repository;

  const ${sequence.ucPascal}({required ${sequence.featurePascal}Repository ${sequence.featureCamel}Repository})
    : _repository = ${sequence.featureCamel}Repository;

  @override
  $returnType call($param) {
    return _repository.${sequence.methodCamel}($paramArg);
  }
}
''';
  }

  static Map<String, dynamic> buildArbEntries(SequenceParam sequence) {
    final entries = <String, dynamic>{};

    entries['${sequence.ucBaseCamel}Action'] = sequence.methodTitle;
    entries['${sequence.ucBaseCamel}Success'] =
        '${sequence.methodTitle} Successfull';

    return entries;
  }
}

String _buildExtensUseCase({
  required FlowType flow,
  required String? entity,
  required bool isList,
  required String? param,
}) {
  final paramPascal = param?.pascalCase;
  final entityOrWithList = isList
      ? 'List<${entity?.pascalCase}>'
      : entity?.pascalCase;
  return switch (flow) {
    .asynchronous =>
      entity != null && param != null
          ? 'ReturnParamUseCase<$entityOrWithList, $paramPascal>'
          : entity != null
          ? 'ReturnUseCase<$entityOrWithList>'
          : param != null
          ? 'ParamUseCase<$paramPascal>'
          : 'VoidUseCase',
    .synchronous =>
      entity != null && param != null
          ? 'ReturnParamSyncUseCase<$entityOrWithList, $paramPascal>'
          : entity != null
          ? 'ReturnSyncUseCase<$entityOrWithList>'
          : param != null
          ? 'ParamSyncUseCase<$paramPascal>'
          : 'VoidSyncUseCase',
    .stream =>
      entity != null && param != null
          ? 'ReturnParamStreamUseCase<$entityOrWithList, $paramPascal>'
          : entity != null
          ? 'ReturnStreamUseCase<$entityOrWithList>'
          : param != null
          ? 'ParamStreamUseCase<$paramPascal>'
          : 'VoidStreamUseCase',
  };
}

String _buildReturn({
  required FlowType flow,
  required String? entity,
  required bool isList,
}) {
  return switch (flow) {
    .synchronous => [
      'Result<',
      if (isList) 'List<',
      _normalizeEntity(entity),
      if (isList) '>',
      '>',
    ].join(''),
    .asynchronous => [
      'AsyncResult<',
      if (isList) 'List<',
      _normalizeEntity(entity),
      if (isList) '>',
      '>',
    ].join(''),
    .stream => [
      'StreamResult<',
      if (isList) 'List<',
      _normalizeEntity(entity),
      if (isList) '>',
      '>',
    ].join(''),
  };
}

String _buildParam(String? param) {
  if (param == null) return '';
  return '${param.pascalCase} param';
}

String _buildParamArg(String? param) {
  return param != null ? 'param' : '';
}

String _normalizeEntity(String? entity) => entity?.pascalCase ?? 'void';
