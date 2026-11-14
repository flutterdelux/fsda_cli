import '../../domain/enums/uc_type.dart';

extension UcTypeX on UcType {
  bool get hasReturn => switch (this) {
    UcType.returnParamStreamUc ||
    UcType.returnParamSyncUc ||
    UcType.returnParamUc ||
    UcType.returnStreamUc ||
    UcType.returnSyncUc ||
    UcType.returnUc => true,
    _ => false,
  };

  bool get hasParam => switch (this) {
    UcType.paramStreamUc ||
    UcType.paramSyncUc ||
    UcType.paramUc ||
    UcType.returnParamStreamUc ||
    UcType.returnParamSyncUc ||
    UcType.returnParamUc => true,
    _ => false,
  };

  bool get isAsync => switch (this) {
    UcType.returnParamUc ||
    UcType.returnUc ||
    UcType.paramUc ||
    UcType.voidUc => true,
    _ => false,
  };

  bool get isStream => switch (this) {
    UcType.voidStreamUc ||
    UcType.paramStreamUc ||
    UcType.returnStreamUc ||
    UcType.returnParamStreamUc => true,
    _ => false,
  };
}
