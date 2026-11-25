import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/remote_ds_body_async_template.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/remote_ds_body_stream_template.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/remote_ds_body_template.dart';
import 'package:test/test.dart';

void main() {
  SequenceParam createParam({
    required FlowType flow,
    String? entity,
    String? dto,
  }) {
    return SequenceParam(
      action: Action.get,
      usecase: 'task_fetch_use_case',
      method: 'fetch_task',
      flow: flow,
      dsMode: DsMode.remote,
      entity: entity,
      dto: dto,
      featureName: 'task',
      moduleName: 'project_management',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('RemoteDsBodyTemplate', () {
    test('GIVEN a SequenceParam with FlowType.asynchronous '
        'WHEN build is called '
        'THEN delegates generation to RemoteDsBodyAsyncTemplate', () {
      // Given
      final sequence = createParam(
        flow: FlowType.asynchronous,
        entity: 'task_entity',
        dto: 'task_dto',
      );

      // When
      final result = RemoteDsBodyTemplate.build(sequence);

      // Then
      expect(result, RemoteDsBodyAsyncTemplate.build(sequence));
    });

    test('GIVEN a SequenceParam with FlowType.stream '
        'WHEN build is called '
        'THEN delegates generation to RemoteDsBodyStreamTemplate', () {
      // Given
      final sequence = createParam(
        flow: FlowType.stream,
        entity: 'task_entity',
        dto: 'task_dto',
      );

      // When
      final result = RemoteDsBodyTemplate.build(sequence);

      // Then
      expect(result, RemoteDsBodyStreamTemplate.build(sequence));
    });

    test(
      'GIVEN a SequenceParam with FlowType.synchronous '
      'WHEN build is called '
      'THEN throws an Exception indicating synchronous flow is unavailable for remote source',
      () {
        // Given
        final sequence = createParam(flow: FlowType.synchronous);

        // When & Then
        expect(
          () => RemoteDsBodyTemplate.build(sequence),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains(
                'Synchronous flow with source remote are not available.',
              ),
            ),
          ),
        );
      },
    );
  });
}
