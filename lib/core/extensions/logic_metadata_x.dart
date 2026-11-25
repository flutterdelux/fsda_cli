import 'package:collection/collection.dart';

import '../../domain/models/dependency_metadata.dart';
import '../../domain/models/logic_metadata.dart';
import '../../domain/models/prop_model.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'prop_list_x.dart';

extension LogicMetadataX on LogicMetadata {
  String get objectName => className.camelCase;

  DependencyParamMetadata? get externalParam =>
      parameters.firstWhereOrNull((p) => !p.type.endsWith('UseCase'));

  DependencyParamMetadata? get methodExternalParam =>
      methodParameters.firstWhereOrNull((p) => !p.type.endsWith('UseCase'));

  String buildSlCall({
    required List<PropModel> extProps,
    String accessorPrefix = '',
  }) {
    final ext = externalParam;
    if (ext == null) {
      return 'sl<$className>()';
    }
    final args = extProps.buildNamedArgs(accessorPrefix: accessorPrefix);
    return 'sl<$className>(param1: ${ext.type}($args))';
  }

  String buildMethodParamArg({
    required List<PropModel> extProps,
    String accessorPrefix = '',
  }) {
    final ext = methodExternalParam;
    if (ext == null) return '';

    final args = extProps.buildNamedArgs(accessorPrefix: accessorPrefix);
    if (ext.isNamed) {
      return '${ext.name}: ${ext.type}($args)';
    }
    return '${ext.type}($args)';
  }
}
