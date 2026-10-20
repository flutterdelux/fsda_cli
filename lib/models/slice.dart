import 'package:freezed_annotation/freezed_annotation.dart';

part 'slice.freezed.dart';

@freezed
abstract class Slice with _$Slice {
  const factory Slice({
    /// r, rp, m, mp, etc
    required String mode,

    /// slice name
    required String name,
    required String feature,
    required String module,

    /// use camelCase
    required String method,

    /// modelling use snake_case
    String? param,
    String? request,
    String? entity,
    String? dto,

    /// for retrieval
    @Default(false) bool returnList,
  }) = _Slice;
}
