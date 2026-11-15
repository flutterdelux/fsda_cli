import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repo_body_common_template.dart';
import 'package:test/test.dart';

void main() {
  group('RepoBodyCommonTemplate', () {
    // Helper untuk membuat SequenceParam dasar sesuai rule snake_case
    SequenceParam createTestParam({
      Action action = Action.get,
      String usecase = 'get_user_use_case',
      String usecasePath = 'path',
      String method = 'get_user', // Sesuai Rules.methodRegExp (snake_case)
      FlowType flow = FlowType.asynchronous,
      DsMode dsMode = DsMode.remote,
      bool isList = false,
      String? entity,
      String? entityPath,
      String? param,
      String? paramPath,
      String? dto,
      String? dtoPath,
      String? request,
      String? requestPath,
      String? response,
      String? responsePath,
    }) {
      return SequenceParam(
        action: action,
        usecase: usecase,
        usecasePath: usecasePath,
        method: method,
        flow: flow,
        dsMode: dsMode,
        isList: isList,
        entity: entity,
        entityPath: entityPath,
        param: param,
        paramPath: paramPath,
        dto: dto,
        dtoPath: dtoPath,
        request: request,
        requestPath: requestPath,
        response: response,
        responsePath: responsePath,
        featureName: 'user',
        featurePath: 'user',
        moduleName: 'core',
        modulePath: 'core',
      );
    }

    test(
      'Given sequence param with return and param (asynchronous, single), '
      'When building repo body, '
      'Then it should return correct code template with request mapping and single entity conversion',
      () {
        // Given
        final sequence = createTestParam(
          method: 'get_user', // snake_case
          flow: FlowType.asynchronous,
          entity: 'user_entity',
          dto: 'user_dto',
          request: 'user_request',
          param: 'user_param',
          isList: false,
        );

        // When
        final result = RepoBodyCommonTemplate.build(sequence);

        // Then
        // Berdasarkan SequenceParamX, method 'get_user' dengan camelCase akan menjadi 'getUser' di pemanggilan datasource
        expect(
          result,
          contains('final request = UserRequest.fromParam(param);'),
        );
        expect(
          result,
          contains('final dto = await _remoteDataSource.getUser(request);'),
        );
        expect(result, contains('final entity = dto.toEntity();'));
        expect(result, contains('return Result.success(entity);'));
        expect(result, contains("return handleException('getUser', e, st);"));
      },
    );

    test(
      'Given sequence param with return and param (synchronous, list), '
      'When building repo body, '
      'Then it should return correct code template without await and with list entities mapping',
      () {
        // Given
        final sequence = createTestParam(
          method: 'get_users', // snake_case
          flow: FlowType.synchronous,
          entity: 'user_entity',
          dto: 'user_dto',
          request: 'user_request',
          param: 'user_param',
          isList: true,
        );

        // When
        final result = RepoBodyCommonTemplate.build(sequence);

        // Then
        expect(
          result,
          contains('final request = UserRequest.fromParam(param);'),
        );
        expect(
          result,
          contains('final dtos = _remoteDataSource.getUsers(request);'),
        );
        expect(
          result,
          contains(
            'final entities = dtos.map((dto) => dto.toEntity()).toList();',
          ),
        );
        expect(result, contains('return Result.success(entities);'));
        expect(result, isNot(contains('await')));
      },
    );

    test(
      'Given sequence param with return only (single), '
      'When building repo body, '
      'Then it should return template without fromParam and with single entity conversion',
      () {
        // Given
        final sequence = createTestParam(
          method: 'get_profile', // snake_case
          entity: 'profile_entity',
          dto: 'profile_dto',
          isList: false,
        );

        // When
        final result = RepoBodyCommonTemplate.build(sequence);

        // Then
        expect(result, isNot(contains('fromParam')));
        expect(
          result,
          contains('final dto = await _remoteDataSource.getProfile();'),
        );
        expect(result, contains('final entity = dto.toEntity();'));
        expect(result, contains('return Result.success(entity);'));
      },
    );

    test(
      'Given sequence param with return only (list), '
      'When building repo body, '
      'Then it should return template without fromParam and with list entities conversion',
      () {
        // Given
        final sequence = createTestParam(
          method: 'get_profiles', // snake_case
          entity: 'profile_entity',
          dto: 'profile_dto',
          isList: true,
        );

        // When
        final result = RepoBodyCommonTemplate.build(sequence);

        // Then
        expect(
          result,
          contains('final dtos = await _remoteDataSource.getProfiles();'),
        );
        expect(
          result,
          contains(
            'final entities = dtos.map((dto) => dto.toEntity()).toList();',
          ),
        );
        expect(result, contains('return Result.success(entities);'));
      },
    );

    test(
      'Given sequence param with param only (no return), '
      'When building repo body, '
      'Then it should return template with request mapping and success null result',
      () {
        // Given
        final sequence = createTestParam(
          method: 'update_user', // snake_case
          request: 'user_request',
          param: 'user_param',
        );

        // When
        final result = RepoBodyCommonTemplate.build(sequence);

        // Then
        expect(
          result,
          contains('final request = UserRequest.fromParam(param);'),
        );
        expect(
          result,
          contains('await _remoteDataSource.updateUser(request);'),
        );
        expect(result, contains('return const Result.success(null);'));
        expect(
          result,
          contains("return handleException('updateUser', e, st);"),
        );
      },
    );

    test(
      'Given sequence param as void (no return and no param), '
      'When building repo body, '
      'Then it should return basic execution template with success null result',
      () {
        // Given
        final sequence = createTestParam(
          method: 'clear_cache', // snake_case
        );

        // When
        final result = RepoBodyCommonTemplate.build(sequence);

        // Then
        expect(result, isNot(contains('fromParam')));
        expect(result, contains('await _remoteDataSource.clearCache();'));
        expect(result, contains('return const Result.success(null);'));
        expect(
          result,
          contains("return handleException('clearCache', e, st);"),
        );
      },
    );
  });
}
