import 'package:fsda_cli/domain/params/slice_gate_param.dart';
import 'package:fsda_cli/domain/params/ui/ui_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('UiGateParam', () {
    const tSliceGate = SliceGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      slice: 'task_list',
    );

    test(
      'Given feature details, slice, and model, '
      'When UiGateParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited slice/feature gate parameters',
      () {
        // Arrange (Given)
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const slice = 'task_list';
        const model = 'TaskModel';

        // Act (When)
        const uiGateParam = UiGateParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          slice: slice,
          model: model,
        );

        // Assert (Then)
        expect(uiGateParam.featureName, equals(featureName));
        expect(uiGateParam.featurePath, equals(featurePath));
        expect(uiGateParam.moduleName, equals(moduleName));
        expect(uiGateParam.modulePath, equals(modulePath));
        expect(uiGateParam.slice, equals(slice));
        expect(uiGateParam.model, equals(model));
      },
    );

    test(
      'Given a SliceGateParam instance and model name, '
      'When UiGateParam.fromSliceGate factory is called, '
      'Then it correctly maps all properties from the slice gate and sets the model',
      () {
        // Arrange (Given)
        const modelName = 'TaskDetailModel';

        // Act (When)
        final uiGateParam = UiGateParam.fromSliceGate(
          sliceGate: tSliceGate,
          model: modelName,
        );

        // Assert (Then)
        expect(uiGateParam.featureName, equals(tSliceGate.featureName));
        expect(uiGateParam.featurePath, equals(tSliceGate.featurePath));
        expect(uiGateParam.moduleName, equals(tSliceGate.moduleName));
        expect(uiGateParam.modulePath, equals(tSliceGate.modulePath));
        expect(uiGateParam.slice, equals(tSliceGate.slice));
        expect(uiGateParam.model, equals(modelName));
      },
    );
  });
}
