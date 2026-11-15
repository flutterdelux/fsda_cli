import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/repositories/repository_template.dart';
import 'package:test/test.dart';

void main() {
  group('RepositoryTemplate', () {
    // Helper untuk membuat SequenceParam dasar sesuai rule snake_case
    SequenceParam createTestParam({
      Action action = Action.get,
      String usecase = 'get_user_use_case',
      String usecasePath = 'path',
      String method = 'get_user',
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
      'Given feature name, '
      'When generating interface class, '
      'Then it should return correct abstract interface repository code template',
      () {
        // Given
        const feature = 'user_profile';

        // When
        final result = RepositoryTemplate.interfaceClass(feature);

        // Then
        expect(result, contains("import 'package:app_core/app_core.dart';"));
        expect(
          result,
          contains('abstract interface class UserProfileRepository {}'),
        );
      },
    );

    test(
      'Given feature name, '
      'When generating implementation class, '
      'Then it should return repository implementation class code template with mixin and logger',
      () {
        // Given
        const feature = 'user_profile';

        // When
        final result = RepositoryTemplate.implClass(feature);

        // Then
        expect(result, contains("import 'package:app_core/app_core.dart';"));
        expect(
          result,
          contains(
            "import '../../domain/repositories/user_profile_repository.dart';",
          ),
        );
        expect(result, contains('class UserProfileRepositoryImpl'));
        expect(result, contains('with RepositoryExceptionHandler'));
        expect(result, contains('implements UserProfileRepository'));
        expect(result, contains('final AppLogger _log;'));
        expect(result, contains('AppLogger get log => _log;'));
      },
    );

    test(
      'Given sequence param with synchronous flow and list entity, '
      'When generating interface method, '
      'Then it should return correct synchronous method signature with Result<List<Entity>>',
      () {
        // Given
        final sequence = createTestParam(
          method: 'get_users',
          flow: FlowType.synchronous,
          entity: 'user_entity',
          isList: true,
          param: 'user_param',
        );

        // When
        final result = RepositoryTemplate.interfaceMethod(sequence);

        // Then
        expect(
          result,
          equals('  Result<List<UserEntity>> getUsers(UserParam param);'),
        );
      },
    );

    test(
      'Given sequence param with asynchronous flow and single entity, '
      'When generating interface method, '
      'Then it should return correct asynchronous method signature with AsyncResult<Entity>',
      () {
        // Given
        final sequence = createTestParam(
          method: 'get_user',
          flow: FlowType.asynchronous,
          entity: 'user_entity',
          isList: false,
        );

        // When
        final result = RepositoryTemplate.interfaceMethod(sequence);

        // Then
        expect(result, equals('  AsyncResult<UserEntity> getUser();'));
      },
    );

    test(
      'Given sequence param with stream flow and void/null entity, '
      'When generating interface method, '
      'Then it should return correct stream method signature with StreamResult<void>',
      () {
        // Given
        final sequence = createTestParam(
          method: 'watch_status',
          flow: FlowType.stream,
          entity: null,
          isList: false,
        );

        // When
        final result = RepositoryTemplate.interfaceMethod(sequence);

        // Then
        expect(result, equals('  StreamResult<void> watchStatus();'));
      },
    );

    test(
      'Given sequence param with asynchronous flow and custom body, '
      'When generating implementation method, '
      'Then it should return complete overridden method implementation with async modifier and body content',
      () {
        // Given
        final sequence = createTestParam(
          method: 'update_user',
          flow: FlowType.asynchronous,
          entity: 'user_entity',
          isList: false,
          param: 'user_param',
        );
        const body = '    return const Result.success(null);';

        // When
        final result = RepositoryTemplate.implMethod(
          sequence: sequence,
          body: body,
        );

        // Then
        expect(result, contains('@override'));
        expect(
          result,
          contains(
            'AsyncResult<UserEntity> updateUser(UserParam param) async {',
          ),
        );
        expect(result, contains('    return const Result.success(null);'));
      },
    );

    test(
      'Given sequence param with stream flow and custom body, '
      'When generating implementation method, '
      'Then it should return complete overridden method implementation with async* modifier',
      () {
        // Given
        final sequence = createTestParam(
          method: 'stream_users',
          flow: FlowType.stream,
          entity: 'user_entity',
          isList: true,
        );
        const body = '    yield const Result.success([]);';

        // When
        final result = RepositoryTemplate.implMethod(
          sequence: sequence,
          body: body,
        );

        // Then
        expect(result, contains('@override'));
        expect(
          result,
          contains('StreamResult<List<UserEntity>> streamUsers() async* {'),
        );
        expect(result, contains('    yield const Result.success([]);'));
      },
    );
  });
}
