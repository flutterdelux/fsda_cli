import 'package:freezed_annotation/freezed_annotation.dart';

part 'di_param.freezed.dart';

@freezed
abstract class DiParam with _$DiParam {
  const factory DiParam({
    required String name,
    required bool isNamed,
    String? typeName,
  }) = _DiParam;
}
