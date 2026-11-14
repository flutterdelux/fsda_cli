import '../../../core/extensions/logic_flow_param_x.dart';
import '../../../core/extensions/logic_uc_x.dart';
import '../../../core/extensions/uc_type_x.dart';
import '../../../domain/enums/logic_flow_type.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/params/logic_flow_param.dart';

abstract final class GetxFlowTemplate {
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
import 'package:get/get.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends GetxController {
  final ${uc.ucPascal} _${uc.ucCamel};
  late final Rx<${logic.statePascal}> rxState;

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
  }) : _${uc.ucCamel} = ${uc.ucCamel},
       rxState = const ${logic.statePascal}.initial().obs;

  ${logic.statePascal} get state => rxState.value;

  $returnTypeModifier ${uc.method}($methodParam) $asyncModifier{
    rxState.value = const ${logic.statePascal}.loading();
    final result = ${awaitKeyword}_${uc.ucCamel}($callArg);
    rxState.value = result.when(
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

  final methodParam = '';

  final returnTypeModifier = isAsync ? 'Future<void>' : 'void';
  final asyncModifier = isAsync ? 'async' : '';
  final awaitKeyword = isAsync ? 'await ' : '';

  return '''import 'package:app_core/app_core.dart';
import 'package:get/get.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends GetxController {
  final ${uc.ucPascal} _${uc.ucCamel};
  late final Rx<${logic.statePascal}> rxState;
  ${fieldParam.trim()}

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
    ${constructorParam.trim()}
  })  : _${uc.ucCamel} = ${uc.ucCamel},
        ${assignmentParam.trim()}
        rxState = const ${logic.statePascal}.initial().obs;

  ${logic.statePascal} get state => rxState.value;

  $returnTypeModifier ${uc.method}($methodParam) $asyncModifier {
    rxState.value = const ${logic.statePascal}.loading();
    final result = ${awaitKeyword}_${uc.ucCamel}($callArg);
    rxState.value = result.when(
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
import 'package:get/get.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends GetxController {
  final ${uc.ucPascal} _${uc.ucCamel};
  late final Rx<${logic.statePascal}> rxState;

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
  }) : _${uc.ucCamel} = ${uc.ucCamel},
       rxState = const ${logic.statePascal}().obs;

  ${logic.statePascal} get state => rxState.value;

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
    rxState.value = state.copyWith(
      isLoading: true,
      failure: null,
      data: page == 1 ? [] : state.data,
    );

    final selectedParam = state.param.copyWith(page: page);
    final result = ${awaitKeyword}_${uc.ucCamel}(selectedParam);

    rxState.value = result.when(
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
import 'package:get/get.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends GetxController {
  final ${uc.ucPascal} _${uc.ucCamel};
  late final Rx<${logic.statePascal}> rxState;
  StreamSubscription<Result<$entityType>>? _subscription;
  ${fieldParam.trim()}

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
    ${constructorParam.trim()}
  })  : _${uc.ucCamel} = ${uc.ucCamel},
        ${assignmentParam.trim()}
        rxState = const ${logic.statePascal}.initial().obs;

  ${logic.statePascal} get state => rxState.value;

  void ${uc.method}($methodParam) {
    rxState.value = const ${logic.statePascal}.loading();

    _subscription?.cancel();
    _subscription = _${uc.ucCamel}($listenCallArg).listen(
      (result) {
        rxState.value = result.when(
          success: (data) => ${logic.statePascal}.loaded(data: data),
          failure: (failure) => ${logic.statePascal}.failure(failure: failure),
        );
      },
      onError: (e) {
        rxState.value = ${logic.statePascal}.failure(
          failure: CoreException.fromException(
            e.toString(),
            st: StackTrace.current,
          ).toFailure(),
        );
      },
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
''';
}
