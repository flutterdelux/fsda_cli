import 'dependency_metadata.dart';

class FeatureMetadata {
  final List<DependencyMetadata> datasources;
  final List<DependencyMetadata> repositories;
  final List<DependencyMetadata> useCases;
  final List<DependencyMetadata> logics;

  const FeatureMetadata({
    required this.datasources,
    required this.repositories,
    required this.useCases,
    required this.logics,
  });
}
