import 'package:fsda_cli/core/extensions/feature_gate_param_x.dart';
import 'package:fsda_cli/domain/params/feature_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('FeatureGateParamX Tests', () {
    test('should format feature name casing correctly', () {
      const param = FeatureGateParam(
        featureName: 'user_profile',
        featurePath: '/myapp/lib/modules/auth/features/user_profile',
        moduleName: 'auth',
        modulePath: '/myapp/lib/modules/auth',
      );

      expect(param.featureSnake, 'user_profile');
      expect(param.featureCamel, 'userProfile');
      expect(param.featurePascal, 'UserProfile');
      expect(param.featureTitle, 'User Profile');
    });

    test('should return correct feature barrel path', () {
      const param = FeatureGateParam(
        featureName: 'user_profile',
        featurePath: '/myapp/lib/modules/auth/features/user_profile',
        moduleName: 'auth',
        modulePath: '/myapp/lib/modules/auth',
      );

      expect(
        param.featureBarrelPath,
        '/myapp/lib/modules/auth/features/user_profile/user_profile_feature.dart',
      );
    });
  });
}
