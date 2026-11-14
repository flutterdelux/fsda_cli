import '../../../core/extensions/logic_flow_param_x.dart';
import '../../../core/extensions/logic_uc_x.dart';
import '../../../core/extensions/uc_type_x.dart';
import '../../../domain/enums/logic_flow_type.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/params/logic_flow_param.dart';

abstract final class RiverpodFlowTemplate {
  static ArtifactGenerationModel build(LogicFlowParam logic) {
    return ArtifactGenerationModel(
      name: logic.controllerPascal,
      path: logic.controllerPath,
      content: logic.uc.type.isStream
          ? _streamLogic(logic)
          : switch (logic.type) {
              LogicFlowType.mutation => _mutationLogic(logic),
              LogicFlowType.retrieval => _retrievalLogic(logic),
              LogicFlowType.pagination => _paginationLogic(logic),
            },
      typesToImport: {
        logic.statePascal,
        logic.uc.ucPascal,
        ?logic.uc.paramType,
      },
      needToExport: true,
    );
  }
}

String _mutationLogic(LogicFlowParam logic) {
  final uc = logic.uc;
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
import 'package:riverpod/riverpod.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends Notifier<${logic.statePascal}> {
  final ${uc.ucPascal} _${uc.ucCamel};

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
  }) : _${uc.ucCamel} = ${uc.ucCamel};

  @override
  ${logic.statePascal} build() {
    return const ${logic.statePascal}.initial();
  }

  $returnTypeModifier ${uc.method}($methodParam) $asyncModifier{
    state = const ${logic.statePascal}.loading();
    final result = ${awaitKeyword}_${uc.ucCamel}($callArg);
    state = result.when(
      success: (data) => ${hasReturn ? '${logic.statePascal}.success(data: data)' : 'const ${logic.statePascal}.success()'},
      failure: (failure) => ${logic.statePascal}.failure(failure: failure),
    );
  }
}
''';
}

String _retrievalLogic(LogicFlowParam logic) {
  final uc = logic.uc;
  final hasParam = uc.type.hasParam;
  final isAsync = uc.type.isAsync;

  final paramType = uc.paramType;
  final callArg = hasParam && paramType != null ? 'param' : '';
  final methodParam = hasParam && paramType != null ? '$paramType param' : '';

  final returnTypeModifier = isAsync ? 'Future<void>' : 'void';
  final asyncModifier = isAsync ? 'async' : '';
  final awaitKeyword = isAsync ? 'await ' : '';

  return '''import 'package:app_core/app_core.dart';
import 'package:riverpod/riverpod.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends Notifier<${logic.statePascal}> {
  final ${uc.ucPascal} _${uc.ucCamel};

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
  }) : _${uc.ucCamel} = ${uc.ucCamel};

  @override
  ${logic.statePascal} build() {
    return const ${logic.statePascal}.initial();
  }

  $returnTypeModifier ${uc.method}($methodParam) $asyncModifier {
    state = const ${logic.statePascal}.loading();
    final result = ${awaitKeyword}_${uc.ucCamel}($callArg);
    state = result.when(
      success: (data) => ${logic.statePascal}.loaded(data: data),
      failure: (failure) => ${logic.statePascal}.failure(failure: failure),
    );
  }
}
''';
}

String _paginationLogic(LogicFlowParam logic) {
  final uc = logic.uc;
  final isAsync = uc.type.isAsync;
  final awaitKeyword = isAsync ? 'await ' : '';

  return '''import 'package:app_core/app_core.dart';
import 'package:riverpod/riverpod.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends Notifier<${logic.statePascal}> {
  final ${uc.ucPascal} _${uc.ucCamel};

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
  }) : _${uc.ucCamel} = ${uc.ucCamel};

  @override
  ${logic.statePascal} build() {
    return const ${logic.statePascal}();
  }

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
    state = state.copyWith(
      isLoading: true,
      failure: null,
      data: page == 1 ? [] : state.data,
    );

    final selectedParam = state.param.copyWith(page: page);
    final result = ${awaitKeyword}_${uc.ucCamel}(selectedParam);

    state = result.when(
      success: (data) => state.copyWith(
        data: [...state.data, ...data],
        hasReachedMax: data.length < state.param.pageSize,
        isLoading: false,
        param: selectedParam,
      ),
      failure: (failure) =>
          state.copyWith(isLoading: false, failure: failure),
    );
  }
}
''';
}

String _streamLogic(LogicFlowParam logic) {
  final uc = logic.uc;
  final hasParam = uc.type.hasParam;

  final paramType = uc.paramType;
  final methodParam = hasParam && paramType != null ? '$paramType param' : '';
  final entityType = uc.returnType ?? 'dynamic';
  final listenCallArg = hasParam && paramType != null ? 'param' : '';

  return '''import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:riverpod/riverpod.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends Notifier<${logic.statePascal}> {
  final ${uc.ucPascal} _${uc.ucCamel};
  StreamSubscription<Result<$entityType>>? _subscription;

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
  }) : _${uc.ucCamel} = ${uc.ucCamel};

  @override
  ${logic.statePascal} build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return const ${logic.statePascal}.initial();
  }

  void ${uc.method}($methodParam) {
    state = const ${logic.statePascal}.loading();

    _subscription?.cancel();
    _subscription = _${uc.ucCamel}($listenCallArg).listen(
      (result) {
        state = result.when(
          success: (data) => ${logic.statePascal}.loaded(data: data),
          failure: (failure) => ${logic.statePascal}.failure(failure: failure),
        );
      },
      onError: (e) {
        state = ${logic.statePascal}.failure(
          failure: CoreException.fromException(
            e.toString(),
            st: StackTrace.current,
          ).toFailure(),
        );
      },
    );
  }
}
''';
}
