import 'package:fsda_cli/domain/params/enum_param.dart'; // Sesuaikan path import dengan project Anda
import 'package:fsda_cli/domain/params/feature_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('EnumParam', () {
    const tFeatureGate = FeatureGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
    );

    test(
      'Given name, path, values, and isLower flag, '
      'When EnumParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited feature gate parameters',
      () {
        // Arrange (Given)
        const name = 'TaskStatus';
        const path =
            '/workspace/modules/todo/lib/src/features/task/domain/enums/task_status.dart';
        const values = ['pending', 'completed'];
        const isLower = true;

        // Act (When)
        final enumParam = EnumParam(
          name: name,
          path: path,
          values: values,
          isLower: isLower,
          featureName: tFeatureGate.featureName,
          featurePath: tFeatureGate.featurePath,
          moduleName: tFeatureGate.moduleName,
          modulePath: tFeatureGate.modulePath,
        );

        // Assert (Then)
        expect(enumParam.name, equals(name));
        expect(enumParam.path, equals(path));
        expect(enumParam.values, equals(values));
        expect(enumParam.isLower, isTrue);
        expect(enumParam.featureName, equals(tFeatureGate.featureName));
        expect(enumParam.featurePath, equals(tFeatureGate.featurePath));
        expect(enumParam.moduleName, equals(tFeatureGate.moduleName));
        expect(enumParam.modulePath, equals(tFeatureGate.modulePath));
      },
    );

    test('Given a FeatureGateParam and enum specific fields, '
        'When EnumParam.fromFeatureGate factory is called, '
        'Then it correctly maps all properties from the feature gate', () {
      // Arrange (Given)
      const name = 'Priority';
      const path =
          '/workspace/modules/todo/lib/src/features/task/domain/enums/priority.dart';
      const values = ['low', 'medium', 'high'];
      const isLower = false;

      // Act (When)
      final enumParam = EnumParam.fromFeatureGate(
        featureGate: tFeatureGate,
        name: name,
        path: path,
        values: values,
        isLower: isLower,
      );

      // Assert (Then)
      expect(enumParam.name, equals(name));
      expect(enumParam.path, equals(path));
      expect(enumParam.values, equals(values));
      expect(enumParam.isLower, isFalse);
      expect(enumParam.featureName, equals(tFeatureGate.featureName));
      expect(enumParam.featurePath, equals(tFeatureGate.featurePath));
      expect(enumParam.moduleName, equals(tFeatureGate.moduleName));
      expect(enumParam.modulePath, equals(tFeatureGate.modulePath));
    });
  });
}
