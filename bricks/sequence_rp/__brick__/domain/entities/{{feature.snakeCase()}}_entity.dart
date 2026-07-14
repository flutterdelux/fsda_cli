import 'package:freezed_annotation/freezed_annotation.dart';

part '{{feature.snakeCase()}}_entity.freezed.dart';

@freezed
abstract class {{feature.pascalCase()}}Entity with _${{feature.pascalCase()}}Entity {
  const factory {{feature.pascalCase()}}Entity({
    required int id,
    required String name,
    required double price,
    required String description,
    required int stock,
    required String imageUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _{{feature.pascalCase()}}Entity;
}
