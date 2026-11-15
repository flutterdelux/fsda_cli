import '../../domain/enums/state_control.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';

extension StateControlX on StateControl {
  String get suffix => switch (this) {
    .cubit => 'cubit',
    .getx => 'controller',
    .provider => 'provider',
    .riverpod => 'provider',
  };
  String get suffixPascal => suffix.pascalCase;
}
