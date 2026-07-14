import 'package:freezed_annotation/freezed_annotation.dart';

part '{{feature.snakeCase()}}_{{slice.snakeCase()}}_param.freezed.dart';

@freezed
abstract class {{feature.pascalCase()}}{{slice.pascalCase()}}Param with _${{feature.pascalCase()}}{{slice.pascalCase()}}Param {
  const factory {{feature.pascalCase()}}{{slice.pascalCase()}}Param({required int id}) = _{{feature.pascalCase()}}{{slice.pascalCase()}}Param;
}
