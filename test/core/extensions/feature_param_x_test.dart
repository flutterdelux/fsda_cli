import 'package:fsda_cli/core/extensions/feature_param_x.dart';
import 'package:fsda_cli/domain/params/feature_param.dart';
import 'package:fsda_cli/domain/params/module_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('FeatureParamX & FeatureParam Tests', () {
    test('should generate correct barrel and repository paths', () {
      const param = FeatureParam(
        name: 'user_profile',
        path: '/modules/auth/lib/src/features/user_profile',
        moduleName: 'auth',
        modulePath: '/modules/auth',
      );

      expect(
        param.featureBarrelPath,
        '/modules/auth/lib/src/features/user_profile/user_profile_feature.dart',
      );
      expect(
        param.repoInterfacePath,
        '/modules/auth/lib/src/features/user_profile/domain/repositories/user_profile_repository.dart',
      );
      expect(
        param.repoImplPath,
        '/modules/auth/lib/src/features/user_profile/data/repositories/user_profile_repository_impl.dart',
      );
    });

    test(
      'should create FeatureParam correctly using fromModuleGate factory',
      () {
        const moduleGate = ModuleGateParam(
          moduleName: 'settings',
          modulePath: '/modules/settings',
        );

        final featureParam = FeatureParam.fromModuleGate(
          moduleGate: moduleGate,
          name: 'account',
          path: '/modules/settings/lib/src/features/account',
        );

        expect(featureParam.name, 'account');
        expect(featureParam.path, '/modules/settings/lib/src/features/account');
        expect(featureParam.moduleName, 'settings');
        expect(featureParam.modulePath, '/modules/settings');
      },
    );
  });
}
