import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repository_template.dart';
import 'package:test/test.dart';

void main() {
  SequenceParam createParam({
    String method = 'get_task_list',
    FlowType flow = FlowType.asynchronous,
    bool isList = false,
    String? entity,
    String? param,
  }) {
    return SequenceParam(
      action: Action.get,
      usecase: 'task_list_get_use_case',
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

  group('RepositoryTemplate', () {
    group('Injection Markers', () {
      test('GIVEN RepositoryTemplate constants '
          'WHEN marker constants are accessed '
          'THEN returns expected injection placeholder comments', () {
        // When & Then
        expect(RepositoryTemplate.markDsField, '// [_FIELD]');
        expect(RepositoryTemplate.markDsParam, '// [_PARAM]');
        expect(RepositoryTemplate.markDsInit, '// [_INIT]');
      });
    });

    group('interfaceClass', () {
      test(
        'GIVEN snake_case feature name '
        'WHEN interfaceClass is called '
        'THEN generates abstract interface Repository class with app_core import',
        () {
          // When
          final result = RepositoryTemplate.interfaceClass('user_profile');

          // Then
          expect(result, '''
import 'package:app_core/app_core.dart';

abstract interface class UserProfileRepository {}
''');
        },
      );
    });

    group('implClass', () {
      test(
        'GIVEN snake_case feature name '
        'WHEN implClass is called '
        'THEN generates RepositoryImpl class with RepositoryExceptionHandler mixin, AppLogger, and injection markers',
        () {
          // When
          final result = RepositoryTemplate.implClass('task');

          // Then
          expect(result, '''
import 'package:app_core/app_core.dart';

import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl
    with RepositoryExceptionHandler
    implements TaskRepository {
  final AppLogger _log;
  // [_FIELD]

  const TaskRepositoryImpl({
    required AppLogger appLogger,
    // [_PARAM]
  }) : // [_INIT]
       _log = appLogger;

  @override
  AppLogger get log => _log;
}
''');
        },
      );
    });

    group('interfaceMethod', () {
      test(
        'GIVEN SequenceParam instances across synchronous, asynchronous, and stream flows '
        'WHEN interfaceMethod is called '
        'THEN generates accurate method signatures for Result, AsyncResult, and StreamResult',
        () {
          // Synchronous void without param
          expect(
            RepositoryTemplate.interfaceMethod(
              createParam(method: 'clear_cache', flow: FlowType.synchronous),
            ),
            '  Result<void> clearCache();',
          );

          // Asynchronous single entity with param
          expect(
            RepositoryTemplate.interfaceMethod(
              createParam(
                method: 'create_task',
                flow: FlowType.asynchronous,
                entity: 'task_entity',
                param: 'task_create_param',
              ),
            ),
            '  AsyncResult<TaskEntity> createTask(TaskCreateParam param);',
          );

          // Stream List<Entity> with param
          expect(
            RepositoryTemplate.interfaceMethod(
              createParam(
                method: 'watch_task_list',
                flow: FlowType.stream,
                isList: true,
                entity: 'task_entity',
                param: 'task_filter_param',
              ),
            ),
            '  StreamResult<List<TaskEntity>> watchTaskList(TaskFilterParam param);',
          );
        },
      );
    });

    group('implMethod', () {
      test(
        'GIVEN synchronous SequenceParam '
        'WHEN implMethod is called '
        'THEN generates @override Result method without async modifier and trims trailing body whitespace',
        () {
          // Given
          final sequence = createParam(
            method: 'get_cached_task',
            flow: FlowType.synchronous,
            entity: 'task_entity',
          );

          // When
          final result = RepositoryTemplate.implMethod(
            sequence: sequence,
            body: '    return Result.success(TaskEntity());\n   ',
          );

          // Then
          expect(result, '''  @override
  Result<TaskEntity> getCachedTask() {
    return Result.success(TaskEntity());
  }''');
        },
      );

      test(
        'GIVEN asynchronous SequenceParam with param and List<Entity> '
        'WHEN implMethod is called '
        'THEN generates @override AsyncResult<List<Entity>> method with async modifier',
        () {
          // Given
          final sequence = createParam(
            method: 'get_task_list',
            flow: FlowType.asynchronous,
            isList: true,
            entity: 'task_entity',
            param: 'task_filter_param',
          );

          // When
          final result = RepositoryTemplate.implMethod(
            sequence: sequence,
            body: '    return Result.success([]);',
          );

          // Then
          expect(result, '''  @override
  AsyncResult<List<TaskEntity>> getTaskList(TaskFilterParam param) async {
    return Result.success([]);
  }''');
        },
      );

      test(
        'GIVEN stream SequenceParam '
        'WHEN implMethod is called '
        'THEN generates @override StreamResult<void> method with async* modifier',
        () {
          // Given
          final sequence = createParam(
            method: 'observe_task_updates',
            flow: FlowType.stream,
          );

          // When
          final result = RepositoryTemplate.implMethod(
            sequence: sequence,
            body: '    yield const Result.success(null);',
          );

          // Then
          expect(result, '''  @override
  StreamResult<void> observeTaskUpdates() async* {
    yield const Result.success(null);
  }''');
        },
      );
    });
  });
}
