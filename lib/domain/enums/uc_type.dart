import 'package:collection/collection.dart';

enum UcType {
  voidUc('VoidUseCase'),
  paramUc('ParamUseCase'),
  returnUc('ReturnUseCase'),
  returnParamUc('ReturnParamUseCase'),
  voidSyncUc('VoidSyncUseCase'),
  paramSyncUc('ParamSyncUseCase'),
  returnSyncUc('ReturnSyncUseCase'),
  returnParamSyncUc('ReturnParamSyncUseCase'),
  voidStreamUc('VoidStreamUseCase'),
  paramStreamUc('ParamStreamUseCase'),
  returnStreamUc('ReturnStreamUseCase'),
  returnParamStreamUc('ReturnParamStreamUseCase');

  final String value;

  const UcType(this.value);

  static UcType? fromValue(String value) {
    return values.firstWhereOrNull((e) => e.value == value);
  }
}
