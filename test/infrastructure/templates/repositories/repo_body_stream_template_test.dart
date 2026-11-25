import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repo_body_stream_template.dart';
import 'package:test/test.dart';

void main() {
  SequenceParam createParam({
    String method = 'watch_task',
    DsMode dsMode = DsMode.remote,
    bool isList = false,
    String? entity,
    String? dto,
    String? param,
    String? request,
  }) {
    return SequenceParam(
      action: Action.get,
      usecase: 'task_watch_use_case',
      method: method,
      flow: FlowType.stream,
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

  group('RepoBodyStreamTemplate', () {
    group('Error Cases', () {
      test(
        'GIVEN SequenceParam with Void or Param-only combination '
        'WHEN build is called '
        'THEN throws an Exception indicating unsupported model combination for stream flow',
        () {
          // Given
          final voidSequence = createParam();
          final paramOnlySequence = createParam(
            param: 'task_filter_param',
            request: 'task_filter_request',
          );

          // When & Then
          for (final sequence in [voidSequence, paramOnlySequence]) {
            expect(
              () => RepoBodyStreamTemplate.build(sequence),
              throwsA(
                isA<Exception>().having(
                  (e) => e.toString(),
                  'message',
                  contains(
                    'Model combination not support for stream flow. Available combination for stream: Only Return or Return+Param',
                  ),
                ),
              ),
            );
          }
        },
      );
    });

    group('ReturnParam Combination (isReturnParam)', () {
      test(
        'GIVEN remote SequenceParam with entity, dto, param, request, and isList false '
        'WHEN build is called '
        'THEN converts param to request, streams single DTO to entity, and yields Result.success',
        () {
          // Given
          final sequence = createParam(
            method: 'watch_task_detail',
            dsMode: DsMode.remote,
            isList: false,
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_detail_param',
            request: 'task_detail_request',
          );

          // When
          final result = RepoBodyStreamTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      final request = TaskDetailRequest.fromParam(param);
      final stream = _remoteDataSource.watchTaskDetail(request);
      await for (final dto in stream) {
        final entity = dto.toEntity();
        yield Result.success(entity);
      }
    } catch (e, st) {
      yield handleException('watchTaskDetail', e, st);
    }
''');
        },
      );

      test(
        'GIVEN local SequenceParam with entity, dto, param, request, and isList true '
        'WHEN build is called '
        'THEN converts param to request, streams DTO list to entities, and yields Result.success',
        () {
          // Given
          final sequence = createParam(
            method: 'watch_filtered_tasks',
            dsMode: DsMode.local,
            isList: true,
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_filter_param',
            request: 'task_filter_request',
          );

          // When
          final result = RepoBodyStreamTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      final request = TaskFilterRequest.fromParam(param);
      final stream = _localDataSource.watchFilteredTasks(request);
      await for (final dtos in stream) {
        final entities = dtos.map((e) => e.toEntity()).toList();
        yield Result.success(entities);
      }
    } catch (e, st) {
      yield handleException('watchFilteredTasks', e, st);
    }
''');
        },
      );
    });

    group('Return Combination (isReturn)', () {
      test(
        'GIVEN remote SequenceParam with entity, dto, and isList false '
        'WHEN build is called '
        'THEN calls parameterless stream method and yields single entity Result.success',
        () {
          // Given
          final sequence = createParam(
            method: 'watch_active_task',
            dsMode: DsMode.remote,
            isList: false,
            entity: 'task_entity',
            dto: 'task_dto',
          );

          // When
          final result = RepoBodyStreamTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      final stream = _remoteDataSource.watchActiveTask();
      await for (final dto in stream) {
        final entity = dto.toEntity();
        yield Result.success(entity);
      }
    } catch (e, st) {
      yield handleException('watchActiveTask', e, st);
    }
''');
        },
      );

      test(
        'GIVEN local SequenceParam with entity, dto, and isList true '
        'WHEN build is called '
        'THEN calls parameterless stream method on _localDataSource and yields entity list Result.success',
        () {
          // Given
          final sequence = createParam(
            method: 'watch_task_list',
            dsMode: DsMode.local,
            isList: true,
            entity: 'task_entity',
            dto: 'task_dto',
          );

          // When
          final result = RepoBodyStreamTemplate.build(sequence);

          // Then
          expect(result, '''
    try {
      final stream = _localDataSource.watchTaskList();
      await for (final dtos in stream) {
        final entities = dtos.map((e) => e.toEntity()).toList();
        yield Result.success(entities);
      }
    } catch (e, st) {
      yield handleException('watchTaskList', e, st);
    }
''');
        },
      );
    });
  });
}
