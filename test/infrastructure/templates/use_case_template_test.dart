import 'package:fsda_cli/core/extensions/sequence_param_x.dart';
import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/use_case_template.dart';
import 'package:test/test.dart';

void main() {
  group('UseCaseTemplate Unit Tests', () {
    test(
      'Given an asynchronous sequence with entity, isList false, and param, '
      'When UseCaseTemplate.build is called, '
      'Then it generates a use case class string extending ReturnParamUseCase with correct async return type and parameters',
      () {
        // Given
        final sequence = const SequenceParam(
          action: Action.get,
          usecase: 'get_user_profile',
          usecasePath:
              '<workspace>/modules/profile/lib/src/features/user_profile/domain/usecases/get_user_profile.dart',
          method: 'get_user_profile',
          flow: FlowType.asynchronous,
          dsMode: DsMode.remote,
          isList: false,
          entity: 'user', // snake_case untuk modelling entity
          param: 'user_id', // snake_case untuk modelling param
          featureName: 'user_profile',
          featurePath:
              '<workspace>/modules/profile/lib/src/features/user_profile',
          moduleName: 'profile',
          modulePath: '<workspace>/modules/profile',
        );

        // When
        final result = UseCaseTemplate.build(sequence: sequence);

        // Then
        expect(
          result,
          contains(
            'class GetUserProfile extends ReturnParamUseCase<User, UserId>',
          ),
        );
        expect(result, contains('final UserProfileRepository _repository;'));
        expect(result, contains('AsyncResult<User> call(UserId param)'));
        expect(result, contains('return _repository.getUserProfile(param);'));
      },
    );

    test(
      'Given a synchronous sequence with list entity and no param, '
      'When UseCaseTemplate.build is called, '
      'Then it generates a use case class string extending ReturnSyncUseCase with list return type and no parameters',
      () {
        // Given
        final sequence = const SequenceParam(
          action: Action.get,
          usecase: 'get_products',
          usecasePath:
              '<workspace>/modules/shop/lib/src/features/product/domain/usecases/get_products.dart',
          method: 'get_products',
          flow: FlowType.synchronous,
          dsMode: DsMode.remote,
          isList: true,
          entity: 'product',
          param: null,
          featureName: 'product',
          featurePath: '<workspace>/modules/shop/lib/src/features/product',
          moduleName: 'shop',
          modulePath: '<workspace>/modules/shop',
        );

        // When
        final result = UseCaseTemplate.build(sequence: sequence);

        // Then
        expect(
          result,
          contains(
            'class GetProducts extends ReturnSyncUseCase<List<Product>>',
          ),
        );
        expect(result, contains('Result<List<Product>> call()'));
        expect(result, contains('return _repository.getProducts();'));
      },
    );

    test(
      'Given a stream sequence with entity only and no param, '
      'When UseCaseTemplate.build is called, '
      'Then it generates a use case class string extending ReturnStreamUseCase',
      () {
        // Given
        final sequence = const SequenceParam(
          action: Action.get,
          usecase: 'watch_user',
          usecasePath:
              '<workspace>/modules/auth/lib/src/features/user/domain/usecases/watch_user.dart',
          method: 'watch_user',
          flow: FlowType.stream,
          dsMode: DsMode.remote,
          isList: false,
          entity: 'user',
          param: null,
          featureName: 'user',
          featurePath: '<workspace>/modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: '<workspace>/modules/auth',
        );

        // When
        final result = UseCaseTemplate.build(sequence: sequence);

        // Then
        expect(
          result,
          contains('class WatchUser extends ReturnStreamUseCase<User>'),
        );
        expect(result, contains('StreamResult<User> call()'));
      },
    );

    test(
      'Given an asynchronous sequence with param only and no entity, '
      'When UseCaseTemplate.build is called, '
      'Then it generates a use case class string extending ParamUseCase with void return',
      () {
        // Given
        final sequence = const SequenceParam(
          action: Action.post,
          usecase: 'delete_user',
          usecasePath:
              '<workspace>/modules/auth/lib/src/features/user/domain/usecases/delete_user.dart',
          method: 'delete_user',
          flow: FlowType.asynchronous,
          dsMode: DsMode.remote,
          isList: false,
          entity: null,
          param: 'user_id',
          featureName: 'user',
          featurePath: '<workspace>/modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: '<workspace>/modules/auth',
        );

        // When
        final result = UseCaseTemplate.build(sequence: sequence);

        // Then
        expect(
          result,
          contains('class DeleteUser extends ParamUseCase<UserId>'),
        );
        expect(result, contains('AsyncResult<void> call(UserId param)'));
      },
    );

    test(
      'Given an asynchronous sequence with neither entity nor param (VoidUseCase), '
      'When UseCaseTemplate.build is called, '
      'Then it generates a use case class string extending VoidUseCase',
      () {
        // Given
        final sequence = const SequenceParam(
          action: Action.post,
          usecase: 'clear_cache',
          usecasePath:
              '<workspace>/modules/app/lib/src/features/settings/domain/usecases/clear_cache.dart',
          method: 'clear_cache',
          flow: FlowType.asynchronous,
          dsMode: DsMode.remote,
          isList: false,
          entity: null,
          param: null,
          featureName: 'settings',
          featurePath: '<workspace>/modules/app/lib/src/features/settings',
          moduleName: 'app',
          modulePath: '<workspace>/modules/app',
        );

        // When
        final result = UseCaseTemplate.build(sequence: sequence);

        // Then
        expect(result, contains('class ClearCache extends VoidUseCase'));
        expect(result, contains('AsyncResult<void> call()'));
      },
    );

    test(
      'Given a synchronous sequence with param only, '
      'When UseCaseTemplate.build is called, '
      'Then it generates a use case class string extending ParamSyncUseCase',
      () {
        // Given
        final sequence = const SequenceParam(
          action: Action.get,
          usecase: 'check_token',
          usecasePath:
              '<workspace>/modules/auth/lib/src/features/token/domain/usecases/check_token.dart',
          method: 'check_token',
          flow: FlowType.synchronous,
          dsMode: DsMode.remote,
          isList: false,
          entity: null,
          param: 'token',
          featureName: 'token',
          featurePath: '<workspace>/modules/auth/lib/src/features/token',
          moduleName: 'auth',
          modulePath: '<workspace>/modules/auth',
        );

        // When
        final result = UseCaseTemplate.build(sequence: sequence);

        // Then
        expect(
          result,
          contains('class CheckToken extends ParamSyncUseCase<Token>'),
        );
        expect(result, contains('Result<void> call(Token param)'));
      },
    );

    test(
      'Given a stream sequence with param only, '
      'When UseCaseTemplate.build is called, '
      'Then it generates a use case class string extending ParamStreamUseCase',
      () {
        // Given
        final sequence = const SequenceParam(
          action: Action.get,
          usecase: 'stream_status',
          usecasePath:
              '<workspace>/modules/status/lib/src/features/status/domain/usecases/stream_status.dart',
          method: 'stream_status',
          flow: FlowType.stream,
          dsMode: DsMode.remote,
          isList: false,
          entity: null,
          param: 'status_id',
          featureName: 'status',
          featurePath: '<workspace>/modules/status/lib/src/features/status',
          moduleName: 'status',
          modulePath: '<workspace>/modules/status',
        );

        // When
        final result = UseCaseTemplate.build(sequence: sequence);

        // Then
        expect(
          result,
          contains('class StreamStatus extends ParamStreamUseCase<StatusId>'),
        );
        expect(result, contains('StreamResult<void> call(StatusId param)'));
      },
    );

    test(
      'Given a synchronous sequence with entity and param, '
      'When UseCaseTemplate.build is called, '
      'Then it generates a use case class string extending ReturnParamSyncUseCase',
      () {
        // Given
        final sequence = const SequenceParam(
          action: Action.get,
          usecase: 'get_user_sync',
          usecasePath:
              '<workspace>/modules/auth/lib/src/features/user/domain/usecases/get_user_sync.dart',
          method: 'get_user_sync',
          flow: FlowType.synchronous,
          dsMode: DsMode.remote,
          isList: false,
          entity: 'user',
          param: 'user_id',
          featureName: 'user',
          featurePath: '<workspace>/modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: '<workspace>/modules/auth',
        );

        // When
        final result = UseCaseTemplate.build(sequence: sequence);

        // Then
        expect(
          result,
          contains(
            'class GetUserSync extends ReturnParamSyncUseCase<User, UserId>',
          ),
        );
        expect(result, contains('Result<User> call(UserId param)'));
      },
    );

    test(
      'Given a stream sequence with entity and param, '
      'When UseCaseTemplate.build is called, '
      'Then it generates a use case class string extending ReturnParamStreamUseCase',
      () {
        // Given
        final sequence = const SequenceParam(
          action: Action.get,
          usecase: 'watch_user_stream',
          usecasePath:
              '<workspace>/modules/auth/lib/src/features/user/domain/usecases/watch_user_stream.dart',
          method: 'watch_user_stream',
          flow: FlowType.stream,
          dsMode: DsMode.remote,
          isList: false,
          entity: 'user',
          param: 'user_id',
          featureName: 'user',
          featurePath: '<workspace>/modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: '<workspace>/modules/auth',
        );

        // When
        final result = UseCaseTemplate.build(sequence: sequence);

        // Then
        expect(
          result,
          contains(
            'class WatchUserStream extends ReturnParamStreamUseCase<User, UserId>',
          ),
        );
        expect(result, contains('StreamResult<User> call(UserId param)'));
      },
    );

    test(
      'Given a stream sequence with void (no entity, no param), '
      'When UseCaseTemplate.build is called, '
      'Then it generates a use case class string extending VoidStreamUseCase',
      () {
        // Given
        final sequence = const SequenceParam(
          action: Action.get,
          usecase: 'stream_ping',
          usecasePath:
              '<workspace>/modules/ping/lib/src/features/ping/domain/usecases/stream_ping.dart',
          method: 'stream_ping',
          flow: FlowType.stream,
          dsMode: DsMode.remote,
          isList: false,
          entity: null,
          param: null,
          featureName: 'ping',
          featurePath: '<workspace>/modules/ping/lib/src/features/ping',
          moduleName: 'ping',
          modulePath: '<workspace>/modules/ping',
        );

        // When
        final result = UseCaseTemplate.build(sequence: sequence);

        // Then
        expect(result, contains('class StreamPing extends VoidStreamUseCase'));
        expect(result, contains('StreamResult<void> call()'));
      },
    );

    test(
      'Given a sequence with specific action and method title details, '
      'When UseCaseTemplate.buildArbEntries is called, '
      'Then it returns a map containing correct ARB entries for action and success',
      () {
        // Given
        final sequence = const SequenceParam(
          action: Action.get,
          usecase:
              'get_user', // snake_case agar ucBaseCamel menghasilkan getUser
          usecasePath:
              '<workspace>/modules/auth/lib/src/features/user/domain/usecases/get_user.dart',
          method: 'get_user',
          featureName: 'user',
          featurePath: '<workspace>/modules/auth/lib/src/features/user',
          moduleName: 'auth',
          modulePath: '<workspace>/modules/auth',
        );

        // When
        final entries = UseCaseTemplate.buildArbEntries(sequence);

        // Then
        expect(
          entries,
          equals({
            'getUserAction': sequence.methodTitle,
            'getUserSuccess': '${sequence.methodTitle} Successfull',
          }),
        );
      },
    );
  });
}
