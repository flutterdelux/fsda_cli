import 'package:fsda_cli/core/extensions/input_gate_param_x.dart';
import 'package:fsda_cli/domain/params/feature_gate_param.dart';
import 'package:fsda_cli/domain/params/inputs/input_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('InputGateParamX & InputGateParam Tests', () {
    test('should generate correct widgetPath based on featureName and field', () {
      const param = InputGateParam(
        featureName: 'login',
        featurePath: '/modules/auth/lib/src/features/login',
        moduleName: 'auth',
        modulePath: '/modules/auth',
        field: 'email',
      );

      expect(
        param.widgetPath,
        '/modules/auth/lib/src/features/login/ui/shared/widgets/login_email_field.dart',
      );
    });

    test(
      'should create InputGateParam correctly using fromFeatureGate factory',
      () {
        const featureGate = FeatureGateParam(
          featureName: 'register',
          featurePath: '/modules/auth/lib/src/features/register',
          moduleName: 'auth',
          modulePath: '/modules/auth',
        );

        final inputGateParam = InputGateParam.fromFeatureGate(
          featureGate: featureGate,
          field: 'password',
        );

        expect(inputGateParam.featureName, 'register');
        expect(
          inputGateParam.featurePath,
          '/modules/auth/lib/src/features/register',
        );
        expect(inputGateParam.moduleName, 'auth');
        expect(inputGateParam.modulePath, '/modules/auth');
        expect(inputGateParam.field, 'password');
      },
    );
  });
}
