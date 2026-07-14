import 'package:app_core/app_core.dart';

import '../../../../shared/data/errors/{{module.snakeCase()}}_exception.dart';
import '{{feature.snakeCase()}}_remote_data_source.dart';

class {{feature.pascalCase()}}RemoteDataSourceImpl implements {{feature.pascalCase()}}RemoteDataSource {
  final ApiClient _apiClient;

  const {{feature.pascalCase()}}RemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  {{{retrieval_check_point}}}

  {{{mutation_check_point}}}
}
