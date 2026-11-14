class DependencyMetadata {
  final String className;
  final List<DependencyParamMetadata> parameters;

  const DependencyMetadata({required this.className, required this.parameters});
}

class DependencyParamMetadata {
  final String name;
  final String type;
  final bool isNamed;
  final String? defaultValue;

  const DependencyParamMetadata({
    required this.name,
    required this.type,
    this.isNamed = false,
    this.defaultValue,
  });
}
