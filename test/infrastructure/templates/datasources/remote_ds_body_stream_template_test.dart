import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/remote_ds_body_stream_template.dart';
import 'package:test/test.dart';

void main() {
  SequenceParam createParam({
    bool isList = false,
    String? entity,
    String? dto,
    String? param,
    String? request,
  }) {
    return SequenceParam(
      action: Action.get,
      usecase: 'task_watch_use_case',
      method: 'watch_task',
      flow: FlowType.stream,
      dsMode: DsMode.remote,
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

  group('RemoteDsBodyStreamTemplate', () {
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
              () => RemoteDsBodyStreamTemplate.build(sequence),
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
        'GIVEN SequenceParam with entity, dto, param, request, and isList false '
        'WHEN build is called '
        'THEN generates stream path with request.id and yields single DTO from Map',
        () {
          // Given
          final sequence = createParam(
            isList: false,
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_detail_param',
            request: 'task_detail_request',
          );

          // When
          final result = RemoteDsBodyStreamTemplate.build(sequence);

          // Then
          expect(result, '''
    final path = '\$_basePath/\${request.id}/stream';
    try {
      await for (final data in _apiClient.stream<Map<String, dynamic>>(path)) {
        yield TaskDto.fromJson(data);
      }
    } catch (e, st) {
      if (e is AppException) {
        if (e.message.contains('404')) {
          throw ProjectManagementException.taskNotFound(msg: e.message, st: st);
        }
      }
      throw ProjectManagementException.fromException(e, st: st);
    }
''');
        },
      );

      test(
        'GIVEN SequenceParam with entity, dto, param, request, and isList true '
        'WHEN build is called '
        'THEN generates stream path with request.id and yields mapped List of DTOs',
        () {
          // Given
          final sequence = createParam(
            isList: true,
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_sub_list_param',
            request: 'task_sub_list_request',
          );

          // When
          final result = RemoteDsBodyStreamTemplate.build(sequence);

          // Then
          expect(result, '''
    final path = '\$_basePath/\${request.id}/stream';
    try {
      await for (final data in _apiClient.stream<List>(path)) {
        yield data.map((e) => TaskDto.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e, st) {
      if (e is AppException) {
        if (e.message.contains('404')) {
          throw ProjectManagementException.taskNotFound(msg: e.message, st: st);
        }
      }
      throw ProjectManagementException.fromException(e, st: st);
    }
''');
        },
      );
    });

    group('Return Combination (isReturn)', () {
      test(
        'GIVEN SequenceParam with entity, dto, and isList false '
        'WHEN build is called '
        'THEN generates direct _basePath/stream and yields single DTO from Map',
        () {
          // Given
          final sequence = createParam(
            isList: false,
            entity: 'task_entity',
            dto: 'task_dto',
          );

          // When
          final result = RemoteDsBodyStreamTemplate.build(sequence);

          // Then
          expect(result, '''
    final path = '\$_basePath/stream';
    try {
      await for (final data in _apiClient.stream<Map<String, dynamic>>(path)) {
        yield TaskDto.fromJson(data);
      }
    } catch (e, st) {
      if (e is AppException) {
        if (e.message.contains('404')) {
          throw ProjectManagementException.taskNotFound(msg: e.message, st: st);
        }
      }
      throw ProjectManagementException.fromException(e, st: st);
    }
''');
        },
      );

      test(
        'GIVEN SequenceParam with entity, dto, and isList true '
        'WHEN build is called '
        'THEN generates direct _basePath/stream and yields mapped List of DTOs',
        () {
          // Given
          final sequence = createParam(
            isList: true,
            entity: 'task_entity',
            dto: 'task_dto',
          );

          // When
          final result = RemoteDsBodyStreamTemplate.build(sequence);

          // Then
          expect(result, '''
    final path = '\$_basePath/stream';
    try {
      await for (final data in _apiClient.stream<List>(path)) {
        yield data.map((e) => TaskDto.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e, st) {
      if (e is AppException) {
        if (e.message.contains('404')) {
          throw ProjectManagementException.taskNotFound(msg: e.message, st: st);
        }
      }
      throw ProjectManagementException.fromException(e, st: st);
    }
''');
        },
      );
    });
  });
}
