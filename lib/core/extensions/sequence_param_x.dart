import 'package:path/path.dart' as p;

import '../../domain/params/sequence_param.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'feature_gate_param_x.dart';

extension SequenceParamX on SequenceParam {
  String get featureBarrelPath =>
      p.join(featurePath, '${featureSnake}_feature.dart');

  bool get hasEntity => entity != null;
  bool get hasDto => dto != null;
  bool get hasParam => param != null;
  bool get hasRequest => request != null;
  bool get hasResponse => response != null;

  bool get hasReturnModel => hasEntity && hasDto;
  bool get hasParamModel => hasParam && hasRequest;

  bool get isVoid => !hasReturnModel && !hasParamModel;
  bool get isParam => !hasReturnModel && hasParamModel;
  bool get isReturn => hasReturnModel && !hasParamModel;
  bool get isReturnParam => hasReturnModel && hasParamModel;

  String get ucSnake => usecase;
  String get ucCamel => ucSnake.camelCase;
  String get ucPascal => ucSnake.pascalCase;

  String get ucBaseSnake => usecase.endsWith('_use_case')
      ? usecase.replaceAll('_use_case', '')
      : usecase;
  String get ucBaseCamel => ucBaseSnake.camelCase;
  String get ucBasePascal => ucBaseSnake.pascalCase;

  String get methodSnake => method;
  String get methodCamel => methodSnake.camelCase;
  String get methodPascal => methodSnake.pascalCase;
  String get methodTitle => methodSnake.titleCase;

  // Model

  String? get responseSnake => response;
  String? get responseCamel => responseSnake?.camelCase;
  String? get responsePascal => responseSnake?.pascalCase;

  String? get dtoSnake => dto;
  String? get dtoCamel => dtoSnake?.camelCase;
  String? get dtoPascal => dtoSnake?.pascalCase;

  String? get entitySnake => entity;
  String? get entityCamel => entitySnake?.camelCase;
  String? get entityPascal => entitySnake?.pascalCase;

  String? get requestSnake => request;
  String? get requestCamel => requestSnake?.camelCase;
  String? get requestPascal => requestSnake?.pascalCase;

  String? get paramSnake => param;
  String? get paramCamel => paramSnake?.camelCase;
  String? get paramPascal => paramSnake?.pascalCase;

  String get dsVar =>
      dsMode == .remote ? '_remoteDataSource' : '_localDataSource';

  String get localStorageMethod => switch (action) {
    .post || .put || .patch => 'write',
    .get => 'read',
    .delete => 'remove',
  };

  String get apiClientMethod => switch (action) {
    .post => 'post<Map<String, dynamic>>',
    .get =>
      flow == .stream
          ? 'stream<Map<String, dynamic>>'
          : 'get<Map<String, dynamic>>',
    .put => 'put<Map<String, dynamic>>',
    .patch => 'patch<Map<String, dynamic>>',
    .delete => 'delete',
  };

  bool get useBodyRequest => switch (action) {
    .post || .put || .patch => true,
    _ => false,
  };
  bool get useQueryParam => switch (action) {
    .get => true,
    _ => false,
  };

  int get httpStatus => switch (action) {
    .post => 201,
    .get => 200,
    .put => 200,
    .patch => 200,
    .delete => 204,
  };

  String get dsInterfacePath {
    return p.join(
      featurePath,
      'data',
      'datasources',
      '${featureSnake}_${dsMode.value}_data_source.dart',
    );
  }

  String get dsImplPath {
    return p.join(
      featurePath,
      'data',
      'datasources',
      '${featureSnake}_${dsMode.value}_data_source_impl.dart',
    );
  }

  String get repoInterfacePath {
    return p.join(
      featurePath,
      'domain',
      'repositories',
      '${featureSnake}_repository.dart',
    );
  }

  String get repoImplPath {
    return p.join(
      featurePath,
      'data',
      'repositories',
      '${featureSnake}_repository_impl.dart',
    );
  }
}
