import 'package:fsda_cli/core/extensions/sequence_param_x.dart';
import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/feature_gate_param.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:test/test.dart';

void main() {
  group('SequenceParam & SequenceParamX Tests', () {
    test(
      'should initialize SequenceParam and test factory constructor fromFeatureGate',
      () {
        const featureGate = FeatureGateParam(
          featureName: 'auth',
          featurePath: '/modules/auth/lib/src/features/auth',
          moduleName: 'auth_module',
          modulePath: '/modules/auth',
        );

        final param = SequenceParam.fromFeatureGate(
          featureGate: featureGate,
          action: Action.get,
          usecase: 'get_user_use_case',
          usecasePath: 'domain/usecases/get_user_use_case.dart',
          method: 'execute',
        );

        expect(param.featureName, 'auth');
        expect(param.action, Action.get);
        expect(param.usecase, 'get_user_use_case');
      },
    );

    test('should evaluate model presence flags and model types correctly', () {
      const paramWithEntityDto = SequenceParam(
        action: Action.get,
        usecase: 'get_user',
        usecasePath: 'path',
        method: 'call',
        entity: 'user_entity',
        dto: 'user_dto',
        featureName: 'auth',
        featurePath: '/path',
        moduleName: 'module',
        modulePath: '/path',
      );

      expect(paramWithEntityDto.hasEntity, isTrue);
      expect(paramWithEntityDto.hasDto, isTrue);
      expect(paramWithEntityDto.hasParam, isFalse);
      expect(paramWithEntityDto.hasRequest, isFalse);
      expect(paramWithEntityDto.hasReturnModel, isTrue);
      expect(paramWithEntityDto.hasParamModel, isFalse);
      expect(paramWithEntityDto.isReturn, isTrue);
      expect(paramWithEntityDto.isVoid, isFalse);

      const paramWithParamReq = SequenceParam(
        action: Action.post,
        usecase: 'login',
        usecasePath: 'path',
        method: 'call',
        param: 'login_param',
        request: 'login_request',
        featureName: 'auth',
        featurePath: '/path',
        moduleName: 'module',
        modulePath: '/path',
      );

      expect(paramWithParamReq.hasParam, isTrue);
      expect(paramWithParamReq.hasRequest, isTrue);
      expect(paramWithParamReq.hasParamModel, isTrue);
      expect(paramWithParamReq.isParam, isTrue);
    });

    test(
      'should format casing for usecase, base usecase, and methods correctly',
      () {
        const param = SequenceParam(
          action: Action.get,
          usecase: 'fetch_user_profile_use_case',
          usecasePath: 'path',
          method: 'fetch_data',
          featureName: 'profile',
          featurePath: '/path',
          moduleName: 'module',
          modulePath: '/path',
        );

        expect(param.ucSnake, 'fetch_user_profile_use_case');
        expect(param.ucCamel, 'fetchUserProfileUseCase');
        expect(param.ucPascal, 'FetchUserProfileUseCase');

        expect(param.ucBaseSnake, 'fetch_user_profile');
        expect(param.ucBaseCamel, 'fetchUserProfile');
        expect(param.ucBasePascal, 'FetchUserProfile');

        expect(param.methodSnake, 'fetch_data');
        expect(param.methodCamel, 'fetchData');
        expect(param.methodPascal, 'FetchData');
        expect(param.methodTitle, 'Fetch Data');
      },
    );

    test(
      'should evaluate data source variable, localStorageMethod, apiClientMethod, and httpStatus based on Action and FlowType',
      () {
        const getRemoteParam = SequenceParam(
          action: Action.get,
          usecase: 'get',
          usecasePath: 'path',
          method: 'get',
          flow: FlowType.stream,
          dsMode: DsMode.remote,
          featureName: 'auth',
          featurePath: '/path',
          moduleName: 'mod',
          modulePath: '/mod',
        );

        expect(getRemoteParam.dsVar, '_remoteDataSource');
        expect(getRemoteParam.localStorageMethod, 'read');
        expect(getRemoteParam.apiClientMethod, 'stream<Map<String, dynamic>>');
        expect(getRemoteParam.useBodyRequest, isFalse);
        expect(getRemoteParam.useQueryParam, isTrue);
        expect(getRemoteParam.httpStatus, 200);

        const postLocalParam = SequenceParam(
          action: Action.post,
          usecase: 'post',
          usecasePath: 'path',
          method: 'post',
          dsMode: DsMode.local,
          featureName: 'auth',
          featurePath: '/path',
          moduleName: 'mod',
          modulePath: '/mod',
        );

        expect(postLocalParam.dsVar, '_localDataSource');
        expect(postLocalParam.localStorageMethod, 'write');
        expect(postLocalParam.apiClientMethod, 'post<Map<String, dynamic>>');
        expect(postLocalParam.useBodyRequest, isTrue);
        expect(postLocalParam.useQueryParam, isFalse);
        expect(postLocalParam.httpStatus, 201);
      },
    );

    test('should generate correct file and directory paths', () {
      const param = SequenceParam(
        action: Action.delete,
        usecase: 'delete',
        usecasePath: 'path',
        method: 'delete',
        dsMode: DsMode.remote,
        featureName: 'auth',
        featurePath: '/modules/auth/lib/src/features/auth',
        moduleName: 'auth',
        modulePath: '/modules/auth',
      );

      expect(
        param.featureBarrelPath,
        '/modules/auth/lib/src/features/auth/auth_feature.dart',
      );
      expect(
        param.dsInterfacePath,
        '/modules/auth/lib/src/features/auth/data/datasources/auth_remote_data_source.dart',
      );
      expect(
        param.dsImplPath,
        '/modules/auth/lib/src/features/auth/data/datasources/auth_remote_data_source_impl.dart',
      );
      expect(
        param.repoInterfacePath,
        '/modules/auth/lib/src/features/auth/domain/repositories/auth_repository.dart',
      );
      expect(
        param.repoImplPath,
        '/modules/auth/lib/src/features/auth/data/repositories/auth_repository_impl.dart',
      );
    });

    test(
      'should evaluate hasResponse, isReturnParam, and model property casings correctly',
      () {
        const param = SequenceParam(
          action: Action.post,
          usecase: 'create_user',
          usecasePath: 'path',
          method: 'call',
          entity: 'user_entity',
          dto: 'user_dto',
          param: 'user_param',
          request: 'user_request',
          response: 'user_response',
          featureName: 'auth',
          featurePath: '/path',
          moduleName: 'module',
          modulePath: '/path',
        );

        expect(param.hasResponse, isTrue);
        expect(param.isReturnParam, isTrue);

        expect(param.responseSnake, 'user_response');
        expect(param.responseCamel, 'userResponse');
        expect(param.responsePascal, 'UserResponse');

        expect(param.dtoSnake, 'user_dto');
        expect(param.dtoCamel, 'userDto');
        expect(param.dtoPascal, 'UserDto');

        expect(param.entitySnake, 'user_entity');
        expect(param.entityCamel, 'userEntity');
        expect(param.entityPascal, 'UserEntity');

        expect(param.requestSnake, 'user_request');
        expect(param.requestCamel, 'userRequest');
        expect(param.requestPascal, 'UserRequest');

        expect(param.paramSnake, 'user_param');
        expect(param.paramCamel, 'userParam');
        expect(param.paramPascal, 'UserParam');
      },
    );

    test(
      'should handle ucBaseSnake when usecase does not end with _use_case',
      () {
        const param = SequenceParam(
          action: Action.get,
          usecase: 'fetch_data',
          usecasePath: 'path',
          method: 'get',
          featureName: 'auth',
          featurePath: '/path',
          moduleName: 'module',
          modulePath: '/path',
        );

        expect(param.ucBaseSnake, 'fetch_data');
        expect(param.ucBaseCamel, 'fetchData');
        expect(param.ucBasePascal, 'FetchData');
      },
    );

    test(
      'should evaluate localStorageMethod, apiClientMethod, and httpStatus for put, patch, and delete actions',
      () {
        const putParam = SequenceParam(
          action: Action.put,
          usecase: 'update',
          usecasePath: 'path',
          method: 'put',
          featureName: 'auth',
          featurePath: '/path',
          moduleName: 'mod',
          modulePath: '/mod',
        );
        expect(putParam.localStorageMethod, 'write');
        expect(putParam.apiClientMethod, 'put<Map<String, dynamic>>');
        expect(putParam.httpStatus, 200);

        const patchParam = SequenceParam(
          action: Action.patch,
          usecase: 'update_patch',
          usecasePath: 'path',
          method: 'patch',
          featureName: 'auth',
          featurePath: '/path',
          moduleName: 'mod',
          modulePath: '/mod',
        );
        expect(patchParam.localStorageMethod, 'write');
        expect(patchParam.apiClientMethod, 'patch<Map<String, dynamic>>');
        expect(patchParam.httpStatus, 200);

        const deleteParam = SequenceParam(
          action: Action.delete,
          usecase: 'delete',
          usecasePath: 'path',
          method: 'delete',
          featureName: 'auth',
          featurePath: '/path',
          moduleName: 'mod',
          modulePath: '/mod',
        );
        expect(deleteParam.localStorageMethod, 'remove');
        expect(deleteParam.apiClientMethod, 'delete');
        expect(deleteParam.httpStatus, 204);
      },
    );
  });
}
