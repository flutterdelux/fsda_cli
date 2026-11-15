import 'package:fsda_cli/domain/params/inputs/input_gate_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_text_area_param.dart';
import 'package:test/test.dart';

void main() {
  group('InputTextAreaParam', () {
    const tInputGate = InputGateParam(
      featureName: 'article',
      featurePath: '/workspace/modules/cms/lib/src/features/article',
      moduleName: 'cms',
      modulePath: '/workspace/modules/cms',
      field: 'content',
    );

    test(
      'Given feature details, field, and optional minLines and maxLines, '
      'When InputTextAreaParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties, inheriting input gate parameters and defaulting minLines and maxLines to 3 when omitted',
      () {
        // Arrange (Given)
        const featureName = 'article';
        const featurePath = '/workspace/modules/cms/lib/src/features/article';
        const moduleName = 'cms';
        const modulePath = '/workspace/modules/cms';
        const field = 'content';

        // Act (When)
        const paramDefault = InputTextAreaParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          field: field,
        );

        const paramCustom = InputTextAreaParam(
          featureName: featureName,
          featurePath: featurePath,
          moduleName: moduleName,
          modulePath: modulePath,
          field: field,
          minLines: 2,
          maxLines: 5,
        );

        // Assert (Then)
        expect(paramDefault.featureName, equals(featureName));
        expect(paramDefault.featurePath, equals(featurePath));
        expect(paramDefault.moduleName, equals(moduleName));
        expect(paramDefault.modulePath, equals(modulePath));
        expect(paramDefault.field, equals(field));
        expect(paramDefault.minLines, equals(3));
        expect(paramDefault.maxLines, equals(3));

        expect(paramCustom.minLines, equals(2));
        expect(paramCustom.maxLines, equals(5));
      },
    );

    test(
      'Given an InputGateParam instance and optional minLines and maxLines, '
      'When InputTextAreaParam.fromInputGate factory is called, '
      'Then it correctly maps all properties from the input gate and sets minLines and maxLines',
      () {
        // Act (When)
        final paramDefault = InputTextAreaParam.fromInputGate(
          inputGate: tInputGate,
        );
        final paramCustom = InputTextAreaParam.fromInputGate(
          inputGate: tInputGate,
          minLines: 4,
          maxLines: 8,
        );

        // Assert (Then)
        expect(paramDefault.featureName, equals(tInputGate.featureName));
        expect(paramDefault.featurePath, equals(tInputGate.featurePath));
        expect(paramDefault.moduleName, equals(tInputGate.moduleName));
        expect(paramDefault.modulePath, equals(tInputGate.modulePath));
        expect(paramDefault.field, equals(tInputGate.field));
        expect(paramDefault.minLines, equals(3));
        expect(paramDefault.maxLines, equals(3));

        expect(paramCustom.minLines, equals(4));
        expect(paramCustom.maxLines, equals(8));
      },
    );
  });
}
