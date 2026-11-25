import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/remote_ds_body_async_template.dart';
import 'package:test/test.dart';

void main() {
  SequenceParam createParam({
    Action action = Action.get,
    bool isList = false,
    String? entity,
    String? dto,
    String? param,
    String? request,
    String? response,
  }) {
    return SequenceParam(
      action: action,
      usecase: 'task_action_use_case',
      method: 'execute_task_action',
      flow: FlowType.asynchronous,
      dsMode: DsMode.remote,
      isList: isList,
      entity: entity,
      dto: dto,
      param: param,
      request: request,
      response: response,
      featureName: 'task',
      moduleName: 'project_management',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('RemoteDsBodyAsyncTemplate', () {
    group('ReturnParam Combination (isReturnParam)', () {
      test(
        'GIVEN Action.post with entity, dto, param, request, and response wrapper '
        'WHEN build is called '
        'THEN generates body request, status 201 check, and response wrapper parsing',
        () {
          // Given
          final sequence = createParam(
            action: Action.post,
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_create_param',
            request: 'task_create_request',
            response: 'task_response',
          );

          // When
          final result = RemoteDsBodyAsyncTemplate.build(sequence);

          // Then
          expect(result, '''
    final path = _basePath;
    final apiResponse = await _apiClient.post<Map<String, dynamic>>(
      path,
      body: request.toJson(),
    );

    if (apiResponse.statusCode == 201) {
      final response = TaskResponse.fromJson(apiResponse.body);
      if (response.data != null) return response.data!;

      throw CoreException.serverError(
        msg: 'Task is null',
        st: StackTrace.current,
      );
    }

    throw ProjectManagementException.fromApiResponse(apiResponse, st: StackTrace.current);
''');
        },
      );

      test(
        'GIVEN Action.get with entity, dto, param, and request without response wrapper '
        'WHEN build is called '
        'THEN generates queryParameters, status 200 check, and direct Map DTO parsing',
        () {
          // Given
          final sequence = createParam(
            action: Action.get,
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_detail_param',
            request: 'task_detail_request',
          );

          // When
          final result = RemoteDsBodyAsyncTemplate.build(sequence);

          // Then
          expect(result, '''
    final path = '\$_basePath/\${request.id}';
    final apiResponse = await _apiClient.get<Map<String, dynamic>>(
      path,
      queryParameters: request.toJson(),
    );

    if (apiResponse.statusCode == 200) {
      final data = apiResponse.body['data'];
      if (data is Map) {
        return TaskDto.fromJson(data as Map<String, dynamic>);
      }

      throw CoreException.serverError(
        msg: 'Task is null',
        st: StackTrace.current,
      );
    }

    throw ProjectManagementException.fromApiResponse(apiResponse, st: StackTrace.current);
''');
        },
      );

      test(
        'GIVEN Action.delete with entity, dto, param, request, and isList true '
        'WHEN build is called '
        'THEN generates empty queryParamStr, status 204 check, and direct List DTO parsing',
        () {
          // Given
          final sequence = createParam(
            action: Action.delete,
            isList: true,
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_delete_param',
            request: 'task_delete_request',
          );

          // When
          final result = RemoteDsBodyAsyncTemplate.build(sequence);

          // Then
          expect(result, '''
    final path = '\$_basePath/\${request.id}';
    final apiResponse = await _apiClient.delete(
      path,
      
    );

    if (apiResponse.statusCode == 204) {
      final data = apiResponse.body['data'];
      if (data is List) {
        return data
            .map((item) => TaskDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw CoreException.serverError(
        msg: 'Task is null',
        st: StackTrace.current,
      );
    }

    throw ProjectManagementException.fromApiResponse(apiResponse, st: StackTrace.current);
''');
        },
      );
    });

    group('Return Combination (isReturn)', () {
      test(
        'GIVEN Action.get with entity, dto, and isList true without response wrapper '
        'WHEN build is called '
        'THEN calls _basePath directly and maps List data to DTO list',
        () {
          // Given
          final sequence = createParam(
            action: Action.get,
            isList: true,
            entity: 'task_entity',
            dto: 'task_dto',
          );

          // When
          final result = RemoteDsBodyAsyncTemplate.build(sequence);

          // Then
          expect(result, '''
    final path = _basePath;
    final apiResponse = await _apiClient.get<Map<String, dynamic>>(path);

    if (apiResponse.statusCode == 200) {
      final data = apiResponse.body['data'];
      if (data is List) {
        return data
            .map((item) => TaskDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw CoreException.serverError(
        msg: 'Task is null',
        st: StackTrace.current,
      );
    }

    throw ProjectManagementException.fromApiResponse(apiResponse, st: StackTrace.current);
''');
        },
      );

      test('GIVEN Action.get with entity, dto, and response wrapper '
          'WHEN build is called '
          'THEN calls _basePath and extracts data using response wrapper', () {
        // Given
        final sequence = createParam(
          action: Action.get,
          entity: 'task_entity',
          dto: 'task_dto',
          response: 'task_response',
        );

        // When
        final result = RemoteDsBodyAsyncTemplate.build(sequence);

        // Then
        expect(result, '''
    final path = _basePath;
    final apiResponse = await _apiClient.get<Map<String, dynamic>>(path);

    if (apiResponse.statusCode == 200) {
      final response = TaskResponse.fromJson(apiResponse.body);
      if (response.data != null) return response.data!;

      throw CoreException.serverError(
        msg: 'Task is null',
        st: StackTrace.current,
      );
    }

    throw ProjectManagementException.fromApiResponse(apiResponse, st: StackTrace.current);
''');
      });
    });

    group('Param Combination (isParam)', () {
      test(
        'GIVEN Action.put with param and request only '
        'WHEN build is called '
        'THEN sends body request to path with id and returns early on matching httpStatus',
        () {
          // Given
          final sequence = createParam(
            action: Action.put,
            param: 'task_update_param',
            request: 'task_update_request',
          );

          // When
          final result = RemoteDsBodyAsyncTemplate.build(sequence);

          // Then
          expect(result, '''
    final path = '\$_basePath/\${request.id}';
    final apiResponse = await _apiClient.put<Map<String, dynamic>>(
      path,
      body: request.toJson(),
    );
    if (apiResponse.statusCode == 200) return;
    throw ProjectManagementException.fromApiResponse(apiResponse, st: StackTrace.current);
''');
        },
      );
    });

    group('Void Combination (isVoid)', () {
      test('GIVEN Action.post with no models '
          'WHEN build is called '
          'THEN calls _basePath directly and returns early on status 201', () {
        // Given
        final sequence = createParam(action: Action.post);

        // When
        final result = RemoteDsBodyAsyncTemplate.build(sequence);

        // Then
        expect(result, '''
    final path = _basePath;
    final apiResponse = await _apiClient.post<Map<String, dynamic>>(path);
    if (apiResponse.statusCode == 201) return;
    throw ProjectManagementException.fromApiResponse(apiResponse, st: StackTrace.current);
''');
      });
    });
  });
}
