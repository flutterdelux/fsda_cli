import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/state_flow_template.dart';
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
      control: StateControl.cubit,
      featureName: 'task',
      moduleName: 'project_management',
      sliceName: slice,
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('StateFlowTemplate', () {
    group('ArtifactGenerationModel Metadata', () {
      test(
        'GIVEN LogicFlowParam with paramType and returnType WHEN build called THEN sets metadata and imports',
        () {
          const uc = LogicUcModel(
            name: 'task_create_use_case',
            path: 'domain/usecases/task_create_use_case.dart',
            type: UcType.returnParamUc,
            repoMethod: 'createTask',
            returnType: 'TaskEntity',
            paramType: 'TaskCreateParam',
          );
          final artifact = StateFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.mutation,
              uc: uc,
              slice: 'create',
            ),
            uc: uc,
          );

          expect(artifact.name, 'TaskCreateState');
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
              'task_create_state.dart',
            ),
          );
          expect(artifact.typesToImport, {'TaskCreateParam', 'TaskEntity'});
          expect(artifact.needToExport, isTrue);
        },
      );

      test(
        'GIVEN LogicFlowParam without paramType and returnType WHEN build called THEN returns empty typesToImport',
        () {
          const uc = LogicUcModel(
            name: 'task_sync_use_case',
            path: 'domain/usecases/task_sync_use_case.dart',
            type: UcType.voidUc,
            repoMethod: 'syncTask',
          );
          final artifact = StateFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.mutation,
              uc: uc,
              slice: 'sync',
            ),
            uc: uc,
          );

          expect(artifact.typesToImport, isEmpty);
        },
      );
    });

    group('Mutation State', () {
      test(
        'GIVEN LogicFlowType.mutation with non-nullable returnType WHEN build called THEN generates sealed Freezed state with required data in success',
        () {
          const uc = LogicUcModel(
            name: 'task_create_use_case',
            path: 'domain/usecases/task_create_use_case.dart',
            type: UcType.returnParamUc,
            repoMethod: 'createTask',
            returnType: 'TaskEntity',
            paramType: 'TaskCreateParam',
          );
          final artifact = StateFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.mutation,
              uc: uc,
              slice: 'create',
            ),
            uc: uc,
          );

          expect(artifact.content, '''
import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_create_state.freezed.dart';

@freezed
sealed class TaskCreateState with _\$TaskCreateState {
  const factory TaskCreateState.initial() = _Initial;
  const factory TaskCreateState.loading() = _Loading;
  const factory TaskCreateState.success({required TaskEntity data}) = _Success;
  const factory TaskCreateState.failure({required Failure failure}) = _Failure;
}
''');
        },
      );

      test(
        'GIVEN LogicFlowType.mutation with null returnType WHEN build called THEN generates empty success factory parameter',
        () {
          const uc = LogicUcModel(
            name: 'task_delete_use_case',
            path: 'domain/usecases/task_delete_use_case.dart',
            type: UcType.paramUc,
            repoMethod: 'deleteTask',
            paramType: 'TaskDeleteParam',
          );
          final artifact = StateFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.mutation,
              uc: uc,
              slice: 'delete',
            ),
            uc: uc,
          );

          expect(
            artifact.content,
            contains('const factory TaskDeleteState.success() = _Success;'),
          );
        },
      );
    });

    group('Retrieval State', () {
      test(
        'GIVEN LogicFlowType.retrieval with nullable returnType WHEN build called THEN generates loaded factory without required modifier',
        () {
          const uc = LogicUcModel(
            name: 'task_detail_use_case',
            path: 'domain/usecases/task_detail_use_case.dart',
            type: UcType.returnParamUc,
            repoMethod: 'getTaskDetail',
            returnType: 'TaskEntity?',
            paramType: 'TaskDetailParam',
          );
          final artifact = StateFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.retrieval,
              uc: uc,
              slice: 'detail',
            ),
            uc: uc,
          );

          expect(artifact.content, '''
import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_detail_state.freezed.dart';

@freezed
sealed class TaskDetailState with _\$TaskDetailState {
  const factory TaskDetailState.initial() = _Initial;
  const factory TaskDetailState.loading() = _Loading;
  const factory TaskDetailState.loaded({TaskEntity? data}) = _Loaded;
  const factory TaskDetailState.failure({required Failure failure}) = _Failure;
}
''');
        },
      );
    });

    group('Pagination State', () {
      test(
        'GIVEN LogicFlowType.pagination with returnType and paramType WHEN build called THEN generates abstract Freezed pagination state',
        () {
          const uc = LogicUcModel(
            name: 'task_list_get_use_case',
            path: 'domain/usecases/task_list_get_use_case.dart',
            type: UcType.returnParamUc,
            repoMethod: 'getTaskList',
            returnType: 'List<TaskEntity>',
            paramType: 'TaskListParam',
          );
          final artifact = StateFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.pagination,
              uc: uc,
              slice: 'list',
            ),
            uc: uc,
          );

          expect(artifact.content, '''
import 'package:app_core/app_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_list_state.freezed.dart';

@freezed
abstract class TaskListState with _\$TaskListState {
  const factory TaskListState({
    @Default([]) List<TaskEntity> data,
    @Default(false) bool hasReachedMax,
    @Default(false) bool isLoading,
    Failure? failure,
    @Default(TaskListParam()) TaskListParam param,
  }) = _TaskListState;
}
''');
        },
      );

      test(
        'GIVEN LogicFlowType.pagination without returnType and paramType WHEN build called THEN falls back to dynamic and Object',
        () {
          const uc = LogicUcModel(
            name: 'task_feed_use_case',
            path: 'domain/usecases/task_feed_use_case.dart',
            type: UcType.voidUc,
            repoMethod: 'getTaskFeed',
          );
          final artifact = StateFlowTemplate.build(
            logic: createLogic(
              type: LogicFlowType.pagination,
              uc: uc,
              slice: 'feed',
            ),
            uc: uc,
          );

          expect(
            artifact.content,
            contains(
              '@Default([]) '
              'dynamic data,',
            ),
          );
          expect(
            artifact.content,
            contains('@Default(Object()) Object param,'),
          );
        },
      );
    });
  });
}
