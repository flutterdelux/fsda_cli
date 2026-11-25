import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repo_body_common_template.dart';
import 'package:test/test.dart';

void main() {
  SequenceParam createParam({
    Action action = Action.get,
    String method = 'get_task_list',
    FlowType flow = FlowType.asynchronous,
    DsMode dsMode = DsMode.remote,
    bool isList = false,
    String? entity,
    String? dto,
    String? param,
    String? request,
  }) {
    return SequenceParam(
      action: action,
      usecase: 'task_list_get_use_case',
      method: method,
      flow: flow,
      dsMode: dsMode,
      isList: isList,
      entity: entity,
      dto: dto,
      param: param,
      request: request,
      featureName: 'task',
      moduleName: 'project_management',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('RepoBodyCommonTemplate', () {
    group('ReturnParam Combination (isReturnParam)', () {
      test(
        'GIVEN asynchronous remote SequenceParam with single entity, dto, param, and request '
        'WHEN build is called '
        'THEN converts param to request, awaits single dto conversion to entity, and wraps in try-catch',
        () {
          // Given
          final sequence = createParam(
            action: Action.post,
            method: 'create_task',
            flow: FlowType.asynchronous,
            dsMode: DsMode.remote,
            isList: false,
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_create_param',
            request: 'task_create_request',
          );

          // When
          final result = RepoBodyCommonTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      final request = TaskCreateRequest.fromParam(param);
      final dto = await _remoteDataSource.createTask(request);
      final entity = dto.toEntity();
      return Result.success(entity);
    } catch (e, st) {
      return handleException('createTask', e, st);
    }
''');
        },
      );

      test(
        'GIVEN synchronous local SequenceParam with List entity, dto, param, and request '
        'WHEN build is called '
        'THEN calls local data source without await and maps DTO list to entity list',
        () {
          // Given
          final sequence = createParam(
            action: Action.get,
            method: 'search_cached_tasks',
            flow: FlowType.synchronous,
            dsMode: DsMode.local,
            isList: true,
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_search_param',
            request: 'task_search_request',
          );

          // When
          final result = RepoBodyCommonTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      final request = TaskSearchRequest.fromParam(param);
      final dtos = _localDataSource.searchCachedTasks(request);
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Result.success(entities);
    } catch (e, st) {
      return handleException('searchCachedTasks', e, st);
    }
''');
        },
      );
    });

    group('Return Combination (isReturn)', () {
      test(
        'GIVEN asynchronous remote SequenceParam with List entity and dto only '
        'WHEN build is called '
        'THEN awaits DTO list without request parameter and maps to entity list',
        () {
          // Given
          final sequence = createParam(
            action: Action.get,
            method: 'get_task_list',
            flow: FlowType.asynchronous,
            dsMode: DsMode.remote,
            isList: true,
            entity: 'task_entity',
            dto: 'task_dto',
          );

          // When
          final result = RepoBodyCommonTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      final dtos = await _remoteDataSource.getTaskList();
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Result.success(entities);
    } catch (e, st) {
      return handleException('getTaskList', e, st);
    }
''');
        },
      );

      test(
        'GIVEN synchronous local SequenceParam with single entity and dto only '
        'WHEN build is called '
        'THEN reads single DTO without await and converts to entity',
        () {
          // Given
          final sequence = createParam(
            action: Action.get,
            method: 'get_cached_task',
            flow: FlowType.synchronous,
            dsMode: DsMode.local,
            isList: false,
            entity: 'task_entity',
            dto: 'task_dto',
          );

          // When
          final result = RepoBodyCommonTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      final dto = _localDataSource.getCachedTask();
      final entity = dto.toEntity();
      return Result.success(entity);
    } catch (e, st) {
      return handleException('getCachedTask', e, st);
    }
''');
        },
      );
    });

    group('Param Combination (isParam)', () {
      test(
        'GIVEN asynchronous remote SequenceParam with param and request only '
        'WHEN build is called '
        'THEN converts param to request, awaits data source call, and returns const Result.success(null)',
        () {
          // Given
          final sequence = createParam(
            action: Action.delete,
            method: 'delete_task',
            flow: FlowType.asynchronous,
            dsMode: DsMode.remote,
            param: 'task_delete_param',
            request: 'task_delete_request',
          );

          // When
          final result = RepoBodyCommonTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      final request = TaskDeleteRequest.fromParam(param);
      await _remoteDataSource.deleteTask(request);
      return const Result.success(null);
    } catch (e, st) {
      return handleException('deleteTask', e, st);
    }
''');
        },
      );

      test(
        'GIVEN synchronous local SequenceParam with param and request only '
        'WHEN build is called '
        'THEN converts param to request, calls local data source without await, and returns const Result.success(null)',
        () {
          // Given
          final sequence = createParam(
            action: Action.post,
            method: 'save_task_draft',
            flow: FlowType.synchronous,
            dsMode: DsMode.local,
            param: 'task_draft_param',
            request: 'task_draft_request',
          );

          // When
          final result = RepoBodyCommonTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      final request = TaskDraftRequest.fromParam(param);
      _localDataSource.saveTaskDraft(request);
      return const Result.success(null);
    } catch (e, st) {
      return handleException('saveTaskDraft', e, st);
    }
''');
        },
      );
    });

    group('Void Combination (isVoid)', () {
      test(
        'GIVEN asynchronous remote SequenceParam with no models '
        'WHEN build is called '
        'THEN awaits parameterless data source method and returns const Result.success(null)',
        () {
          // Given
          final sequence = createParam(
            action: Action.post,
            method: 'sync_tasks',
            flow: FlowType.asynchronous,
            dsMode: DsMode.remote,
          );

          // When
          final result = RepoBodyCommonTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      await _remoteDataSource.syncTasks();
      return const Result.success(null);
    } catch (e, st) {
      return handleException('syncTasks', e, st);
    }
''');
        },
      );

      test(
        'GIVEN synchronous local SequenceParam with no models '
        'WHEN build is called '
        'THEN calls parameterless local data source method without await and returns const Result.success(null)',
        () {
          // Given
          final sequence = createParam(
            action: Action.delete,
            method: 'clear_task_cache',
            flow: FlowType.synchronous,
            dsMode: DsMode.local,
          );

          // When
          final result = RepoBodyCommonTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      _localDataSource.clearTaskCache();
      return const Result.success(null);
    } catch (e, st) {
      return handleException('clearTaskCache', e, st);
    }
''');
        },
      );
    });
  });
}
