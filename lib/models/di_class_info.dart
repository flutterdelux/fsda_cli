import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/di_class_type.dart';
import 'di_param.dart';

part 'di_class_info.freezed.dart';

@freezed
abstract class DiClassInfo with _$DiClassInfo {
  const factory DiClassInfo({
    required String className,
    String? interfaceName,
    required List<DiParam> parameters,
    required DiClassType? type,
    String? importPath,
  }) = _DiClassInfo;
}
