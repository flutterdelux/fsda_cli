import 'package:args/args.dart';

extension ArgResultsX on ArgResults {
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    for (final optionName in options) {
      if (wasParsed(optionName) || this[optionName] != null) {
        map[optionName] = this[optionName];
      }
    }

    return map;
  }
}
