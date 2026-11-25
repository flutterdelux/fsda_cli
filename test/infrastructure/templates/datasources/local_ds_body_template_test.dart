import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/local_ds_body_template.dart';
import 'package:test/test.dart';

void main() {
  SequenceParam createParam({
    Action action = Action.get,
    FlowType flow = FlowType.asynchronous,
    bool isList = false,
    String? entity,
    String? dto,
    String? param,
    String? request,
  }) {
    return SequenceParam(
      action: action,
      usecase: 'task_cache_use_case',
      method: 'handle_task_cache',
      flow: flow,
      dsMode: DsMode.local,
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

  group('LocalDsBodyTemplate', () {
    group('Error Cases', () {
      test('GIVEN a SequenceParam with FlowType.stream '
          'WHEN build is called '
          'THEN throws an Exception indicating stream is not supported', () {
        // Given
        final sequence = createParam(flow: FlowType.stream);

        // When & Then
        expect(
          () => LocalDsBodyTemplate.build(sequence),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Stream not supported yet for local data source.'),
            ),
          ),
        );
      });

      test(
        'GIVEN a SequenceParam with ReturnParam combination (entity, dto, param, and request) '
        'WHEN build is called '
        'THEN throws an Exception indicating invalid model combination',
        () {
          // Given
          final sequence = createParam(
            action: Action.post,
            entity: 'task_entity',
            dto: 'task_dto',
            param: 'task_create_param',
            request: 'task_create_request',
          );

          // When & Then
          expect(
            () => LocalDsBodyTemplate.build(sequence),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains(
                  'Model combination not valid for local storage: Available combinations: Return, Param, Void',
                ),
              ),
            ),
          );
        },
      );
    });

    group('Return Combination (isReturn)', () {
      test('GIVEN asynchronous SequenceParam with single DTO '
          'WHEN build is called '
          'THEN generates awaited read and Map decoding to single DTO', () {
        // Given
        final sequence = createParam(
          action: Action.get,
          flow: FlowType.asynchronous,
          isList: false,
          entity: 'task_entity',
          dto: 'task_dto',
        );

        // When
        final result = LocalDsBodyTemplate.build(sequence);

        // Then
        expect(result, '''
    final jsonString = await _localStorage.read(_cacheKey);
    if (jsonString == null || jsonString is! String) {
      return null;
    }
    
      final jsonMap = jsonDecode(jsonString);
      if (jsonMap is! Map) return null;

      return TaskDto.fromJson(jsonMap as Map<String, dynamic>);

''');
      });

      test(
        'GIVEN synchronous SequenceParam with List<DTO> '
        'WHEN build is called '
        'THEN generates non-awaited read and List decoding to mapped DTO list',
        () {
          // Given
          final sequence = createParam(
            action: Action.get,
            flow: FlowType.synchronous,
            isList: true,
            entity: 'task_entity',
            dto: 'task_dto',
          );

          // When
          final result = LocalDsBodyTemplate.build(sequence);

          // Then
          expect(result, '''
    final jsonString = _localStorage.read(_cacheKey);
    if (jsonString == null || jsonString is! String) {
      return null;
    }
    
      final jsonList = jsonDecode(jsonString);
      if (jsonList is! List) return null;

      return jsonList.map((e) => TaskDto.fromJson(e as Map<String, dynamic>)).toList();

''');
        },
      );
    });

    group('Param Combination (isParam)', () {
      test(
        'GIVEN asynchronous SequenceParam with Action.post, param, and request '
        'WHEN build is called '
        'THEN generates jsonEncode and awaited write call',
        () {
          // Given
          final sequence = createParam(
            action: Action.post,
            flow: FlowType.asynchronous,
            param: 'task_save_param',
            request: 'task_save_request',
          );

          // When
          final result = LocalDsBodyTemplate.build(sequence);

          // Then
          expect(result, '''
    final jsonString = jsonEncode(request.toJson());
    await _localStorage.write(_cacheKey, jsonString);
''');
        },
      );

      test(
        'GIVEN synchronous SequenceParam with Action.put, param, and request '
        'WHEN build is called '
        'THEN generates jsonEncode and non-awaited write call',
        () {
          // Given
          final sequence = createParam(
            action: Action.put,
            flow: FlowType.synchronous,
            param: 'task_update_param',
            request: 'task_update_request',
          );

          // When
          final result = LocalDsBodyTemplate.build(sequence);

          // Then
          expect(result, '''
    final jsonString = jsonEncode(request.toJson());
    _localStorage.write(_cacheKey, jsonString);
''');
        },
      );
    });

    group('Void Combination (isVoid)', () {
      test('GIVEN asynchronous SequenceParam with Action.delete and no models '
          'WHEN build is called '
          'THEN generates awaited remove call on _localStorage', () {
        // Given
        final sequence = createParam(
          action: Action.delete,
          flow: FlowType.asynchronous,
        );

        // When
        final result = LocalDsBodyTemplate.build(sequence);

        // Then
        expect(result, '''
    await _localStorage.remove(_cacheKey);
''');
      });

      test('GIVEN synchronous SequenceParam with Action.delete and no models '
          'WHEN build is called '
          'THEN generates non-awaited remove call on _localStorage', () {
        // Given
        final sequence = createParam(
          action: Action.delete,
          flow: FlowType.synchronous,
        );

        // When
        final result = LocalDsBodyTemplate.build(sequence);

        // Then
        expect(result, '''
    _localStorage.remove(_cacheKey);
''');
      });
    });
  });
}
