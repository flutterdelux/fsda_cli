import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repo_body_stream_template.dart';
import 'package:test/test.dart';

void main() {
  group('RepoBodyStreamTemplate', () {
    SequenceParam createTestParam({
      Action action = Action.get,
      String usecase = 'get_stream_user_use_case',
      String usecasePath = 'path',
      String method = 'get_stream_user',
      FlowType flow = FlowType.stream,
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
      'Given sequence param with return and param for stream (single, isList: false), '
      'When building repo body stream, '
      'Then it should return correct code template with request mapping, stream iteration for single dto, and yield success',
      () {
        // Given
        final sequence = createTestParam(
          method: 'get_stream_user',
          entity: 'user_entity',
          dto: 'user_dto',
          request: 'user_request',
          param: 'user_param',
          isList: false,
        );

        // When
        final result = RepoBodyStreamTemplate.build(sequence);

        // Then
        expect(
          result,
          contains('final request = UserRequest.fromParam(param);'),
        );
        expect(
          result,
          contains('final stream = _remoteDataSource.getStreamUser(request);'),
        );
        expect(result, contains('await for (final dto in stream) {'));
        expect(result, contains('final entity = dto.toEntity();'));
        expect(result, contains('yield Result.success(entity);'));
        expect(
          result,
          contains("yield handleException('getStreamUser', e, st);"),
        );
      },
    );

    test(
      'Given sequence param with return and param for stream (list, isList: true), '
      'When building repo body stream, '
      'Then it should return correct code template with request mapping, stream iteration for list dtos, and yield success',
      () {
        // Given
        final sequence = createTestParam(
          method: 'get_stream_users',
          entity: 'user_entity',
          dto: 'user_dto',
          request: 'user_request',
          param: 'user_param',
          isList: true,
        );

        // When
        final result = RepoBodyStreamTemplate.build(sequence);

        // Then
        expect(
          result,
          contains('final request = UserRequest.fromParam(param);'),
        );
        expect(
          result,
          contains('final stream = _remoteDataSource.getStreamUsers(request);'),
        );
        expect(result, contains('await for (final dtos in stream) {'));
        expect(
          result,
          contains('final entities = dtos.map((e) => e.toEntity()).toList();'),
        );
        expect(result, contains('yield Result.success(entities);'));
        expect(
          result,
          contains("yield handleException('getStreamUsers', e, st);"),
        );
      },
    );

    test(
      'Given sequence param with return only for stream (single, isList: false), '
      'When building repo body stream, '
      'Then it should return template without fromParam and with single dto stream yield',
      () {
        // Given
        final sequence = createTestParam(
          method: 'get_stream_profile',
          entity: 'profile_entity',
          dto: 'profile_dto',
          isList: false,
        );

        // When
        final result = RepoBodyStreamTemplate.build(sequence);

        // Then
        expect(result, isNot(contains('fromParam')));
        expect(
          result,
          contains('final stream = _remoteDataSource.getStreamProfile();'),
        );
        expect(result, contains('await for (final dto in stream) {'));
        expect(result, contains('final entity = dto.toEntity();'));
        expect(result, contains('yield Result.success(entity);'));
      },
    );

    test(
      'Given sequence param with return only for stream (list, isList: true), '
      'When building repo body stream, '
      'Then it should return template without fromParam and with list dtos stream yield',
      () {
        // Given
        final sequence = createTestParam(
          method: 'get_stream_profiles',
          entity: 'profile_entity',
          dto: 'profile_dto',
          isList: true,
        );

        // When
        final result = RepoBodyStreamTemplate.build(sequence);

        // Then
        expect(result, isNot(contains('fromParam')));
        expect(
          result,
          contains('final stream = _remoteDataSource.getStreamProfiles();'),
        );
        expect(result, contains('await for (final dtos in stream) {'));
        expect(
          result,
          contains('final entities = dtos.map((e) => e.toEntity()).toList();'),
        );
        expect(result, contains('yield Result.success(entities);'));
      },
    );

    test(
      'Given unsupported model combination for stream (e.g. param only or void), '
      'When building repo body stream, '
      'Then it should throw an Exception indicating stream flow only supports Return or Return+Param',
      () {
        // Given (Param only - bukan Return)
        final sequenceParamOnly = createTestParam(
          method: 'update_stream',
          request: 'user_request',
          param: 'user_param',
        );

        // Given (Void - tanpa return/param)
        final sequenceVoid = createTestParam(method: 'clear_stream');

        // When & Then
        expect(
          () => RepoBodyStreamTemplate.build(sequenceParamOnly),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Model combination not support for stream flow'),
            ),
          ),
        );

        expect(
          () => RepoBodyStreamTemplate.build(sequenceVoid),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Model combination not support for stream flow'),
            ),
          ),
        );
      },
    );
  });
}
