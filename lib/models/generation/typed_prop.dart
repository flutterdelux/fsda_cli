class TypedProp {
  const TypedProp({required this.type, required this.name, this.defaultValue});

  final String type;
  final String name;
  final String? defaultValue;

  String get normalizedType => type.replaceAll(' ', '');

  bool get isNullable => normalizedType.endsWith('?');

  String get typeWithoutNullability {
    if (!isNullable) {
      return normalizedType;
    }
    return normalizedType.substring(0, normalizedType.length - 1);
  }

  bool get hasDefault => defaultValue != null;

  bool get isRequired => !isNullable && !hasDefault;
}
