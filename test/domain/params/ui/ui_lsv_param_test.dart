import 'package:fsda_cli/domain/params/ui/ui_gate_param.dart'; // Sesuaikan path import dengan project Anda
import 'package:fsda_cli/domain/params/ui/ui_lsv_param.dart';
import 'package:test/test.dart';

void main() {
  group('UiLsvParam', () {
    const tUiGate = UiGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      slice: 'task_lsv',
      model: 'TaskModel',
    );

    test(
      'Given feature details, slice, and model, '
      'When UiLsvParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited UI gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const slice = 'task_lsv';
        const model = 'TaskModel';

        // Act (When)
        const uiLsvParam = UiLsvParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          slice: slice,
          model: model,
        );

        // Assert (Then)
        expect(uiLsvParam.featureName, equals(featureName));
        expect(uiLsvParam.featurePath, equals(featurePath));
        expect(uiLsvParam.moduleName, equals(moduleName));
        expect(uiLsvParam.modulePath, equals(modulePath));
        expect(uiLsvParam.slice, equals(slice));
        expect(uiLsvParam.model, equals(model));
      },
    );

    test('Given a UiGateParam instance, '
        'When UiLsvParam.fromUiGate factory is called, '
        'Then it correctly maps all properties from the UI gate', () {
      // Act (When)
      final uiLsvParam = UiLsvParam.fromUiGate(tUiGate);

      // Assert (Then)
      expect(uiLsvParam.featureName, equals(tUiGate.featureName));
      expect(uiLsvParam.featurePath, equals(tUiGate.featurePath));
      expect(uiLsvParam.moduleName, equals(tUiGate.moduleName));
      expect(uiLsvParam.modulePath, equals(tUiGate.modulePath));
      expect(uiLsvParam.slice, equals(tUiGate.slice));
      expect(uiLsvParam.model, equals(tUiGate.model));
    });
  });
}
