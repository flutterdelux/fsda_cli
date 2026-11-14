import 'package:fsda_cli/core/extensions/logic_param_x.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/params/logic_param.dart';
import 'package:fsda_cli/domain/params/slice_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('LogicParamX & LogicParam Tests', () {
    test('should generate correct controller and state paths and casing', () {
      const param = LogicParam(
        props: [],
        control: StateControl.cubit,
        featureName: 'user_profile',
        featurePath: '/modules/auth/lib/src/features/user_profile',
        moduleName: 'auth',
        modulePath: '/modules/auth',
        slice: 'settings',
      );

      expect(param.controllerSnake, 'user_profile_settings_cubit');
      expect(param.controllerCamel, 'userProfileSettingsCubit');
      expect(param.controllerPascal, 'UserProfileSettingsCubit');
      expect(
        param.controllerPath,
        '/modules/auth/lib/src/features/user_profile/logic/settings/user_profile_settings_cubit.dart',
      );

      expect(param.stateSnake, 'user_profile_settings_state');
      expect(param.statePascal, 'UserProfileSettingsState');
      expect(
        param.statePath,
        '/modules/auth/lib/src/features/user_profile/logic/settings/user_profile_settings_state.dart',
      );
    });

    test('should create LogicParam correctly using fromSliceGate factory', () {
      const sliceGate = SliceGateParam(
        slice: 'account',
        featureName: 'settings',
        featurePath: '/modules/settings/lib/src/features/settings',
        moduleName: 'settings',
        modulePath: '/modules/settings',
      );

      final logicParam = LogicParam.fromSliceGate(
        sliceGate: sliceGate,
        props: const [],
        control: StateControl.getx,
      );

      expect(logicParam.slice, 'account');
      expect(logicParam.featureName, 'settings');
      expect(
        logicParam.featurePath,
        '/modules/settings/lib/src/features/settings',
      );
      expect(logicParam.moduleName, 'settings');
      expect(logicParam.modulePath, '/modules/settings');
      expect(logicParam.control, StateControl.getx);
    });
  });
}
