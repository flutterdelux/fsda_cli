import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/feature_gate_param.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:test/test.dart';

void main() {
  group('SequenceParam Tests', () {
    test(
      'should initialize with default and custom values using main constructor',
      () {
        const param = SequenceParam(
          action: Action.post,
          usecase: 'LoginUseCase',
          usecasePath: '/usecases/login_usecase.dart',
          method: 'login',
          featureName: 'auth',
          featurePath: '/features/auth',
          moduleName: 'modules',
          modulePath: '/modules',
        );

        expect(param.action, Action.post);
        expect(param.flow, FlowType.asynchronous);
        expect(param.dsMode, DsMode.remote);
        expect(param.isList, false);
        expect(param.entity, null);
      },
    );

    test('should initialize correctly using fromFeatureGate factory', () {
      const featureGate = FeatureGateParam(
        featureName: 'auth',
        featurePath: '/features/auth',
        moduleName: 'modules',
        modulePath: '/modules',
      );

      final param = SequenceParam.fromFeatureGate(
        featureGate: featureGate,
        action: Action.put,
        usecase: 'UpdateProfileUseCase',
        usecasePath: '/usecases/update_profile_usecase.dart',
        method: 'updateProfile',
        flow: FlowType.synchronous,
        dsMode: DsMode.local,
        isList: true,
        entity: 'UserEntity',
        entityPath: '/entities/user_entity.dart',
        dto: 'UserDto',
        dtoPath: '/dtos/user_dto.dart',
        request: 'UserRequest',
        requestPath: '/requests/user_request.dart',
        response: 'UserResponse',
        responsePath: '/responses/user_response.dart',
        param: 'UserIdParam',
        paramPath: '/params/user_id_param.dart',
      );

      expect(param.action, Action.put);
      expect(param.usecase, 'UpdateProfileUseCase');
      expect(param.flow, FlowType.synchronous);
      expect(param.dsMode, DsMode.local);
      expect(param.isList, true);
      expect(param.entity, 'UserEntity');
      expect(param.dto, 'UserDto');
      expect(param.request, 'UserRequest');
      expect(param.response, 'UserResponse');
      expect(param.param, 'UserIdParam');
      expect(param.featureName, 'auth');
    });
  });
}
