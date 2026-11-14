import 'package:fsda_cli/core/extensions/enum_param_x.dart';
import 'package:fsda_cli/domain/params/enum_param.dart';
import 'package:test/test.dart';

void main() {
  group('EnumParamX Tests', () {
    test('should generate correct featureBarrelPath', () {
      final param = const EnumParam(
        name: 'status',
        path: '/modules/settings/lib/src/features/domain/enums/status',
        values: ['active', 'inactive'],
        featureName: 'status',
        featurePath: '/myapp/lib/modules/settings/lib/src/features/status',
        moduleName: 'settings',
        modulePath: '/myapp/lib/modules/settings',
        isLower: false,
      );

      expect(
        param.featureBarrelPath,
        '/myapp/lib/modules/settings/lib/src/features/status/status_feature.dart',
      );
    });
  });
}
