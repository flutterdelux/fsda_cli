import '../../../core/extensions/logic_flow_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/logic_uc_model.dart';
import '../../../domain/params/logic_flow_param.dart';

abstract final class StateFlowTemplate {
  static ArtifactGenerationModel build({
    required LogicFlowParam logic,
    required LogicUcModel uc,
  }) {
    return ArtifactGenerationModel(
      name: logic.statePascal,
      path: logic.statePath,
      content: switch (logic.type) {
        .mutation => _mutationState(logic: logic, logicUc: uc),
        .retrieval => _retrievalState(logic: logic, logicUc: uc),
        .pagination => _paginationState(logic: logic, uc: uc),
      },
      typesToImport: {?uc.paramType, ?uc.returnType},
      needToExport: true,
    );
  }
}

String _paginationState({
  required LogicFlowParam logic,
  required LogicUcModel uc,
}) {
  // Ambil tipe list data dari returnType usecase (misal: List<NoteEntity> atau NoteEntity)
  // Jika returnType berupa List<T>, ambil T atau gunakan dynamic
  final returnType = uc.returnType ?? 'dynamic';

  final props =
      '''
    @Default([]) $returnType data,
    @Default(false) bool hasReachedMax,
    @Default(false) bool isLoading,
    Failure? failure,
    @Default(${uc.paramType ?? 'Object'}()) ${uc.paramType ?? 'Object'} param,
''';

  return '''
import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${logic.stateSnake}.freezed.dart';

@freezed
abstract class ${logic.statePascal} with _\$${logic.statePascal} {
  const factory ${logic.statePascal}({
    ${props.trim()}
  }) = _${logic.statePascal};
}
''';
}

String _mutationState({
  required LogicFlowParam logic,
  required LogicUcModel logicUc,
}) {
  return '''
import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${logic.stateSnake}.freezed.dart';

@freezed
sealed class ${logic.statePascal} with _\$${logic.statePascal} {
  const factory ${logic.statePascal}.initial() = _Initial;
  const factory ${logic.statePascal}.loading() = _Loading;
  const factory ${logic.statePascal}.success(${_propState(logicUc)}) = _Success;
  const factory ${logic.statePascal}.failure({required Failure failure}) = _Failure;
}
''';
}

String _retrievalState({
  required LogicFlowParam logic,
  required LogicUcModel logicUc,
}) {
  return '''
import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${logic.stateSnake}.freezed.dart';

@freezed
sealed class ${logic.statePascal} with _\$${logic.statePascal} {
  const factory ${logic.statePascal}.initial() = _Initial;
  const factory ${logic.statePascal}.loading() = _Loading;
  const factory ${logic.statePascal}.loaded(${_propState(logicUc)}) = _Loaded;
  const factory ${logic.statePascal}.failure({required Failure failure}) = _Failure;
}
''';
}

String _propState(LogicUcModel uc) {
  if (uc.returnType == null) return '';
  final propUc = [
    if (!uc.returnType!.endsWith('?')) 'required',
    uc.returnType,
    'data',
  ].join(' ');
  return "{$propUc}";
}
