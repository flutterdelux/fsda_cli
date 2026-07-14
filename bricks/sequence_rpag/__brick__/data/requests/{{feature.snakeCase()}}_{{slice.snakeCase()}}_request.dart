import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/params/{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.dart';

part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_request.freezed.dart';
part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_request.g.dart';

@freezed
abstract class {{feature.pascalCase()}}{{slice.pascalCase()}}Request with _${{feature.pascalCase()}}{{slice.pascalCase()}}Request {
  const {{feature.pascalCase()}}{{slice.pascalCase()}}Request._();

  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}Request({required int page, required int pageSize}) =
      _{{feature.pascalCase()}}{{slice.pascalCase()}}Request;

  factory {{feature.pascalCase()}}{{slice.pascalCase()}}Request.fromJson(Map<String, Object?> json) =>
      _${{feature.pascalCase()}}{{slice.pascalCase()}}RequestFromJson(json);

  factory {{feature.pascalCase()}}{{slice.pascalCase()}}Request.fromParam({{feature.pascalCase()}}{{slice.pascalCase()}}Param param) {
    return {{feature.pascalCase()}}{{slice.pascalCase()}}Request(page: param.page, pageSize: param.pageSize);
  }
}
