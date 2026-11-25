import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/provider_flow_template.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  LogicFlowParam createLogic({
    required LogicFlowType type,
    required LogicUcModel uc,
    String slice = 'form',
  }) {
    return LogicFlowParam(
      type: type,
      uc: '${uc.name}.dart',
      control: StateControl.provider,
      featureName: 'task',
      moduleName: 'project_management',
      sliceName: slice,
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('ProviderFlowTemplate', () {
    group('ArtifactGenerationModel Metadata', () {
      test(
        'GIVEN LogicFlowParam with paramType WHEN build called THEN sets metadata and imports',
        () {
          const uc = LogicUcModel(
            name: 'task_create_use_case',
            path: 'domain/usecases/task_create_use_case.dart',
            type: UcType.returnParamUc,
            repoMethod: 'createTask',
            returnType: 'TaskEntity',
            paramType: 'TaskCreateParam',
          );
          final artifact = ProviderFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.mutation,
              uc: uc,
              slice: 'create',
            ),
            uc: uc,
          );

          expect(artifact.name, 'TaskCreateProvider');
          expect(
            artifact.path,
            p.join(
              '/projects/my_workspace',
              'modules',
              'project_management',
              'lib',
              'src',
              'features',
              'task',
              'logic',
              'create',
              'task_create_provider.dart',
            ),
          );
          expect(artifact.typesToImport, {
            'TaskCreateState',
            'TaskCreateUseCase',
            'TaskCreateParam',
          });
          expect(artifact.needToExport, isTrue);
        },
      );

      test(
        'GIVEN LogicFlowParam without paramType WHEN build called THEN omits null from typesToImport',
        () {
          const uc = LogicUcModel(
            name: 'task_list_get_use_case',
            path: 'domain/usecases/task_list_get_use_case.dart',
            type: UcType.returnUc,
            repoMethod: 'getTaskList',
            returnType: 'List<TaskEntity>',
          );
          final artifact = ProviderFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.retrieval,
              uc: uc,
              slice: 'list',
            ),
            uc: uc,
          );

          expect(artifact.typesToImport, {
            'TaskListState',
            'TaskListGetUseCase',
          });
        },
      );
    });

    group('Mutation Flow', () {
      test(
        'GIVEN async ReturnParamUseCase WHEN build called THEN generates async mutation ChangeNotifier',
        () {
          const uc = LogicUcModel(
            name: 'task_create_use_case',
            path: 'domain/usecases/task_create_use_case.dart',
            type: UcType.returnParamUc,
            repoMethod: 'createTask',
            returnType: 'TaskEntity',
            paramType: 'TaskCreateParam',
          );
          final artifact = ProviderFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.mutation,
              uc: uc,
              slice: 'create',
            ),
            uc: uc,
          );

          expect(
            artifact.content,
            contains("import 'package:flutter/foundation.dart';"),
          );
          expect(
            artifact.content,
            contains("import 'task_create_state.dart';"),
          );
          expect(
            artifact.content,
            contains('class TaskCreateProvider extends ChangeNotifier'),
          );
          expect(artifact.content, contains('late TaskCreateState _state;'));
          expect(
            artifact.content,
            contains('_state = const TaskCreateState.initial();'),
          );
          expect(
            artifact.content,
            contains('TaskCreateState get state => _state;'),
          );
          expect(
            artifact.content,
            contains('Future<void> createTask(TaskCreateParam param) async {'),
          );
          expect(
            artifact.content,
            contains('_state = const TaskCreateState.loading();'),
          );
          expect(artifact.content, contains('notifyListeners();'));
          expect(
            artifact.content,
            contains('final result = await _taskCreateUseCase(param);'),
          );
          expect(
            artifact.content,
            contains('success: (data) => TaskCreateState.success(data: data),'),
          );
          expect(
            artifact.content,
            contains(
              'failure: (failure) => TaskCreateState.failure(failure: failure),',
            ),
          );
        },
      );

      test(
        'GIVEN sync VoidSyncUseCase WHEN build called THEN generates sync void mutation ChangeNotifier',
        () {
          const uc = LogicUcModel(
            name: 'task_clear_cache_use_case',
            path: 'domain/usecases/task_clear_cache_use_case.dart',
            type: UcType.voidSyncUc,
            repoMethod: 'clearCache',
          );
          final artifact = ProviderFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.mutation,
              uc: uc,
              slice: 'cache',
            ),
            uc: uc,
          );

          expect(artifact.content, contains('void clearCache() {'));
          expect(
            artifact.content,
            contains('final result = _taskClearCacheUseCase();'),
          );
          expect(
            artifact.content,
            contains('success: (data) => const TaskCacheState.success(),'),
          );
        },
      );
    });

    group('Retrieval Flow', () {
      test(
        'GIVEN async ReturnParamUseCase WHEN build called THEN injects param in constructor',
        () {
          const uc = LogicUcModel(
            name: 'task_detail_use_case',
            path: 'domain/usecases/task_detail_use_case.dart',
            type: UcType.returnParamUc,
            repoMethod: 'getTaskDetail',
            returnType: 'TaskEntity',
            paramType: 'TaskDetailParam',
          );
          final artifact = ProviderFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.retrieval,
              uc: uc,
              slice: 'detail',
            ),
            uc: uc,
          );

          expect(artifact.content, contains('final TaskDetailParam _param;'));
          expect(artifact.content, contains('required TaskDetailParam param,'));
          expect(artifact.content, contains('_param = param,'));
          expect(
            artifact.content,
            contains('Future<void> getTaskDetail() async {'),
          );
          expect(
            artifact.content,
            contains('final result = await _taskDetailUseCase(_param);'),
          );
          expect(
            artifact.content,
            contains('success: (data) => TaskDetailState.loaded(data: data),'),
          );
        },
      );

      test(
        'GIVEN sync ReturnSyncUseCase without param WHEN build called THEN omits constructor param',
        () {
          const uc = LogicUcModel(
            name: 'task_summary_use_case',
            path: 'domain/usecases/task_summary_use_case.dart',
            type: UcType.returnSyncUc,
            repoMethod: 'getTaskSummary',
            returnType: 'TaskSummaryEntity',
          );
          final artifact = ProviderFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.retrieval,
              uc: uc,
              slice: 'summary',
            ),
            uc: uc,
          );

          expect(artifact.content, isNot(contains('_param')));
          expect(artifact.content, contains('void getTaskSummary()  {'));
          expect(
            artifact.content,
            contains('final result = _taskSummaryUseCase();'),
          );
        },
      );
    });

    group('Pagination Flow', () {
      test(
        'GIVEN LogicFlowType.pagination WHEN build called THEN generates pagination methods with notifyListeners',
        () {
          const uc = LogicUcModel(
            name: 'task_list_get_use_case',
            path: 'domain/usecases/task_list_get_use_case.dart',
            type: UcType.returnParamUc,
            repoMethod: 'getTaskList',
            returnType: 'List<TaskEntity>',
            paramType: 'TaskListParam',
          );
          final artifact = ProviderFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.pagination,
              uc: uc,
              slice: 'list',
            ),
            uc: uc,
          );

          expect(artifact.content, contains('_state = const TaskListState();'));
          expect(artifact.content, contains('Future<void> init() async'));
          expect(artifact.content, contains('Future<void> refresh() async'));
          expect(artifact.content, contains('Future<void> loadMore() async'));
          expect(
            artifact.content,
            contains('final selectedParam = state.param.copyWith(page: page);'),
          );
          expect(
            artifact.content,
            contains(
              'final result = await _taskListGetUseCase(selectedParam);',
            ),
          );
          expect(
            artifact.content,
            contains('hasReachedMax: data.length < state.param.pageSize,'),
          );
          expect(artifact.content, contains('notifyListeners();'));
        },
      );
    });
    group('Stream Flow', () {
      test(
        'GIVEN ReturnParamStreamUseCase WHEN build called THEN generates subscription ChangeNotifier with dispose',
        () {
          const uc = LogicUcModel(
            name: 'task_watch_use_case',
            path: 'domain/usecases/task_watch_use_case.dart',
            type: UcType.returnParamStreamUc,
            repoMethod: 'watchTask',
            returnType: 'TaskEntity',
            paramType: 'TaskWatchParam',
          );
          final artifact = ProviderFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.retrieval,
              uc: uc,
              slice: 'watch',
            ),
            uc: uc,
          );
          expect(artifact.content, contains("import 'dart:async';"));
          expect(artifact.content, contains('final TaskWatchParam _param;'));
          expect(
            artifact.content,
            contains(
              'StreamSubscription<Result<'
              'TaskEntity>>? _subscription;',
            ),
          );
          expect(
            artifact.content,
            contains('void watchTask(TaskWatchParam param) {'),
          );
          expect(artifact.content, contains('_subscription?.cancel();'));
          expect(
            artifact.content,
            contains('_subscription = _taskWatchUseCase(_param).listen('),
          );
          expect(
            artifact.content,
            contains('success: (data) => TaskWatchState.loaded(data: data),'),
          );
          expect(artifact.content, contains('CoreException.fromException('));
          expect(artifact.content, contains('void dispose() {'));
          expect(artifact.content, contains('super.dispose();'));
        },
      );
      test(
        'GIVEN ReturnStreamUseCase without param or returnType WHEN build called THEN uses dynamic fallback',
        () {
          const uc = LogicUcModel(
            name: 'task_events_use_case',
            path: 'domain/usecases/task_events_use_case.dart',
            type: UcType.returnStreamUc,
            repoMethod: 'observeEvents',
          );
          final artifact = ProviderFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.retrieval,
              uc: uc,
              slice: 'events',
            ),
            uc: uc,
          );
          expect(
            artifact.content,
            contains(
              'StreamSubscription<Result<'
              'dynamic>>? _subscription;',
            ),
          );
          expect(artifact.content, contains('void observeEvents() {'));
          expect(
            artifact.content,
            contains('_subscription = _taskEventsUseCase().listen('),
          );
        },
      );
    });
  });
}
