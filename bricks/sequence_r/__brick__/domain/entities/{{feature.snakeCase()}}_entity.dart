import 'package:freezed_annotation/freezed_annotation.dart';

part '{{feature.snakeCase()}}_entity.freezed.dart';

@freezed
abstract class {{feature.pascalCase()}}Entity with _${{feature.pascalCase()}}Entity {
  const factory {{feature.pascalCase()}}Entity({
    required int id,
    required String name,
    required String description,
    required String imageUrl,
    required double rating,
    required int reviewCount,
    required bool isPopular,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _{{feature.pascalCase()}}Entity;
}
