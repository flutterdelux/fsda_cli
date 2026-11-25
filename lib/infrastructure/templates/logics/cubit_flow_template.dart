import '../../../core/extensions/logic_flow_param_x.dart';
import '../../../core/extensions/logic_uc_x.dart';
import '../../../core/extensions/uc_type_x.dart';
import '../../../domain/enums/logic_flow_type.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/logic_uc_model.dart';
import '../../../domain/params/logic_flow_param.dart';

abstract final class CubitFlowTemplate {
  static ArtifactGenerationModel build({
    required LogicFlowParam logic,
    required LogicUcModel uc,
  }) {
    return ArtifactGenerationModel(
      name: logic.controllerPascal,
      path: logic.controllerPath,
      content: uc.type.isStream
          ? _streamLogic(logic: logic, uc: uc)
          : switch (logic.type) {
              LogicFlowType.mutation => _mutationLogic(logic: logic, uc: uc),
              LogicFlowType.retrieval => _retrievalLogic(logic: logic, uc: uc),
              LogicFlowType.pagination => _paginationLogic(
                logic: logic,
                uc: uc,
              ),
            },
      typesToImport: {logic.statePascal, uc.ucPascal, ?uc.paramType},
      needToExport: true,
    );
  }
}

String _mutationLogic({
  required LogicFlowParam logic,
  required LogicUcModel uc,
}) {
  final hasParam = uc.type.hasParam;
  final hasReturn = uc.type.hasReturn;
  final isAsync = uc.type.isAsync;

  final paramType = uc.paramType;
  final callArg = hasParam ? 'param' : '';
  final methodParam = hasParam && paramType != null ? '$paramType param' : '';

  final returnTypeModifier = isAsync ? 'Future<void>' : 'void';
  final asyncModifier = isAsync ? 'async ' : '';
  final awaitKeyword = isAsync ? 'await ' : '';

  return '''import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends Cubit<${logic.statePascal}> {
  final ${uc.ucPascal} _${uc.ucCamel};

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
  })  : _${uc.ucCamel} = ${uc.ucCamel},
        super(const ${logic.statePascal}.initial());

  $returnTypeModifier ${uc.repoMethod}($methodParam) $asyncModifier{
    emit(const ${logic.statePascal}.loading());
    final result = ${awaitKeyword}_${uc.ucCamel}($callArg);
    emit(
      result.when(
        success: (data) => ${hasReturn ? '${logic.statePascal}.success(data: data)' : 'const ${logic.statePascal}.success()'},
        failure: (failure) => ${logic.statePascal}.failure(failure: failure),
      ),
    );
  }
}
''';
}

String _retrievalLogic({
  required LogicFlowParam logic,
  required LogicUcModel uc,
}) {
  final hasParam = uc.type.hasParam;
  final isAsync = uc.type.isAsync;

  final paramType = uc.paramType;

  // Jika retrieval memiliki parameter (misal: GetDetail berdasarkan ID/Param),
  // simpan sebagai field di dalam Cubit agar bisa dipakai ulang saat refresh/retry.
  final fieldParam = hasParam && paramType != null
      ? '  final $paramType _param;\n'
      : '';
  final constructorParam = hasParam && paramType != null
      ? '    required $paramType param,\n'
      : '';
  final assignmentParam = hasParam && paramType != null
      ? '    _param = param,\n'
      : '';
  final callArg = hasParam && paramType != null ? '_param' : '';

  // Method retrieval dibuat tanpa parameter karena parameter sudah di-inject via constructor
  final methodParam = '';

  final returnTypeModifier = isAsync ? 'Future<void>' : 'void';
  final asyncModifier = isAsync ? 'async' : '';
  final awaitKeyword = isAsync ? 'await ' : '';

  return '''import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends Cubit<${logic.statePascal}> {
  final ${uc.ucPascal} _${uc.ucCamel};
$fieldParam
  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
$constructorParam  })  : _${uc.ucCamel} = ${uc.ucCamel},
$assignmentParam    super(const ${logic.statePascal}.initial());

  $returnTypeModifier ${uc.repoMethod}($methodParam) $asyncModifier {
    emit(const ${logic.statePascal}.loading());
    final result = ${awaitKeyword}_${uc.ucCamel}($callArg);
    emit(
      result.when(
        success: (data) => ${logic.statePascal}.loaded(data: data),
        failure: (failure) => ${logic.statePascal}.failure(failure: failure),
      ),
    );
  }
}
''';
}

String _paginationLogic({
  required LogicFlowParam logic,
  required LogicUcModel uc,
}) {
  final isAsync = uc.type.isAsync;
  final awaitKeyword = isAsync ? 'await ' : '';

  return '''import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends Cubit<${logic.statePascal}> {
  final ${uc.ucPascal} _${uc.ucCamel};

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
  })  : _${uc.ucCamel} = ${uc.ucCamel},
        super(const ${logic.statePascal}());

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    await _getData(page: 1);
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasReachedMax) return;
    await _getData(page: state.param.page + 1);
  }

  Future<void> _getData({required int page}) async {
    emit(
      state.copyWith(
        isLoading: true,
        failure: null,
        data: page == 1 ? [] : state.data,
      ),
    );

    final selectedParam = state.param.copyWith(page: page);
    final result = ${awaitKeyword}_${uc.ucCamel}(selectedParam);

    emit(
      result.when(
        success: (data) => state.copyWith(
          data: [...state.data, ...data],
          hasReachedMax: data.length < state.param.pageSize,
          isLoading: false,
          param: selectedParam,
        ),
        failure: (failure) =>
            state.copyWith(isLoading: false, failure: failure),
      ),
    );
  }
}
''';
}

String _streamLogic({required LogicFlowParam logic, required LogicUcModel uc}) {
  final hasParam = uc.type.hasParam;

  final paramType = uc.paramType;
  final methodParam = hasParam && paramType != null ? '$paramType param' : '';

  final entityType = uc.returnType ?? 'dynamic';

  final fieldParam = hasParam && paramType != null
      ? '  final $paramType _param;\n'
      : '';
  final constructorParam = hasParam && paramType != null
      ? '    required $paramType param,\n'
      : '';
  final assignmentParam = hasParam && paramType != null
      ? '    _param = param,\n'
      : '';
  final listenCallArg = hasParam && paramType != null ? '_param' : '';

  return '''import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:bloc/bloc.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends Cubit<${logic.statePascal}> {
  final ${uc.ucPascal} _${uc.ucCamel};
$fieldParam  StreamSubscription<Result<$entityType>>? _subscription;

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
$constructorParam  })  : _${uc.ucCamel} = ${uc.ucCamel},
$assignmentParam  super(const ${logic.statePascal}.initial());

  void ${uc.repoMethod}($methodParam) {
    emit(const ${logic.statePascal}.loading());

    _subscription?.cancel();
    _subscription = _${uc.ucCamel}($listenCallArg).listen(
      (result) {
        emit(
          result.when(
            success: (data) => ${logic.statePascal}.loaded(data: data),
            failure: (failure) => ${logic.statePascal}.failure(failure: failure),
          ),
        );
      },
      onError: (e) {
        emit(
          ${logic.statePascal}.failure(
            failure: CoreException.fromException(
              e.toString(),
              st: StackTrace.current,
            ).toFailure(),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
''';
}
