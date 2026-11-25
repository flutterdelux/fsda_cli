import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/models/prop_model.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../text_modifiers/string_extension.dart';

abstract final class ComposeRouteTemplate {
  static String buildConstant(ComposeParam param) {
    final targetBaseName = param.targetBaseName;
    return "  static const _${targetBaseName.camelCase} = '${targetBaseName.kebabCase}';";
  }

  static String buildRoute({
    required ComposeParam param,
    required List<PropModel> props,
  }) {
    final targetBaseName = param.targetBaseName;

    final argParams = props
        .map((p) {
          final fieldName = p.name.camelCase;
          return '            $fieldName: $fieldName,';
        })
        .join('\n');
    final buildParamExtractor = props
        .map((p) {
          final fieldName = p.name.camelCase;
          final isInt = p.type.contains('int');
          final valueParam = "state.pathParameters['${p.name}']";
          return '''
          final $fieldName = ${isInt ? 'int.tryParse($valueParam.toString())' : valueParam};
          if ($fieldName == null) return const NotFoundPage();

''';
        })
        .join('\n');
    final buildWidgetCall = props.isEmpty
        ? 'return const ${param.target.pascalCase}();'
        : '''
          ${buildParamExtractor.trim()}
          return ${param.target.pascalCase}(
            ${argParams.trim()}
          );
''';

    return '''
      GoRoute(
        path: '${targetBaseName.replaceAll('${param.featureName}_', '').kebabCase}',
        name: _${targetBaseName.camelCase},
        builder: (context, state) {
          ${buildWidgetCall.trim()}
        },
      )
''';
  }

  static String buildNavigation({
    required ComposeParam param,
    required List<PropModel> props,
  }) {
    final targetBaseName = param.targetBaseName;
    if (props.isEmpty) {
      return '''
  static Future<dynamic> to${targetBaseName.pascalCase}(BuildContext context) {
    return context.pushNamed(_${targetBaseName.camelCase});
  }
  ''';
    }
    final pathParamsMap =
        '{\n${props.map((p) => "        '${p.name}': '\$${p.name.camelCase}',").join('\n')}\n      }';
    return '''
  static Future<dynamic> to${targetBaseName.pascalCase}(
    BuildContext context, {
    ${props.map((p) => '    required ${p.type} ${p.name.camelCase}').join(',\n').trim()}
  }) {
    return context.pushNamed(
      _${targetBaseName.camelCase},
      ${props.isEmpty ? '' : 'pathParameters: $pathParamsMap'}
    );
  }
''';
  }
}
