import 'package:freezed_annotation/freezed_annotation.dart';

part '{{feature.snakeCase()}}_entity.freezed.dart';

@freezed
abstract class {{feature.pascalCase()}}Entity with _${{feature.pascalCase()}}Entity {
  const factory {{feature.pascalCase()}}Entity({
    required String id,
    required String userId,
    required double amount,
    required String currency,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _{{feature.pascalCase()}}Entity;
}
