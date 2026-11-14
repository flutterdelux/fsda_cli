import 'package:fsda_cli/core/extensions/module_gate_param_x.dart';
import 'package:fsda_cli/domain/params/module_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('ModuleGateParamX Tests', () {
    test('should format module name casing correctly', () {
      const param = ModuleGateParam(
        moduleName: 'user_management',
        modulePath: '/myapp/lib/modules/user_management',
      );

      expect(param.moduleSnake, 'user_management');
      expect(param.moduleCamel, 'userManagement');
      expect(param.modulePascal, 'UserManagement');
    });
  });
}
