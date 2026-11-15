import 'package:fsda_cli/domain/params/ui/ui_gate_param.dart'; // Sesuaikan path import dengan project Anda
import 'package:fsda_cli/domain/params/ui/ui_lsh_param.dart';
import 'package:test/test.dart';

void main() {
  group('UiLshParam', () {
    const tUiGate = UiGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      slice: 'task_lsh',
      model: 'TaskModel',
    );

    test(
      'Given feature details, slice, and model, '
      'When UiLshParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited UI gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const slice = 'task_lsh';
        const model = 'TaskModel';

        // Act (When)
        const uiLshParam = UiLshParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          slice: slice,
          model: model,
        );

        // Assert (Then)
        expect(uiLshParam.featureName, equals(featureName));
        expect(uiLshParam.featurePath, equals(featurePath));
        expect(uiLshParam.moduleName, equals(moduleName));
        expect(uiLshParam.modulePath, equals(modulePath));
        expect(uiLshParam.slice, equals(slice));
        expect(uiLshParam.model, equals(model));
      },
    );

    test('Given a UiGateParam instance, '
        'When UiLshParam.fromUiGate factory is called, '
        'Then it correctly maps all properties from the UI gate', () {
      // Act (When)
      final uiLshParam = UiLshParam.fromUiGate(tUiGate);

      // Assert (Then)
      expect(uiLshParam.featureName, equals(tUiGate.featureName));
      expect(uiLshParam.featurePath, equals(tUiGate.featurePath));
      expect(uiLshParam.moduleName, equals(tUiGate.moduleName));
      expect(uiLshParam.modulePath, equals(tUiGate.modulePath));
      expect(uiLshParam.slice, equals(tUiGate.slice));
      expect(uiLshParam.model, equals(tUiGate.model));
    });
  });
}
