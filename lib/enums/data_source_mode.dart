enum DataSourceMode {
  both('both', 'Generate both remote and local datasource scaffolds'),
  remote('remote', 'Generate only remote datasource scaffold'),
  local('local', 'Generate only local datasource scaffold');

  final String value;
  final String description;

  const DataSourceMode(this.value, this.description);

  factory DataSourceMode.fromValue(String? rawValue) {
    final normalizedValue = rawValue?.trim();
    return values.firstWhere(
      (mode) => mode.value == normalizedValue,
      orElse: () => throw ArgumentError(
        'Unsupported datasource mode: $rawValue. Supported mode(ds): ${values.map((mode) => mode.value).join(', ')}',
      ),
    );
  }

  bool get includeRemote => this == both || this == remote;
  bool get includeLocal => this == both || this == local;
}
