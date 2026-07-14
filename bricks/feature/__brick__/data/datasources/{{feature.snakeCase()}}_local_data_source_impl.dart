import 'package:app_core/app_core.dart';

import '{{feature.snakeCase()}}_local_data_source.dart';

class {{feature.pascalCase()}}LocalDataSourceImpl
    implements {{feature.pascalCase()}}LocalDataSource {
  final DatabaseClient _client;

  const {{feature.pascalCase()}}LocalDataSourceImpl({
    required DatabaseClient client,
  }) : _client = client;

  {{{retrieval_check_point}}}

  {{{mutation_check_point}}}
}
