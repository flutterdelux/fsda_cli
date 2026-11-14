import '../../../core/extensions/sequence_param_x.dart';
import '../../../domain/enums/flow_type.dart';
import '../../../domain/params/sequence_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class RepositoryTemplate {
  static const markDsField = '// [_FIELD]';
  static const markDsParam = '// [_PARAM]';
  static const markDsInit = '// [_INIT]';

  static String interfaceClass(String feature) {
    final featurePascal = feature.pascalCase;
    final repoPascal = '${featurePascal}Repository';
    final content =
        '''
import 'package:app_core/app_core.dart';

abstract interface class $repoPascal {}
''';
    return content;
  }

  static String implClass(String feature) {
    final featurePascal = feature.pascalCase;

    final repoSnake = '${feature}_repository';
    final repoPascal = '${featurePascal}Repository';

    final content =
        '''
import 'package:app_core/app_core.dart';

import '../../domain/repositories/$repoSnake.dart';

class ${repoPascal}Impl
    with RepositoryExceptionHandler
    implements $repoPascal {
  final AppLogger _log;
  $markDsField

  const ${repoPascal}Impl({
    required AppLogger appLogger,
    $markDsParam
  }) : $markDsInit
       _log = appLogger;

  @override
  AppLogger get log => _log;
}
''';
    return content;
  }

  static String interfaceMethod(SequenceParam sequence) {
    final returnType = _buildReturn(
      flow: sequence.flow,
      entity: sequence.entity,
      isList: sequence.isList,
    );
    final param = _buildParam(sequence.param);
    return '  $returnType ${sequence.methodCamel}($param);';
  }

  static String implMethod({
    required SequenceParam sequence,
    required String body,
  }) {
    final returnType = _buildReturn(
      flow: sequence.flow,
      entity: sequence.entity,
      isList: sequence.isList,
    );
    final param = _buildParam(sequence.param);
    final modifier = _buildModifier(sequence.flow);
    final content =
        '''
  @override
  $returnType ${sequence.methodCamel}($param) $modifier{
${body.trimRight()}
  }
''';
    return content.trimRight();
  }
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

String _normalizeEntity(String? entity) => entity?.pascalCase ?? 'void';

String _buildModifier(FlowType flow) {
  return switch (flow) {
    .synchronous => '',
    .asynchronous => 'async ',
    .stream => 'async* ',
  };
}
