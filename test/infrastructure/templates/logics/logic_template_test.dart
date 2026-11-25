import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/infrastructure/templates/logics/cubit_flow_template.dart';
import 'package:fsda_cli/infrastructure/templates/logics/cubit_template.dart';
import 'package:fsda_cli/infrastructure/templates/logics/getx_flow_template.dart';
import 'package:fsda_cli/infrastructure/templates/logics/getx_template.dart';
import 'package:fsda_cli/infrastructure/templates/logics/logic_template.dart';
import 'package:fsda_cli/infrastructure/templates/logics/provider_flow_template.dart';
import 'package:fsda_cli/infrastructure/templates/logics/provider_template.dart';
import 'package:fsda_cli/infrastructure/templates/logics/riverpod_flow_template.dart';
import 'package:fsda_cli/infrastructure/templates/logics/riverpod_template.dart';
import 'package:test/test.dart';

void main() {
  LogicParam createLogic(StateControl control) {
    return LogicParam(
      props: const [
        PropModel(
          type: 'String',
          name: 'search_query',
          defaultValue: "''",
          converter: '',
        ),
      ],
      control: control,
      featureName: 'task',
      moduleName: 'project_management',
      sliceName: 'filter',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  const sampleUc = LogicUcModel(
    name: 'task_list_get_use_case',
    path: 'domain/usecases/task_list_get_use_case.dart',
    type: UcType.returnUc,
    repoMethod: 'getTaskList',
    returnType: 'List<TaskEntity>',
  );

  LogicFlowParam createLogicFlow(StateControl control) {
    return LogicFlowParam(
      type: LogicFlowType.retrieval,
      uc: '${sampleUc.name}.dart',
      control: control,
      featureName: 'task',
      moduleName: 'project_management',
      sliceName: 'list',
      workspaceName: 'my_workspace',
      workspacePath: '/projects/my_workspace',
    );
  }

  group('LogicTemplate', () {
    group('build', () {
      test(
        'GIVEN LogicParam across all StateControl variants '
        'WHEN build is called '
        'THEN delegates artifact generation to the corresponding state control template',
        () {
          // Given
          final cases = {
            StateControl.cubit: CubitTemplate.build,
            StateControl.getx: GetxTemplate.build,
            StateControl.provider: ProviderTemplate.build,
            StateControl.riverpod: RiverpodTemplate.build,
          };

          // When & Then
          cases.forEach((control, expectedBuilder) {
            final param = createLogic(control);
            final result = LogicTemplate.build(param);
            final expected = expectedBuilder(param);

            expect(result.name, expected.name);
            expect(result.path, expected.path);
            expect(result.content, expected.content);
            expect(result.typesToImport, expected.typesToImport);
            expect(result.needToExport, expected.needToExport);
          });
        },
      );
    });

    group('buildFlow', () {
      test(
        'GIVEN LogicFlowParam and LogicUcModel across all StateControl variants '
        'WHEN buildFlow is called '
        'THEN delegates flow artifact generation to the corresponding state control flow template',
        () {
          // Given
          final cases = {
            StateControl.cubit: CubitFlowTemplate.build,
            StateControl.getx: GetxFlowTemplate.build,
            StateControl.provider: ProviderFlowTemplate.build,
            StateControl.riverpod: RiverpodFlowTemplate.build,
          };

          // When & Then
          cases.forEach((control, expectedBuilder) {
            final param = createLogicFlow(control);
            final result = LogicTemplate.buildFlow(logic: param, uc: sampleUc);
            final expected = expectedBuilder(logic: param, uc: sampleUc);

            expect(result.name, expected.name);
            expect(result.path, expected.path);
            expect(result.content, expected.content);
            expect(result.typesToImport, expected.typesToImport);
            expect(result.needToExport, expected.needToExport);
          });
        },
      );
    });
  });
}
