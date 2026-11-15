import 'package:fsda_cli/domain/params/inputs/input_gate_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_image_param.dart';
import 'package:test/test.dart';

void main() {
  group('InputImageParam', () {
    const tInputGate = InputGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
      field: 'avatar',
    );

    test(
      'Given feature details, field, and optional type, '
      'When InputImageParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and defaults type to "NetworkFile" when omitted',
      () {
        // Arrange (Given)
        const featureName = 'task';
        const featurePath = '/workspace/modules/todo/lib/src/features/task';
        const moduleName = 'todo';
        const modulePath = '/workspace/modules/todo';
        const field = 'avatar';

        // Act (When)
        const paramWithDefault = InputImageParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          field: field,
        );

        const paramWithCustom = InputImageParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          field: field,
          type: 'File',
        );

        // Assert (Then)
        expect(paramWithDefault.featureName, equals(featureName));
        expect(paramWithDefault.featurePath, equals(featurePath));
        expect(paramWithDefault.moduleName, equals(moduleName));
        expect(paramWithDefault.modulePath, equals(modulePath));
        expect(paramWithDefault.field, equals(field));
        expect(paramWithDefault.type, equals('NetworkFile'));

        expect(paramWithCustom.type, equals('File'));
      },
    );

    test(
      'Given an InputGateParam instance and optional valueType, '
      'When InputImageParam.fromInputGate factory is called, '
      'Then it correctly maps all properties from the input gate and sets the type accordingly',
      () {
        // Act (When)
        final paramDefault = InputImageParam.fromInputGate(
          inputGate: tInputGate,
        );
        final paramCustom = InputImageParam.fromInputGate(
          inputGate: tInputGate,
          valueType: 'LocalFile',
        );

        // Assert (Then)
        expect(paramDefault.featureName, equals(tInputGate.featureName));
        expect(paramDefault.featurePath, equals(tInputGate.featurePath));
        expect(paramDefault.moduleName, equals(tInputGate.moduleName));
        expect(paramDefault.modulePath, equals(tInputGate.modulePath));
        expect(paramDefault.field, equals(tInputGate.field));
        expect(paramDefault.type, equals('NetworkFile'));

        expect(paramCustom.type, equals('LocalFile'));
      },
    );
  });
}
