import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/data_source_template.dart';
import 'package:test/test.dart';

void main() {
  SequenceParam createParam({
    String method = 'get_task_list',
    FlowType flow = FlowType.asynchronous,
    bool isList = false,
    String? dto,
    String? request,
  }) {
    return SequenceParam(
      action: Action.get,
      usecase: 'task_list_get_use_case',
      method: method,
      flow: flow,
      isList: isList,
      dto: dto,
      request: request,
      featureName: 'task',
      moduleName: 'project_management',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('DataSourceTemplate', () {
    group('interfaceClass', () {
      test('GIVEN feature name and DsMode.remote '
          'WHEN interfaceClass is called '
          'THEN generates RemoteDataSource abstract interface class', () {
        // When
        final result = DataSourceTemplate.interfaceClass(
          feature: 'user_profile',
          mode: DsMode.remote,
        );

        // Then
        expect(result, '''
abstract interface class UserProfileRemoteDataSource {}
''');
      });

      test('GIVEN feature name and DsMode.local '
          'WHEN interfaceClass is called '
          'THEN generates LocalDataSource abstract interface class', () {
        // When
        final result = DataSourceTemplate.interfaceClass(
          feature: 'user_profile',
          mode: DsMode.local,
        );

        // Then
        expect(result, '''
abstract interface class UserProfileLocalDataSource {}
''');
      });
    });

    group('remoteImplClass', () {
      test(
        'GIVEN feature name and basePath '
        'WHEN remoteImplClass is called '
        'THEN generates RemoteDataSourceImpl class with ApiClient dependency and _basePath constant',
        () {
          // When
          final result = DataSourceTemplate.remoteImplClass(
            feature: 'task',
            basePath: '/tasks',
          );

          // Then
          expect(result, '''import 'package:app_core/app_core.dart';

import 'task_remote_data_source.dart';

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  static const _basePath = '/tasks';

  final ApiClient _apiClient;

  const TaskRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;
}
''');
        },
      );
    });

    group('localImplClass', () {
      test(
        'GIVEN feature name and cacheKey '
        'WHEN localImplClass is called '
        'THEN generates LocalDataSourceImpl class with LocalStorage dependency and _cacheKey constant',
        () {
          // When
          final result = DataSourceTemplate.localImplClass(
            feature: 'task',
            cacheKey: 'cached_tasks',
          );

          // Then
          expect(result, '''
import 'package:app_core/app_core.dart';

import 'task_local_data_source.dart';

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const _cacheKey = 'cached_tasks';

  final LocalStorage _localStorage;

  const TaskLocalDataSourceImpl({
    required LocalStorage localStorage,
  }) : _localStorage = localStorage;  

}
''');
        },
      );
    });

    group('interfaceMethod', () {
      test(
        'GIVEN SequenceParam instances across synchronous, asynchronous, and stream flows '
        'WHEN interfaceMethod is called '
        'THEN generates accurate method signatures for void, single DTO, and List<DTO> with or without request',
        () {
          // Synchronous void without request
          expect(
            DataSourceTemplate.interfaceMethod(
              createParam(method: 'clear_cache', flow: FlowType.synchronous),
            ),
            '  void clearCache();',
          );

          // Asynchronous single DTO with request
          expect(
            DataSourceTemplate.interfaceMethod(
              createParam(
                method: 'create_task',
                flow: FlowType.asynchronous,
                dto: 'task_dto',
                request: 'task_create_request',
              ),
            ),
            '  Future<TaskDto> createTask(TaskCreateRequest request);',
          );

          // Stream List<DTO> with request
          expect(
            DataSourceTemplate.interfaceMethod(
              createParam(
                method: 'watch_task_list',
                flow: FlowType.stream,
                isList: true,
                dto: 'task_dto',
                request: 'task_filter_request',
              ),
            ),
            '  Stream<List<TaskDto>> watchTaskList(TaskFilterRequest request);',
          );
        },
      );
    });

    group('implMethod', () {
      test(
        'GIVEN synchronous SequenceParam '
        'WHEN implMethod is called '
        'THEN generates @override method without async modifier and trims trailing body whitespace',
        () {
          // Given
          final sequence = createParam(
            method: 'get_cached_task',
            flow: FlowType.synchronous,
            dto: 'task_dto',
          );

          // When
          final result = DataSourceTemplate.implMethod(
            sequence: sequence,
            body: '    return TaskDto();\n   ',
          );

          // Then
          expect(result, '''  @override
  TaskDto getCachedTask() {
    return TaskDto();
  }''');
        },
      );

      test(
        'GIVEN asynchronous SequenceParam with request and List<DTO> '
        'WHEN implMethod is called '
        'THEN generates @override Future<List<DTO>> method with async modifier',
        () {
          // Given
          final sequence = createParam(
            method: 'get_task_list',
            flow: FlowType.asynchronous,
            isList: true,
            dto: 'task_dto',
            request: 'task_filter_request',
          );

          // When
          final result = DataSourceTemplate.implMethod(
            sequence: sequence,
            body: '    return [];',
          );

          // Then
          expect(result, '''  @override
  Future<List<TaskDto>> getTaskList(TaskFilterRequest request) async {
    return [];
  }''');
        },
      );

      test(
        'GIVEN stream SequenceParam '
        'WHEN implMethod is called '
        'THEN generates @override Stream<void> method with async* modifier',
        () {
          // Given
          final sequence = createParam(
            method: 'observe_task_updates',
            flow: FlowType.stream,
          );

          // When
          final result = DataSourceTemplate.implMethod(
            sequence: sequence,
            body: '    yield null;',
          );

          // Then
          expect(result, '''  @override
  Stream<void> observeTaskUpdates() async* {
    yield null;
  }''');
        },
      );
    });
  });
}
