class ArtifactGenerationModel {
  final String name;
  final String path;
  final String content;
  final Set<String> typesToImport;
  final bool needToExport;

  ArtifactGenerationModel({
    required this.name,
    required this.path,
    required this.content,
    required this.typesToImport,
    required this.needToExport,
  });
}
