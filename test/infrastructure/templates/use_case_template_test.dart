import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/use_case_template.dart';
import 'package:test/test.dart';

void main() {
  SequenceParam createParam({
    Action action = Action.get,
    String usecase = 'task_list_get_use_case',
    String method = 'get_task_list',
    FlowType flow = FlowType.asynchronous,
    bool isList = false,
    String? entity,
    String? param,
  }) {
    return SequenceParam(
      action: action,
      usecase: usecase,
      method: method,
      flow: flow,
      isList: isList,
      entity: entity,
      param: param,
      featureName: 'task',
      moduleName: 'project_management',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('UseCaseTemplate', () {
    group('build - Asynchronous Flow', () {
      test(
        'GIVEN asynchronous SequenceParam without entity and param '
        'WHEN build is called '
        'THEN generates VoidUseCase class with AsyncResult<void> and empty call parameters',
        () {
          // Given
          final sequence = createParam(
            action: Action.post,
            usecase: 'task_sync_use_case',
            method: 'sync_task',
            flow: FlowType.asynchronous,
          );

          // When
          final result = UseCaseTemplate.build(sequence: sequence);

          // Then
          expect(result, '''import 'package:app_core/app_core.dart';
import '../repositories/task_repository.dart';

class TaskSyncUseCase extends VoidUseCase {
  final TaskRepository _repository;

  const TaskSyncUseCase({required TaskRepository taskRepository})
    : _repository = taskRepository;

  @override
  AsyncResult<void> call() {
    return _repository.syncTask();
  }
}
''');
        },
      );

      test(
        'GIVEN asynchronous SequenceParam with param only '
        'WHEN build is called '
        'THEN generates ParamUseCase class passing param argument to repository',
        () {
          // Given
          final sequence = createParam(
            action: Action.delete,
            usecase: 'task_delete_use_case',
            method: 'delete_task',
            flow: FlowType.asynchronous,
            param: 'task_delete_param',
          );

          // When
          final result = UseCaseTemplate.build(sequence: sequence);

          // Then
          expect(
            result,
            contains(
              'class TaskDeleteUseCase extends ParamUseCase<TaskDeleteParam>',
            ),
          );
          expect(
            result,
            contains('AsyncResult<void> call(TaskDeleteParam param)'),
          );
          expect(result, contains('return _repository.deleteTask(param);'));
        },
      );

      test(
        'GIVEN asynchronous SequenceParam with entity and isList true '
        'WHEN build is called '
        'THEN generates ReturnUseCase<List<Entity>> with AsyncResult<List<Entity>>',
        () {
          // Given
          final sequence = createParam(
            usecase: 'task_list_get_use_case',
            method: 'get_task_list',
            flow: FlowType.asynchronous,
            isList: true,
            entity: 'task_entity',
          );

          // When
          final result = UseCaseTemplate.build(sequence: sequence);

          // Then
          expect(
            result,
            contains(
              'class TaskListGetUseCase extends ReturnUseCase<List<TaskEntity>>',
            ),
          );
          expect(result, contains('AsyncResult<List<TaskEntity>> call()'));
          expect(result, contains('return _repository.getTaskList();'));
        },
      );

      test('GIVEN asynchronous SequenceParam with entity and param '
          'WHEN build is called '
          'THEN generates ReturnParamUseCase<Entity, Param> accurately', () {
        // Given
        final sequence = createParam(
          action: Action.post,
          usecase: 'task_create_use_case',
          method: 'create_task',
          flow: FlowType.asynchronous,
          entity: 'task_entity',
          param: 'task_create_param',
        );

        // When
        final result = UseCaseTemplate.build(sequence: sequence);

        // Then
        expect(
          result,
          contains(
            'class TaskCreateUseCase extends ReturnParamUseCase<TaskEntity, TaskCreateParam>',
          ),
        );
        expect(
          result,
          contains('AsyncResult<TaskEntity> call(TaskCreateParam param)'),
        );
        expect(result, contains('return _repository.createTask(param);'));
      });
    });

    group('build - Synchronous & Stream Flows', () {
      test('GIVEN synchronous SequenceParam across all signature combinations '
          'WHEN build is called '
          'THEN generates SyncUseCase variants with Result return type', () {
        // VoidSyncUseCase
        final voidSync = UseCaseTemplate.build(
          sequence: createParam(flow: FlowType.synchronous),
        );
        expect(voidSync, contains('extends VoidSyncUseCase'));
        expect(voidSync, contains('Result<void> call()'));

        // ParamSyncUseCase
        final paramSync = UseCaseTemplate.build(
          sequence: createParam(
            flow: FlowType.synchronous,
            param: 'task_filter_param',
          ),
        );
        expect(
          paramSync,
          contains('extends ParamSyncUseCase<TaskFilterParam>'),
        );
        expect(paramSync, contains('Result<void> call(TaskFilterParam param)'));

        // ReturnSyncUseCase
        final returnSync = UseCaseTemplate.build(
          sequence: createParam(
            flow: FlowType.synchronous,
            entity: 'task_entity',
          ),
        );
        expect(returnSync, contains('extends ReturnSyncUseCase<TaskEntity>'));
        expect(returnSync, contains('Result<TaskEntity> call()'));

        // ReturnParamSyncUseCase with isList
        final returnParamSync = UseCaseTemplate.build(
          sequence: createParam(
            flow: FlowType.synchronous,
            isList: true,
            entity: 'task_entity',
            param: 'task_filter_param',
          ),
        );
        expect(
          returnParamSync,
          contains(
            'extends ReturnParamSyncUseCase<List<TaskEntity>, TaskFilterParam>',
          ),
        );
        expect(
          returnParamSync,
          contains('Result<List<TaskEntity>> call(TaskFilterParam param)'),
        );
      });

      test(
        'GIVEN stream SequenceParam across all signature combinations '
        'WHEN build is called '
        'THEN generates StreamUseCase variants with StreamResult return type',
        () {
          // VoidStreamUseCase
          final voidStream = UseCaseTemplate.build(
            sequence: createParam(flow: FlowType.stream),
          );
          expect(voidStream, contains('extends VoidStreamUseCase'));
          expect(voidStream, contains('StreamResult<void> call()'));

          // ParamStreamUseCase
          final paramStream = UseCaseTemplate.build(
            sequence: createParam(
              flow: FlowType.stream,
              param: 'task_watch_param',
            ),
          );
          expect(
            paramStream,
            contains('extends ParamStreamUseCase<TaskWatchParam>'),
          );
          expect(
            paramStream,
            contains('StreamResult<void> call(TaskWatchParam param)'),
          );

          // ReturnStreamUseCase
          final returnStream = UseCaseTemplate.build(
            sequence: createParam(flow: FlowType.stream, entity: 'task_entity'),
          );
          expect(
            returnStream,
            contains('extends ReturnStreamUseCase<TaskEntity>'),
          );
          expect(returnStream, contains('StreamResult<TaskEntity> call()'));

          // ReturnParamStreamUseCase with isList
          final returnParamStream = UseCaseTemplate.build(
            sequence: createParam(
              flow: FlowType.stream,
              isList: true,
              entity: 'task_entity',
              param: 'task_watch_param',
            ),
          );
          expect(
            returnParamStream,
            contains(
              'extends ReturnParamStreamUseCase<List<TaskEntity>, TaskWatchParam>',
            ),
          );
          expect(
            returnParamStream,
            contains(
              'StreamResult<List<TaskEntity>> call(TaskWatchParam param)',
            ),
          );
        },
      );
    });

    group('buildArbEntries', () {
      test('GIVEN a SequenceParam with usecase and method names '
          'WHEN buildArbEntries is called '
          'THEN returns map with Action and Success localization entries', () {
        // Given
        final sequence = createParam(
          usecase: 'task_create_use_case',
          method: 'create_task',
        );

        // When
        final result = UseCaseTemplate.buildArbEntries(sequence);

        // Then
        expect(result, {
          'taskCreateAction': 'Create Task',
          'taskCreateSuccess': 'Create Task Successfull',
        });
      });
    });
  });
}
