import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/remote_ds_body_async_template.dart';
import 'package:test/test.dart';

void main() {
  group('RemoteDsBodyAsyncTemplate', () {
    group('Return + Param combinations', () {
      test(
        'Given sequence with isReturnParam true, Action.post (useBodyRequest), and response model, '
        'When build is called, '
        'Then it generates remote async body with body payload and response DTO parsing',
        () {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.post,
            usecase: 'create_user_use_case',
            usecasePath: '',
            method: 'create_user',
            flow: FlowType.asynchronous,
            dsMode: DsMode.remote,
            entity: 'user_entity',
            dto: 'user_dto',
            response: 'user_response',
            param: 'create_user_param',
            request: 'create_user_request',
            featureName: 'user_profile',
            featurePath: '',
            moduleName: 'auth',
            modulePath: '',
          );

          // Act (When)
          final result = RemoteDsBodyAsyncTemplate.build(sequence);

          // Assert (Then)
          expect(result, contains(r"final path = '$_basePath/${request.id}';"));
          expect(result, contains('await _apiClient.post'));
          expect(result, contains('body: request.toJson(),'));
          expect(
            result,
            contains(
              'final response = UserResponse.fromJson(apiResponse.body);',
            ),
          );
          expect(
            result,
            contains('if (response.data != null) return response.data!;'),
          );
          expect(result, contains("msg: 'User Profile is null',"));
          expect(result, contains('throw AuthException.fromApiResponse('));
        },
      );

      test(
        'Given sequence with isReturnParam true, Action.get (useQueryParam), and direct single DTO (no response wrapper), '
        'When build is called, '
        'Then it generates remote async body with queryParameters and direct Map DTO parsing',
        () {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.get,
            usecase: 'get_user_detail_use_case',
            usecasePath: '',
            method: 'get_user_detail',
            flow: FlowType.asynchronous,
            dsMode: DsMode.remote,
            entity: 'user_entity',
            dto: 'user_dto',
            response: null,
            param: 'get_user_param',
            request: 'get_user_request',
            featureName: 'user',
            featurePath: '',
            moduleName: 'account',
            modulePath: '',
          );

          // Act (When)
          final result = RemoteDsBodyAsyncTemplate.build(sequence);

          // Assert (Then)
          expect(result, contains('await _apiClient.get'));
          expect(result, contains('queryParameters: request.toJson(),'));
          expect(result, contains("final data = apiResponse.body['data'];"));
          expect(result, contains('if (data is Map) {'));
          expect(
            result,
            contains('return UserDto.fromJson(data as Map<String, dynamic>);'),
          );
          expect(result, contains('throw AccountException.fromApiResponse('));
        },
      );

      test(
        'Given sequence with isReturnParam true, Action.delete (neither body nor query param), and isList true, '
        'When build is called, '
        'Then it generates remote async body without request payload and with List DTO parsing',
        () {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.delete,
            usecase: 'delete_user_use_case',
            usecasePath: '',
            method: 'delete_user',
            flow: FlowType.asynchronous,
            dsMode: DsMode.remote,
            isList: true,
            entity: 'user_entity',
            dto: 'user_dto',
            response: null,
            param: 'delete_user_param',
            request: 'delete_user_request',
            featureName: 'user',
            featurePath: '',
            moduleName: 'account',
            modulePath: '',
          );

          // Act (When)
          final result = RemoteDsBodyAsyncTemplate.build(sequence);

          // Assert (Then)
          expect(result, contains('await _apiClient.delete'));
          expect(result, isNot(contains('body: request.toJson(),')));
          expect(result, isNot(contains('queryParameters: request.toJson(),')));
          expect(result, contains('if (data is List) {'));
          expect(
            result,
            contains(
              '.map((item) => UserDto.fromJson(item as Map<String, dynamic>))',
            ),
          );
        },
      );
    });

    group('Return only combinations', () {
      test(
        'Given sequence with isReturn true and response model, '
        'When build is called, '
        'Then it generates remote async get body using _basePath and response wrapper',
        () {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.get,
            usecase: 'get_profile_use_case',
            usecasePath: '',
            method: 'get_profile',
            flow: FlowType.asynchronous,
            dsMode: DsMode.remote,
            entity: 'profile_entity',
            dto: 'profile_dto',
            response: 'profile_response',
            featureName: 'profile',
            featurePath: '',
            moduleName: 'user',
            modulePath: '',
          );

          // Act (When)
          final result = RemoteDsBodyAsyncTemplate.build(sequence);

          // Assert (Then)
          expect(result, contains('final path = _basePath;'));
          expect(
            result,
            contains(
              'final apiResponse = await _apiClient.get<Map<String, dynamic>>(path);',
            ),
          );
          expect(
            result,
            contains(
              'final response = ProfileResponse.fromJson(apiResponse.body);',
            ),
          );
          expect(result, contains("msg: 'Profile is null',"));
          expect(result, contains('throw UserException.fromApiResponse('));
        },
      );

      test(
        'Given sequence with isReturn true, isList true, and direct DTO (no response wrapper), '
        'When build is called, '
        'Then it generates remote async get body with direct List DTO mapping',
        () {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.get,
            usecase: 'get_items_use_case',
            usecasePath: '',
            method: 'get_items',
            flow: FlowType.asynchronous,
            dsMode: DsMode.remote,
            isList: true,
            entity: 'item_entity',
            dto: 'item_dto',
            response: null,
            featureName: 'item',
            featurePath: '',
            moduleName: 'catalog',
            modulePath: '',
          );

          // Act (When)
          final result = RemoteDsBodyAsyncTemplate.build(sequence);

          // Assert (Then)
          expect(result, contains('final path = _basePath;'));
          expect(result, contains('if (data is List) {'));
          expect(
            result,
            contains(
              '.map((item) => ItemDto.fromJson(item as Map<String, dynamic>))',
            ),
          );
        },
      );
    });

    group('Param only & Void combinations', () {
      test(
        'Given sequence with isParam true, '
        'When build is called, '
        'Then it generates remote async mutation body with request.id path and body payload',
        () {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.put,
            usecase: 'update_user_use_case',
            usecasePath: '',
            method: 'update_user',
            flow: FlowType.asynchronous,
            dsMode: DsMode.remote,
            param: 'update_user_param',
            request: 'update_user_request',
            featureName: 'user',
            featurePath: '',
            moduleName: 'auth',
            modulePath: '',
          );

          // Act (When)
          final result = RemoteDsBodyAsyncTemplate.build(sequence);

          // Assert (Then)
          expect(result, contains(r"final path = '$_basePath/${request.id}';"));
          expect(
            result,
            contains('await _apiClient.put<Map<String, dynamic>>'),
          );
          expect(result, contains('body: request.toJson(),'));
          expect(
            result,
            contains('if (apiResponse.statusCode == 200) return;'),
          );
          expect(result, contains('throw AuthException.fromApiResponse('));
        },
      );

      test('Given sequence with isVoid true, '
          'When build is called, '
          'Then it generates remote async void body using _basePath', () {
        // Arrange (Given)
        const sequence = SequenceParam(
          action: Action.post,
          usecase: 'logout_use_case',
          usecasePath: '',
          method: 'logout',
          flow: FlowType.asynchronous,
          dsMode: DsMode.remote,
          featureName: 'session',
          featurePath: '',
          moduleName: 'auth',
          modulePath: '',
        );

        // Act (When)
        final result = RemoteDsBodyAsyncTemplate.build(sequence);

        // Assert (Then)
        expect(result, contains('final path = _basePath;'));
        expect(
          result,
          contains(
            'final apiResponse = await _apiClient.post<Map<String, dynamic>>(path);',
          ),
        );
        expect(result, contains('if (apiResponse.statusCode == 201) return;'));
        expect(result, contains('throw AuthException.fromApiResponse('));
      });
    });
  });
}
