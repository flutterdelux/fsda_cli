import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/{{feature.snakeCase()}}_entity.dart';

part '{{feature.snakeCase()}}_dto.freezed.dart';
part '{{feature.snakeCase()}}_dto.g.dart';

@freezed
abstract class {{feature.pascalCase()}}Dto with _${{feature.pascalCase()}}Dto {
  const {{feature.pascalCase()}}Dto._();

  const factory {{feature.pascalCase()}}Dto({
    required int id,
    required String name,
    required double price,
    required String description,
    required int stock,
    required String imageUrl,
    @UtcDateTimeConverter() required DateTime createdAt,
    @UtcDateTimeConverter() required DateTime updatedAt,
  }) = _{{feature.pascalCase()}}Dto;

  factory {{feature.pascalCase()}}Dto.fromJson(Map<String, Object?> json) =>
      _${{feature.pascalCase()}}DtoFromJson(json);

  {{feature.pascalCase()}}Entity toEntity() {
    return {{feature.pascalCase()}}Entity(
      id: id,
      name: name,
      price: price,
      description: description,
      stock: stock,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
