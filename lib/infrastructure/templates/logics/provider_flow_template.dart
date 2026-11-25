import '../../../core/extensions/logic_flow_param_x.dart';
import '../../../core/extensions/logic_uc_x.dart';
import '../../../core/extensions/uc_type_x.dart';
import '../../../domain/enums/logic_flow_type.dart';
import '../../../domain/models/artifact_generation_model.dart';
import '../../../domain/models/logic_uc_model.dart';
import '../../../domain/params/logic_flow_param.dart';

abstract final class ProviderFlowTemplate {
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
import 'package:flutter/foundation.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends ChangeNotifier {
  final ${uc.ucPascal} _${uc.ucCamel};
  late ${logic.statePascal} _state;

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
  }) : _${uc.ucCamel} = ${uc.ucCamel},
       _state = const ${logic.statePascal}.initial();
  
  ${logic.statePascal} get state => _state;

  $returnTypeModifier ${uc.repoMethod}($methodParam) $asyncModifier{
    _state = const ${logic.statePascal}.loading();
    notifyListeners();

    final result = ${awaitKeyword}_${uc.ucCamel}($callArg);
    
    _state = result.when(
      success: (data) => ${hasReturn ? '${logic.statePascal}.success(data: data)' : 'const ${logic.statePascal}.success()'},
      failure: (failure) => ${logic.statePascal}.failure(failure: failure),
    );
    notifyListeners();
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
import 'package:flutter/foundation.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends ChangeNotifier {
  final ${uc.ucPascal} _${uc.ucCamel};
$fieldParam
  late ${logic.statePascal} _state;

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
    ${constructorParam.trim()}
  })  : _${uc.ucCamel} = ${uc.ucCamel},
        ${assignmentParam.trim()}
        _state = const ${logic.statePascal}.initial();

  ${logic.statePascal} get state => _state;

  $returnTypeModifier ${uc.repoMethod}($methodParam) $asyncModifier {
    _state = const ${logic.statePascal}.loading();
    notifyListeners();

    final result = ${awaitKeyword}_${uc.ucCamel}($callArg);
    
    _state = result.when(
      success: (data) => ${logic.statePascal}.loaded(data: data),
      failure: (failure) => ${logic.statePascal}.failure(failure: failure),
    );
    notifyListeners();
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
import 'package:flutter/foundation.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends ChangeNotifier {
  final ${uc.ucPascal} _${uc.ucCamel};
  late ${logic.statePascal} _state;

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
  }) : _${uc.ucCamel} = ${uc.ucCamel},
       _state = const ${logic.statePascal}();

  ${logic.statePascal} get state => _state;

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
    _state = state.copyWith(
      isLoading: true,
      failure: null,
      data: page == 1 ? [] : state.data,
    );
    notifyListeners();

    final selectedParam = state.param.copyWith(page: page);
    final result = ${awaitKeyword}_${uc.ucCamel}(selectedParam);

    _state = result.when(
      success: (data) => state.copyWith(
        data: [...state.data, ...data],
        hasReachedMax: data.length < state.param.pageSize,
        isLoading: false,
        param: selectedParam,
      ),
      failure: (failure) =>
          state.copyWith(isLoading: false, failure: failure),
    );
    notifyListeners();
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
import 'package:flutter/foundation.dart';
import '${logic.stateSnake}.dart';

class ${logic.controllerPascal} extends ChangeNotifier {
  final ${uc.ucPascal} _${uc.ucCamel};
  ${logic.statePascal} _state;
  StreamSubscription<Result<$entityType>>? _subscription;
  ${fieldParam.trim()}  

  ${logic.controllerPascal}({
    required ${uc.ucPascal} ${uc.ucCamel},
    ${constructorParam.trim()}
  })  : _${uc.ucCamel} = ${uc.ucCamel},
        ${assignmentParam.trim()}
        _state = const ${logic.statePascal}.initial();

  ${logic.statePascal} get state => _state;

  void ${uc.repoMethod}($methodParam) {
    _state = const ${logic.statePascal}.loading();
    notifyListeners();

    _subscription?.cancel();
    _subscription = _${uc.ucCamel}($listenCallArg).listen(
      (result) {
        _state = result.when(
          success: (data) => ${logic.statePascal}.loaded(data: data),
          failure: (failure) => ${logic.statePascal}.failure(failure: failure),
        );
        notifyListeners();
      },
      onError: (e) {
        _state = ${logic.statePascal}.failure(
          failure: CoreException.fromException(
            e.toString(),
            st: StackTrace.current,
          ).toFailure(),
        );
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
''';
}
