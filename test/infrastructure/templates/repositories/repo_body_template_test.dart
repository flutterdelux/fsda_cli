import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repo_body_common_template.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repo_body_stream_template.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repo_body_template.dart';
import 'package:test/test.dart';

void main() {
  SequenceParam createParam({
    required FlowType flow,
    String? entity = 'task_entity',
    String? dto = 'task_dto',
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

  group('RepoBodyTemplate', () {
    test('GIVEN a SequenceParam with FlowType.stream '
        'WHEN build is called '
        'THEN delegates generation to RepoBodyStreamTemplate', () {
      // Given
      final sequence = createParam(flow: FlowType.stream);

      // When
      final result = RepoBodyTemplate.build(sequence);

      // Then
      expect(result, RepoBodyStreamTemplate.build(sequence));
    });

    test('GIVEN a SequenceParam with FlowType.asynchronous '
        'WHEN build is called '
        'THEN delegates generation to RepoBodyCommonTemplate', () {
      // Given
      final sequence = createParam(flow: FlowType.asynchronous);

      // When
      final result = RepoBodyTemplate.build(sequence);

      // Then
      expect(result, RepoBodyCommonTemplate.build(sequence));
    });

    test('GIVEN a SequenceParam with FlowType.synchronous '
        'WHEN build is called '
        'THEN delegates generation to RepoBodyCommonTemplate', () {
      // Given
      final sequence = createParam(flow: FlowType.synchronous);

      // When
      final result = RepoBodyTemplate.build(sequence);

      // Then
      expect(result, RepoBodyCommonTemplate.build(sequence));
    });
  });
}
