import 'package:fsda_cli/domain/params/ui/ui_gate_param.dart';
import 'package:fsda_cli/domain/params/ui/ui_param.dart';
import 'package:test/test.dart';

void main() {
  group('UiParam', () {
    const tUiGate = UiGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      slice: 'task_ui',
      model: 'TaskModel',
    );

    test(
      'Given feature details, slice, and model, '
      'When UiParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited UI gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const slice = 'task_ui';
        const model = 'TaskModel';

        // Act (When)
        const uiParam = UiParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          slice: slice,
          model: model,
        );

        // Assert (Then)
        expect(uiParam.featureName, equals(featureName));
        expect(uiParam.featurePath, equals(featurePath));
        expect(uiParam.moduleName, equals(moduleName));
        expect(uiParam.modulePath, equals(modulePath));
        expect(uiParam.slice, equals(slice));
        expect(uiParam.model, equals(model));
      },
    );

    test('Given a UiGateParam instance, '
        'When UiParam.fromUiGate factory is called, '
        'Then it correctly maps all properties from the UI gate', () {
      // Act (When)
      final uiParam = UiParam.fromUiGate(tUiGate);

      // Assert (Then)
      expect(uiParam.featureName, equals(tUiGate.featureName));
      expect(uiParam.featurePath, equals(tUiGate.featurePath));
      expect(uiParam.moduleName, equals(tUiGate.moduleName));
      expect(uiParam.modulePath, equals(tUiGate.modulePath));
      expect(uiParam.slice, equals(tUiGate.slice));
      expect(uiParam.model, equals(tUiGate.model));
    });
  });
}
