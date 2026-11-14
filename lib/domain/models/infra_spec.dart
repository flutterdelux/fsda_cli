class InfraSpec {
  final String name;
  final Set<String> appDependencies;
  final Set<String> externalDiImports;
  final String externalDiCode;
  final Set<String> coreDiImports;
  final String coreDiCode;

  const InfraSpec({
    required this.name,
    required this.appDependencies,
    required this.externalDiImports,
    required this.externalDiCode,
    required this.coreDiImports,
    required this.coreDiCode,
  });
}
