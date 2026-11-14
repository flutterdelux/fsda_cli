import 'package:fsda_cli/core/extensions/logic_flow_param_x.dart';
import 'package:fsda_cli/domain/enums/logic_flow_type.dart';
import 'package:fsda_cli/domain/enums/state_control.dart';
import 'package:fsda_cli/domain/enums/uc_type.dart';
import 'package:fsda_cli/domain/models/logic_uc_model.dart';
import 'package:fsda_cli/domain/params/logic_flow_param.dart';
import 'package:fsda_cli/domain/params/slice_gate_param.dart';
import 'package:test/test.dart';

void main() {
  group('LogicFlowParamX & LogicFlowParam Tests', () {
    test('should generate correct controller and state paths and casing', () {
      const param = LogicFlowParam(
        type: LogicFlowType.mutation,
        uc: LogicUcModel(
          name: 'update_profile',
          path: 'domain/usecases/update_profile_uc.dart',
          type: UcType.paramUc,
          method: 'execute',
        ),
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

    test(
      'should create LogicFlowParam correctly using fromSliceGate factory',
      () {
        const sliceGate = SliceGateParam(
          slice: 'account',
          featureName: 'settings',
          featurePath: '/modules/settings/lib/src/features/settings',
          moduleName: 'settings',
          modulePath: '/modules/settings',
        );

        final logicFlowParam = LogicFlowParam.fromSliceGate(
          sliceGate: sliceGate,
          type: LogicFlowType.retrieval,
          uc: const LogicUcModel(
            name: 'get_account',
            path: 'domain/usecases/get_account_uc.dart',
            type: UcType.returnUc,
            method: 'execute',
          ),
          control: StateControl.getx,
        );

        expect(logicFlowParam.slice, 'account');
        expect(logicFlowParam.featureName, 'settings');
        expect(
          logicFlowParam.featurePath,
          '/modules/settings/lib/src/features/settings',
        );
        expect(logicFlowParam.moduleName, 'settings');
        expect(logicFlowParam.modulePath, '/modules/settings');
        expect(logicFlowParam.type, LogicFlowType.retrieval);
        expect(logicFlowParam.control, StateControl.getx);
      },
    );
  });
}
