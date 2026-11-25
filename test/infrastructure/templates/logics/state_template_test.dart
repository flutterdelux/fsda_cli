import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/state_template.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  LogicParam createLogic({
    List<PropModel> props = const [],
    String featureName = 'task',
    String slice = 'filter',
  }) {
    return LogicParam(
      props: props,
      control: StateControl.cubit,
      featureName: featureName,
      moduleName: 'project_management',
      sliceName: slice,
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('StateTemplate', () {
    test(
      'GIVEN a LogicParam with default, required, nullable, and duplicate-type props '
      'WHEN build is called '
      'THEN returns ArtifactGenerationModel with accurate metadata, deduplicated typesToImport, and Freezed state content',
      () {
        // Given
        const props = [
          PropModel(
            type: 'String',
            name: 'search_query',
            defaultValue: "''",
            converter: '',
          ),
          PropModel(
            type: 'TaskStatus',
            name: 'selected_status',
            defaultValue: '',
            converter: '',
          ),
          PropModel(
            type: 'String?',
            name: 'error_message',
            defaultValue: '',
            converter: '',
          ),
          PropModel(
            type: 'String',
            name: 'sort_by',
            defaultValue: "'created_at'",
            converter: '',
          ),
        ];
        final logic = createLogic(props: props, slice: 'filter');

        // When
        final artifact = StateTemplate.build(logic);

        // Then
        expect(artifact.name, 'TaskFilterState');
        expect(
          artifact.path,
          p.join(
            '/projects/my_workspace',
            'modules',
            'project_management',
            'lib',
            'src',
            'features',
            'task',
            'logic',
            'filter',
            'task_filter_state.dart',
          ),
        );
        expect(artifact.typesToImport, {'String', 'TaskStatus', 'String?'});
        expect(artifact.needToExport, isTrue);
        expect(artifact.content, '''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_filter_state.freezed.dart';

@freezed
sealed class TaskFilterState with _\$TaskFilterState {
  const factory TaskFilterState({
    @Default('') String searchQuery,
    required TaskStatus selectedStatus,
    String? errorMessage,
    @Default('created_at') String sortBy,
  }) = _TaskFilterState;
}
''');
      },
    );

    test(
      'GIVEN a LogicParam with empty props '
      'WHEN build is called '
      'THEN returns empty typesToImport and Freezed state with empty factory body',
      () {
        // Given
        final logic = createLogic(props: const [], slice: 'empty_state');

        // When
        final artifact = StateTemplate.build(logic);

        // Then
        expect(artifact.name, 'TaskEmptyStateState');
        expect(artifact.typesToImport, isEmpty);
        expect(artifact.needToExport, isTrue);
        expect(artifact.content, '''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_empty_state_state.freezed.dart';

@freezed
sealed class TaskEmptyStateState with _\$TaskEmptyStateState {
  const factory TaskEmptyStateState({

  }) = _TaskEmptyStateState;
}
''');
      },
    );
  });
}
