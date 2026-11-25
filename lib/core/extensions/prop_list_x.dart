import '../../domain/models/prop_model.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';

extension PropListX on List<PropModel> {
  List<PropModel> deduplicateProps() {
    final seen = <String>{};
    final unique = <PropModel>[];
    for (final prop in this) {
      final key = prop.name.camelCase;
      if (seen.add(key)) {
        unique.add(prop);
      }
    }
    return unique;
  }

  String buildNamedArgs({String accessorPrefix = ''}) {
    return deduplicateProps()
        .map((p) {
          final fieldName = p.name.camelCase;
          return '$fieldName: $accessorPrefix$fieldName';
        })
        .join(', ');
  }
}
