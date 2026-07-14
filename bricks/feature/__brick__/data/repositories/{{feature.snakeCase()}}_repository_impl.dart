import 'package:app_core/app_core.dart';

import '../../domain/repositories/{{feature.snakeCase()}}_repository.dart';
import '../datasources/{{feature.snakeCase()}}_local_data_source.dart';
import '../datasources/{{feature.snakeCase()}}_remote_data_source.dart';

class {{feature.pascalCase()}}RepositoryImpl
    with RepositoryExceptionHandler
    implements {{feature.pascalCase()}}Repository {
  final AppLogger _log;
  final NetworkInfo _networkInfo;
  final {{feature.pascalCase()}}LocalDataSource _localDataSource;
  final {{feature.pascalCase()}}RemoteDataSource _remoteDataSource;

  const {{feature.pascalCase()}}RepositoryImpl({
    required AppLogger appLogger,
    required NetworkInfo networkInfo,
    required {{feature.pascalCase()}}LocalDataSource {{feature.camelCase()}}LocalDataSource,
    required {{feature.pascalCase()}}RemoteDataSource {{feature.camelCase()}}RemoteDataSource,
  }) : _log = appLogger,
       _networkInfo = networkInfo,
       _localDataSource = {{feature.camelCase()}}LocalDataSource,
       _remoteDataSource = {{feature.camelCase()}}RemoteDataSource;

  @override
  AppLogger get log => _log;

  {{{retrieval_check_point}}}

  {{{mutation_check_point}}}
}