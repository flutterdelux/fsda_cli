import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/cubit_template.dart';
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

  group('CubitTemplate', () {
    test(
      'GIVEN a LogicParam with multiple props including duplicate types '
      'WHEN build is called '
      'THEN returns ArtifactGenerationModel with accurate metadata, deduplicated typesToImport, and Cubit content',
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
            defaultValue: 'TaskStatus.todo',
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
        final artifact = CubitTemplate.build(logic);

        // Then
        expect(artifact.name, 'TaskFilterCubit');
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
            'task_filter_cubit.dart',
          ),
        );
        expect(artifact.typesToImport, {'String', 'TaskStatus'});
        expect(artifact.needToExport, isTrue);
        expect(artifact.content, '''
import 'package:bloc/bloc.dart';
import 'task_filter_state.dart';

class TaskFilterCubit extends Cubit<TaskFilterState> {
  TaskFilterCubit() : super(const TaskFilterState());

  void updateState({
    String searchQuery,
    TaskStatus selectedStatus,
    String sortBy,
  }) {
    emit(TaskFilterState(
      searchQuery: searchQuery,
      selectedStatus: selectedStatus,
      sortBy: sortBy,
    ));
  }
}
''');
      },
    );

    test(
      'GIVEN a LogicParam with empty props '
      'WHEN build is called '
      'THEN returns empty typesToImport and Cubit with empty updateState parameters',
      () {
        // Given
        final logic = createLogic(props: const [], slice: 'empty_state');

        // When
        final artifact = CubitTemplate.build(logic);

        // Then
        expect(artifact.name, 'TaskEmptyStateCubit');
        expect(artifact.typesToImport, isEmpty);
        expect(artifact.needToExport, isTrue);
        expect(artifact.content, '''
import 'package:bloc/bloc.dart';
import 'task_empty_state_state.dart';

class TaskEmptyStateCubit extends Cubit<TaskEmptyStateState> {
  TaskEmptyStateCubit() : super(const TaskEmptyStateState());

  void updateState({
    
  }) {
    emit(TaskEmptyStateState(
      
    ));
  }
}
''');
      },
    );
  });
}
