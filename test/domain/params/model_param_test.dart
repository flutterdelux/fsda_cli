import 'package:fsda_cli/domain/enums/model_type.dart'; // Sesuaikan path import dengan project Anda
import 'package:fsda_cli/domain/models/prop_model.dart';
import 'package:fsda_cli/domain/params/feature_gate_param.dart';
import 'package:fsda_cli/domain/params/model_param.dart';
import 'package:test/test.dart';

void main() {
  group('ModelParam', () {
    const tFeatureGate = FeatureGateParam(
      featureName: 'task',
      featurePath: '/workspace/modules/todo/lib/src/features/task',
      moduleName: 'todo',
      modulePath: '/workspace/modules/todo',
    );

    const tProps = [
      PropModel(name: 'id', type: 'String', defaultValue: '', converter: ''),
      PropModel(name: 'title', type: 'String', defaultValue: '', converter: ''),
    ];

    test(
      'Given name, path, type, props, and isInjectL10n flag, '
      'When ModelParam is instantiated directly via constructor, '
      'Then it correctly holds all provided properties and inherited feature gate parameters',
      () {
        // Arrange (Given)
        const name = 'TaskModel';
        const path =
            '/workspace/modules/todo/lib/src/features/task/domain/models/task_model.dart';
        const type =
            ModelType.dto; // Sesuaikan dengan enum ModelType yang tersedia
        const isInjectL10n = true;

        // Act (When)
        final modelParam = ModelParam(
          name: name,
          path: path,
          type: type,
          props: tProps,
          isInjectL10n: isInjectL10n,
          featureName: tFeatureGate.featureName,
          featurePath: tFeatureGate.featurePath,
          moduleName: tFeatureGate.moduleName,
          modulePath: tFeatureGate.modulePath,
        );

        // Assert (Then)
        expect(modelParam.name, equals(name));
        expect(modelParam.path, equals(path));
        expect(modelParam.type, equals(type));
        expect(modelParam.props, equals(tProps));
        expect(modelParam.isInjectL10n, isTrue);
        expect(modelParam.featureName, equals(tFeatureGate.featureName));
        expect(modelParam.featurePath, equals(tFeatureGate.featurePath));
        expect(modelParam.moduleName, equals(tFeatureGate.moduleName));
        expect(modelParam.modulePath, equals(tFeatureGate.modulePath));
      },
    );

    test(
      'Given a FeatureGateParam and model specific fields, '
      'When ModelParam.fromFeatureGate factory is called, '
      'Then it correctly maps all properties from the feature gate with default isInjectL10n handling',
      () {
        // Arrange (Given)
        const name = 'TaskEntity';
        const path =
            '/workspace/modules/todo/lib/src/features/task/domain/models/task_entity.dart';
        const type = ModelType.entity;
        const isInjectL10n = false;

        // Act (When)
        final modelParam = ModelParam.fromFeatureGate(
          featureGate: tFeatureGate,
          name: name,
          path: path,
          type: type,
          props: tProps,
          isInjectL10n: isInjectL10n,
        );

        // Assert (Then)
        expect(modelParam.name, equals(name));
        expect(modelParam.path, equals(path));
        expect(modelParam.type, equals(type));
        expect(modelParam.props, equals(tProps));
        expect(modelParam.isInjectL10n, isFalse);
        expect(modelParam.featureName, equals(tFeatureGate.featureName));
        expect(modelParam.featurePath, equals(tFeatureGate.featurePath));
        expect(modelParam.moduleName, equals(tFeatureGate.moduleName));
        expect(modelParam.modulePath, equals(tFeatureGate.modulePath));
      },
    );
  });
}
