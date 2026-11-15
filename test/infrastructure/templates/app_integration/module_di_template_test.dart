import 'package:fsda_cli/domain/models/dependency_metadata.dart';
import 'package:fsda_cli/domain/models/feature_metadata.dart';
import 'package:fsda_cli/domain/params/app_integration/reg_feature_param.dart';
import 'package:fsda_cli/infrastructure/templates/app_integration/module_di_template.dart';
import 'package:test/test.dart';

void main() {
  group('ModuleDiTemplate', () {
    const tRegParam = RegFeatureParam(
      appName: 'my_app',
      appPath: '/app',
      moduleName: 'auth',
      modulePath: '/modules/auth',
      featureName: 'auth',
      featurePath: '/modules/auth/lib/src/features/auth',
    );

    test(
      'Given empty metadata lists for all dependencies, '
      'When buildFeatureDiMethod is called, '
      'Then it generates DI registration method with placeholder comments',
      () async {
        // Arrange (Given)
        const metadata = FeatureMetadata(
          datasources: [],
          repositories: [],
          useCases: [],
          logics: [],
        );

        // Act (When)
        final result = ModuleDiTemplate.buildFeatureDiMethod(
          param: tRegParam,
          metadata: metadata,
        );

        // Assert (Then)
        expect(result, contains('static void _authDi() {'));
        expect(result, contains('// Datasources'));
        expect(result, contains('// Repositories'));
        expect(result, contains('// Usecases'));
        expect(result, contains('// Logic'));
      },
    );

    test(
      'Given datasource metadata with ApiClient and regular parameters, '
      'When buildFeatureDiMethod is called, '
      'Then it generates lazy singleton registrations with proper argument injections',
      () async {
        // Arrange (Given)
        final metadata = const FeatureMetadata(
          datasources: [
            DependencyMetadata(
              className: 'AuthRemoteDatasourceImpl',
              parameters: [
                DependencyParamMetadata(
                  name: 'client',
                  type: 'ApiClient',
                  isNamed: true,
                ),
                DependencyParamMetadata(
                  name: 'logger',
                  type: 'OtherService',
                  isNamed: false,
                ),
              ],
            ),
          ],
          repositories: [],
          useCases: [],
          logics: [],
        );

        // Act (When)
        final result = ModuleDiTemplate.buildFeatureDiMethod(
          param: tRegParam,
          metadata: metadata,
        );

        // Assert (Then)
        expect(
          result,
          contains('sl.registerLazySingleton<AuthRemoteDatasource>('),
        );
        expect(result, contains('client: sl()'));
        expect(result, contains('sl()'));
      },
    );

    test(
      'Given repository metadata with AppLogger parameter, '
      'When buildFeatureDiMethod is called, '
      'Then it generates lazy singleton registrations with parameterized logger injection',
      () async {
        // Arrange (Given)
        final metadata = const FeatureMetadata(
          datasources: [],
          repositories: [
            DependencyMetadata(
              className: 'AuthRepositoryImpl',
              parameters: [
                DependencyParamMetadata(
                  name: 'appLogger',
                  type: 'AppLogger',
                  isNamed: true,
                ),
              ],
            ),
          ],
          useCases: [],
          logics: [],
        );

        // Act (When)
        final result = ModuleDiTemplate.buildFeatureDiMethod(
          param: tRegParam,
          metadata: metadata,
        );

        // Assert (Then)
        expect(result, contains('sl.registerLazySingleton<AuthRepository>('));
        expect(result, contains("appLogger: sl(param1: 'AuthRepository')"));
      },
    );

    test(
      'Given usecases metadata, '
      'When buildFeatureDiMethod is called, '
      'Then it generates lazy singleton registrations for usecases',
      () async {
        // Arrange (Given)
        final metadata = const FeatureMetadata(
          datasources: [],
          repositories: [],
          useCases: [
            DependencyMetadata(
              className: 'LoginUseCase',
              parameters: [
                DependencyParamMetadata(
                  name: 'repository',
                  type: 'AuthRepository',
                  isNamed: true,
                ),
              ],
            ),
          ],
          logics: [],
        );

        // Act (When)
        final result = ModuleDiTemplate.buildFeatureDiMethod(
          param: tRegParam,
          metadata: metadata,
        );

        // Assert (Then)
        expect(result, contains('sl.registerLazySingleton('));
        expect(result, contains('() => LoginUseCase('));
        expect(result, contains('repository: sl()'));
      },
    );

    test('Given logic metadata with external Param or Entity, '
        'When buildFeatureDiMethod is called, '
        'Then it generates registerFactoryParam registrations', () async {
      // Arrange (Given)
      final metadata = const FeatureMetadata(
        datasources: [],
        repositories: [],
        useCases: [],
        logics: [
          DependencyMetadata(
            className: 'AuthCubit',
            parameters: [
              DependencyParamMetadata(
                name: 'useCase',
                type: 'LoginUseCase',
                isNamed: false,
              ),
              DependencyParamMetadata(
                name: 'param',
                type: 'LoginParam',
                isNamed: true,
              ),
            ],
          ),
        ],
      );

      // Act (When)
      final result = ModuleDiTemplate.buildFeatureDiMethod(
        param: tRegParam,
        metadata: metadata,
      );

      // Assert (Then)
      expect(
        result,
        contains('sl.registerFactoryParam<AuthCubit, LoginParam, void>('),
      );
      expect(result, contains('(param, _) => AuthCubit('));
      expect(result, contains('param: param'));
    });

    test('Given standard logic metadata without external parameters, '
        'When buildFeatureDiMethod is called, '
        'Then it generates standard registerFactory registrations', () async {
      // Arrange (Given)
      final metadata = const FeatureMetadata(
        datasources: [],
        repositories: [],
        useCases: [],
        logics: [
          DependencyMetadata(
            className: 'SimpleCubit',
            parameters: [
              DependencyParamMetadata(
                name: 'useCase',
                type: 'LoginUseCase',
                isNamed: false,
              ),
            ],
          ),
        ],
      );

      // Act (When)
      final result = ModuleDiTemplate.buildFeatureDiMethod(
        param: tRegParam,
        metadata: metadata,
      );

      // Assert (Then)
      expect(result, contains('sl.registerFactory('));
      expect(result, contains('() => SimpleCubit('));
      expect(result, contains('sl()'));
    });
  });
}
