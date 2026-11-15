import 'package:fsda_cli/core/extensions/ui_gate_param_x.dart';
import 'package:fsda_cli/domain/params/ui/ui_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('UiGateParamX Extension', () {
    test('Given a UiGateParam with a model name, '
        'When extension properties (modelSnake, modelCamel, modelPascal, modelTitle) are accessed, '
        'Then it correctly formats the model string variations', () {
      // Arrange (Given)
      const uiParam = UiGateParam(
        featureName: 'task',
        featurePath: '/workspace/modules/todo/lib/src/features/task',
        moduleName: 'todo',
        modulePath: '/workspace/modules/todo',
        slice: 'task_view',
        model: 'task_dto',
      );

      // Act & Assert (When & Then)
      expect(uiParam.modelSnake, equals('task_dto'));
      expect(uiParam.modelCamel, equals('taskDto'));
      expect(uiParam.modelPascal, equals('TaskDto'));
      expect(uiParam.modelTitle, equals('Task Dto'));
    });
  });
}
