import 'package:fsda_cli/core/extensions/slice_gate_param_x.dart';
import 'package:fsda_cli/domain/params/feature_gate_param.dart';
import 'package:fsda_cli/domain/params/slice_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('SliceGateParam & SliceGateParamX Tests', () {
    test(
      'should initialize SliceGateParam and test factory constructor fromFeatureGate',
      () {
        const featureGate = FeatureGateParam(
          featureName: 'auth',
          featurePath: '/modules/auth/lib/src/features/auth',
          moduleName: 'auth_module',
          modulePath: '/modules/auth',
        );

        final param = SliceGateParam.fromFeatureGate(
          featureGate: featureGate,
          slice: 'user_profile_slice',
        );

        expect(param.featureName, 'auth');
        expect(param.featurePath, '/modules/auth/lib/src/features/auth');
        expect(param.moduleName, 'auth_module');
        expect(param.modulePath, '/modules/auth');
        expect(param.slice, 'user_profile_slice');
      },
    );

    test('should format casing for slice string correctly', () {
      const param = SliceGateParam(
        featureName: 'auth',
        featurePath: '/path',
        moduleName: 'module',
        modulePath: '/path',
        slice: 'user_profile_slice',
      );

      expect(param.sliceSnake, 'user_profile_slice');
      expect(param.sliceCamel, 'userProfileSlice');
      expect(param.slicePascal, 'UserProfileSlice');
      expect(param.sliceTitle, 'User Profile Slice');
    });
  });
}
