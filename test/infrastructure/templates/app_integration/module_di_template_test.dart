import 'package:fsda_cli/domain/models/dependency_metadata.dart';
import 'package:fsda_cli/domain/models/feature_metadata.dart';
import 'package:fsda_cli/domain/params/app_integration/reg_feature_param.dart';
import 'package:fsda_cli/infrastructure/templates/app_integration/module_di_template.dart';
import 'package:test/test.dart';

void main() {
  const regFeatureParam = RegFeatureParam(
    featureName: 'user_profile',
    moduleName: 'account',
    appName: 'portal_app',
    workspaceName: 'my_workspace',
    workspacePath: '/projects/my_workspace',
  );

  group('ModuleDiTemplate', () {
    test(
      'GIVEN an empty FeatureMetadata '
      'WHEN buildFeatureDiMethod is called '
      'THEN generates static _<featureCamel>Di method with section comment headers only',
      () {
        // Given
        const metadata = FeatureMetadata(
          datasources: [],
          repositories: [],
          useCases: [],
          logics: [],
        );

        // When
        final result = ModuleDiTemplate.buildFeatureDiMethod(
          param: regFeatureParam,
          metadata: metadata,
        );

        // Then
        expect(result, '''
  static void _userProfileDi() {
    // Datasources

    // Repositories

    // Usecases

    // Logic
  }
''');
      },
    );

    test(
      'GIVEN FeatureMetadata with datasources, repositories, useCases, and standard logics '
      'WHEN buildFeatureDiMethod is called '
      'THEN generates complete GetIt registration blocks with AppLogger param1 and registerFactory',
      () {
        // Given
        const metadata = FeatureMetadata(
          datasources: [
            DependencyMetadata(
              className: 'UserProfileRemoteDataSourceImpl',
              parameters: [
                DependencyParamMetadata(
                  name: 'apiClient',
                  type: 'ApiClient',
                  isNamed: true,
                ),
              ],
            ),
            DependencyMetadata(
              className: 'UserProfileLocalDataSourceImpl',
              parameters: [
                DependencyParamMetadata(
                  name: 'localStorage',
                  type: 'LocalStorage',
                  isNamed: false,
                ),
              ],
            ),
          ],
          repositories: [
            DependencyMetadata(
              className: 'UserProfileRepositoryImpl',
              parameters: [
                DependencyParamMetadata(
                  name: 'appLogger',
                  type: 'AppLogger',
                  isNamed: true,
                ),
                DependencyParamMetadata(
                  name: 'remoteDataSource',
                  type: 'UserProfileRemoteDataSource',
                  isNamed: true,
                ),
                DependencyParamMetadata(
                  name: 'localDataSource',
                  type: 'UserProfileLocalDataSource',
                  isNamed: false,
                ),
              ],
            ),
          ],
          useCases: [
            DependencyMetadata(
              className: 'GetUserProfileUseCase',
              parameters: [
                DependencyParamMetadata(
                  name: 'userProfileRepository',
                  type: 'UserProfileRepository',
                  isNamed: true,
                ),
              ],
            ),
            DependencyMetadata(
              className: 'SyncUserProfileUseCase',
              parameters: [
                DependencyParamMetadata(
                  name: 'repository',
                  type: 'UserProfileRepository',
                  isNamed: false,
                ),
              ],
            ),
          ],
          logics: [
            DependencyMetadata(
              className: 'UserProfileListCubit',
              parameters: [
                DependencyParamMetadata(
                  name: 'getUserProfileUseCase',
                  type: 'GetUserProfileUseCase',
                  isNamed: true,
                ),
              ],
            ),
          ],
        );

        // When
        final result = ModuleDiTemplate.buildFeatureDiMethod(
          param: regFeatureParam,
          metadata: metadata,
        );

        // Then
        expect(result, '''
  static void _userProfileDi() {
    // Datasources
    sl.registerLazySingleton<UserProfileRemoteDataSource>(
      () => UserProfileRemoteDataSourceImpl(
        apiClient: sl(),
      ),
    );
    sl.registerLazySingleton<UserProfileLocalDataSource>(
      () => UserProfileLocalDataSourceImpl(
        sl(),
      ),
    );

    // Repositories
    sl.registerLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(
        appLogger: sl(param1: 'UserProfileRepository'),
        remoteDataSource: sl(),
        sl(),
      ),
    );

    // Usecases
    sl.registerLazySingleton(
      () => GetUserProfileUseCase(
        userProfileRepository: sl(),
      ),
    );
    sl.registerLazySingleton(
      () => SyncUserProfileUseCase(
        sl(),
      ),
    );

    // Logic
    sl.registerFactory(
      () => UserProfileListCubit(
        getUserProfileUseCase: sl()
      ),
    );
  }
''');
      },
    );

    test(
      'GIVEN FeatureMetadata with logics requiring *Param or *Entity constructor arguments '
      'WHEN buildFeatureDiMethod is called '
      'THEN generates sl.registerFactoryParam passing external param to constructor',
      () {
        // Given
        const metadata = FeatureMetadata(
          datasources: [],
          repositories: [],
          useCases: [],
          logics: [
            DependencyMetadata(
              className: 'UserProfileDetailCubit',
              parameters: [
                DependencyParamMetadata(
                  name: 'getUserDetailUseCase',
                  type: 'GetUserDetailUseCase',
                  isNamed: true,
                ),
                DependencyParamMetadata(
                  name: 'param',
                  type: 'UserDetailParam',
                  isNamed: true,
                ),
              ],
            ),
            DependencyMetadata(
              className: 'UserProfileEditCubit',
              parameters: [
                DependencyParamMetadata(
                  name: 'updateUserUseCase',
                  type: 'UpdateUserUseCase',
                  isNamed: false,
                ),
                DependencyParamMetadata(
                  name: 'initialUser',
                  type: 'UserEntity',
                  isNamed: false,
                ),
              ],
            ),
          ],
        );

        // When
        final result = ModuleDiTemplate.buildFeatureDiMethod(
          param: regFeatureParam,
          metadata: metadata,
        );

        // Then
        expect(result, '''
  static void _userProfileDi() {
    // Datasources

    // Repositories

    // Usecases

    // Logic
    sl.registerFactoryParam<UserProfileDetailCubit, UserDetailParam, void>(
      (param, _) => UserProfileDetailCubit(
        getUserDetailUseCase: sl(),
        param: param,
      ),
    );
    sl.registerFactoryParam<UserProfileEditCubit, UserEntity, void>(
      (param, _) => UserProfileEditCubit(
        sl(),
        param,
      ),
    );
  }
''');
      },
    );
  });
}
