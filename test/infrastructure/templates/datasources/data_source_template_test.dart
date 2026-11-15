import 'package:fsda_cli/domain/enums/action.dart';
import 'package:fsda_cli/domain/enums/ds_mode.dart';
import 'package:fsda_cli/domain/enums/flow_type.dart';
import 'package:fsda_cli/domain/params/sequence_param.dart';
import 'package:fsda_cli/infrastructure/templates/datasources/data_source_template.dart';
import 'package:test/test.dart';

void main() {
  group('DataSourceTemplate', () {
    test('Given feature name and local/remote ds mode, '
        'When interfaceClass is called, '
        'Then it generates correct abstract interface class content', () async {
      // Arrange (Given)
      const feature = 'user_profile';

      // Act (When)
      final remoteResult = DataSourceTemplate.interfaceClass(
        feature: feature,
        mode: DsMode.remote,
      );
      final localResult = DataSourceTemplate.interfaceClass(
        feature: feature,
        mode: DsMode.local,
      );

      // Assert (Then)
      expect(
        remoteResult,
        contains('abstract interface class UserProfileRemoteDataSource {}'),
      );
      expect(
        localResult,
        contains('abstract interface class UserProfileLocalDataSource {}'),
      );
    });

    test(
      'Given feature name and base path, '
      'When remoteImplClass is called, '
      'Then it generates remote implementation class with ApiClient dependency',
      () async {
        // Arrange (Given)
        const feature = 'auth';
        const basePath = '/api/v1';

        // Act (When)
        final result = DataSourceTemplate.remoteImplClass(
          feature: feature,
          basePath: basePath,
        );

        // Assert (Then)
        expect(result, contains("import 'auth_remote_data_source.dart';"));
        expect(
          result,
          contains(
            'class AuthRemoteDataSourceImpl implements AuthRemoteDataSource',
          ),
        );
        expect(result, contains("static const _basePath = '/api/v1';"));
        expect(result, contains('final ApiClient _apiClient;'));
        expect(
          result,
          contains(
            'const AuthRemoteDataSourceImpl({required ApiClient apiClient})',
          ),
        );
      },
    );

    test(
      'Given feature name and cache key, '
      'When localImplClass is called, '
      'Then it generates local implementation class with LocalStorage dependency',
      () async {
        // Arrange (Given)
        const feature = 'settings';
        const cacheKey = 'SETTINGS_CACHE';

        // Act (When)
        final result = DataSourceTemplate.localImplClass(
          feature: feature,
          cacheKey: cacheKey,
        );

        // Assert (Then)
        expect(result, contains("import 'settings_local_data_source.dart';"));
        expect(
          result,
          contains(
            'class SettingsLocalDataSourceImpl implements SettingsLocalDataSource',
          ),
        );
        expect(result, contains("static const _cacheKey = 'SETTINGS_CACHE';"));
        expect(result, contains('final LocalStorage _localStorage;'));
        expect(result, contains('const SettingsLocalDataSourceImpl({'));
        expect(result, contains('required LocalStorage localStorage,'));
      },
    );

    group('interfaceMethod & implMethod variations', () {
      test('Given synchronous flow with single DTO and request, '
          'When interfaceMethod and implMethod are called, '
          'Then it generates correct sync method signature and body', () async {
        // Arrange (Given)
        const sequence = SequenceParam(
          action: Action.get,
          usecase: 'get_user_use_case',
          usecasePath: '',
          method: 'fetch_user', // Menggunakan snake_case
          flow: FlowType.synchronous,
          isList: false,
          dto: 'user_dto',
          request: 'user_request',
          featureName: 'user',
          featurePath: '',
          moduleName: 'app',
          modulePath: '',
        );

        // Act (When)
        const body = '    return UserDto();';
        final interfaceRes = DataSourceTemplate.interfaceMethod(sequence);
        final implRes = DataSourceTemplate.implMethod(
          sequence: sequence,
          body: body,
        );

        // Assert (Then)
        expect(
          interfaceRes,
          equals('  UserDto fetchUser(UserRequest request);'),
        );
        expect(implRes, contains('@override'));
        expect(implRes, contains('  UserDto fetchUser(UserRequest request) {'));
        expect(implRes, contains('    return UserDto();'));
      });

      test(
        'Given asynchronous flow returning list of DTOs without request, '
        'When interfaceMethod and implMethod are called, '
        'Then it generates async method with Future<List<Dto>> and async modifier',
        () async {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.get,
            usecase: 'get_users_use_case',
            usecasePath: '',
            method: 'fetch_users', // Menggunakan snake_case
            flow: FlowType.asynchronous,
            isList: true,
            dto: 'user_dto',
            request: null,
            featureName: 'user',
            featurePath: '',
            moduleName: 'app',
            modulePath: '',
          );

          // Act (When)
          const body = '    return [];';
          final interfaceRes = DataSourceTemplate.interfaceMethod(sequence);
          final implRes = DataSourceTemplate.implMethod(
            sequence: sequence,
            body: body,
          );

          // Assert (Then)
          expect(interfaceRes, equals('  Future<List<UserDto>> fetchUsers();'));
          expect(
            implRes,
            contains('  Future<List<UserDto>> fetchUsers() async {'),
          );
          expect(implRes, contains('    return [];'));
        },
      );

      test(
        'Given stream flow returning void when dto is null, '
        'When interfaceMethod is called, '
        'Then it generates Stream<void> return type and async* modifier',
        () async {
          // Arrange (Given)
          const sequence = SequenceParam(
            action: Action.get,
            usecase: 'watch_status_use_case',
            usecasePath: '',
            method: 'watch_status', // Menggunakan snake_case
            flow: FlowType.stream,
            isList: false,
            dto: null,
            request: null,
            featureName: 'status',
            featurePath: '',
            moduleName: 'app',
            modulePath: '',
          );

          // Act (When)
          const body = '    yield null;';
          final interfaceRes = DataSourceTemplate.interfaceMethod(sequence);
          final implRes = DataSourceTemplate.implMethod(
            sequence: sequence,
            body: body,
          );

          // Assert (Then)
          expect(interfaceRes, equals('  Stream<void> watchStatus();'));
          expect(implRes, contains('  Stream<void> watchStatus() async* {'));
          expect(implRes, contains('    yield null;'));
        },
      );
    });
  });
}
