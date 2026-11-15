import '../../../core/extensions/logic_flow_param_x.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/params/logic_flow_param.dart';

abstract final class StateFlowTemplate {
  static ArtifactGenerationModel build(LogicFlowParam logic) {
    return ArtifactGenerationModel(
      name: logic.statePascal,
      path: logic.statePath,
      content: switch (logic.type) {
        .mutation => _mutationState(logic),
        .retrieval => _retrievalState(logic),
        .pagination => _paginationState(logic),
      },
      typesToImport: {?logic.uc.paramType, ?logic.uc.returnType},
      needToExport: true,
    );
  }
}

String _paginationState(LogicFlowParam logic) {
  // Ambil tipe list data dari returnType usecase (misal: List<NoteEntity> atau NoteEntity)
  // Jika returnType berupa List<T>, ambil T atau gunakan dynamic
  final returnType = logic.uc.returnType ?? 'dynamic';

  final props =
      '''
    @Default([]) $returnType data,
    @Default(false) bool hasReachedMax,
    @Default(false) bool isLoading,
    Failure? failure,
    @Default(${logic.uc.paramType ?? 'Object'}()) ${logic.uc.paramType ?? 'Object'} param,
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

String _mutationState(LogicFlowParam logic) {
  return '''
import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${logic.stateSnake}.freezed.dart';

@freezed
sealed class ${logic.statePascal} with _\$${logic.statePascal} {
  const factory ${logic.statePascal}.initial() = _Initial;
  const factory ${logic.statePascal}.loading() = _Loading;
  const factory ${logic.statePascal}.success(${_propState(logic)}) = _Success;
  const factory ${logic.statePascal}.failure({required Failure failure}) = _Failure;
}
''';
}

String _retrievalState(LogicFlowParam logic) {
  return '''
import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${logic.stateSnake}.freezed.dart';

@freezed
sealed class ${logic.statePascal} with _\$${logic.statePascal} {
  const factory ${logic.statePascal}.initial() = _Initial;
  const factory ${logic.statePascal}.loading() = _Loading;
  const factory ${logic.statePascal}.loaded(${_propState(logic)}) = _Loaded;
  const factory ${logic.statePascal}.failure({required Failure failure}) = _Failure;
}
''';
}

String _propState(LogicFlowParam logic) {
  final uc = logic.uc;
  if (uc.returnType == null) return '';
  final propUc = [
    if (!uc.returnType!.endsWith('?')) 'required',
    uc.returnType,
    'data',
  ].join(' ');
  return "{$propUc}";
}
