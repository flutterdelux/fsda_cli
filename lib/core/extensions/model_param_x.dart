import 'package:path/path.dart' as p;

import '../../domain/params/model_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'feature_param_x.dart';

extension ModelParamX on ModelParam {
  String get nameSnake => modelName;
  String get nameCamel => nameSnake.camelCase;
  String get namePascal => nameSnake.pascalCase;
  String get nameTitle => nameSnake.titleCase;

  List<String> get _parts => modelName.split('_');
  String get baseNameSnake => _parts.sublist(0, _parts.length - 1).join('_');
  String get baseNameCamel => baseNameSnake.camelCase;
  String get baseNamePascal => baseNameSnake.pascalCase;
  String get baseNameTitle => baseNameSnake.titleCase;

  String get modelPath => p.join(featurePath, switch (type) {
    .entity => 'domain/entities',
    .param => 'domain/params',
    .dto => 'data/dtos',
    .request => 'data/requests',
    .response => 'data/responses',
  }, '$nameSnake.dart');
}
