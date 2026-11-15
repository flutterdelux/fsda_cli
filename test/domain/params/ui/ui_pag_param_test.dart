import 'package:fsda_cli/domain/params/ui/ui_gate_param.dart'; // Sesuaikan path import dengan project Anda
import 'package:fsda_cli/domain/params/ui/ui_pag_param.dart';
import 'package:test/test.dart';

void main() {
  group('UiPagParam', () {
    const tUiGate = UiGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      slice: 'task_pag',
      model: 'TaskModel',
    );

    test(
      'Given feature details, slice, and model, '
      'When UiPagParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited UI gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const slice = 'task_pag';
        const model = 'TaskModel';

        // Act (When)
        const uiPagParam = UiPagParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          slice: slice,
          model: model,
        );

        // Assert (Then)
        expect(uiPagParam.featureName, equals(featureName));
        expect(uiPagParam.featurePath, equals(featurePath));
        expect(uiPagParam.moduleName, equals(moduleName));
        expect(uiPagParam.modulePath, equals(modulePath));
        expect(uiPagParam.slice, equals(slice));
        expect(uiPagParam.model, equals(model));
      },
    );

    test('Given a UiGateParam instance, '
        'When UiPagParam.fromUiGate factory is called, '
        'Then it correctly maps all properties from the UI gate', () {
      // Act (When)
      final uiPagParam = UiPagParam.fromUiGate(tUiGate);

      // Assert (Then)
      expect(uiPagParam.featureName, equals(tUiGate.featureName));
      expect(uiPagParam.featurePath, equals(tUiGate.featurePath));
      expect(uiPagParam.moduleName, equals(tUiGate.moduleName));
      expect(uiPagParam.modulePath, equals(tUiGate.modulePath));
      expect(uiPagParam.slice, equals(tUiGate.slice));
      expect(uiPagParam.model, equals(tUiGate.model));
    });
  });
}
