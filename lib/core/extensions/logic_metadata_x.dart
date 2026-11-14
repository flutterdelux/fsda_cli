import 'package:mason/mason.dart';

import '../../domain/models/logic_metadata.dart';

extension LogicMetadataX on LogicMetadata {
  String get objectName => className.snakeCase.camelCase;
}
