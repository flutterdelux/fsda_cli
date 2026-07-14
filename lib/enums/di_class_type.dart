enum DiClassType {
  datasource,
  repository,
  usecase,
  logic;

  static DiClassType? fromValue(String value) {
    return switch (value) {
      final v when v.endsWith('DataSource') || v.endsWith('DataSourceImpl') =>
        DiClassType.datasource,
      final v when v.endsWith('Repository') || v.endsWith('RepositoryImpl') =>
        DiClassType.repository,
      final v when v.endsWith('UseCase') => DiClassType.usecase,
      final v when v.endsWith('Cubit') || v.endsWith('Bloc') =>
        DiClassType.logic,
      _ => null,
    };
  }
}
