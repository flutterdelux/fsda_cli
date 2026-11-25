import '../../core/constants/rules.dart';
import '../../domain/params/failure_param.dart';
import '../../domain/params/module_param.dart';

abstract final class FailureResolverKeys {
  /// `failure`
  static const failure = 'failure';

  /// `name`
  static const name = 'name';

  /// `message`
  static const message = 'message';
}

abstract final class FailureResolver {
  /// Resolve single failure item (`Map<String, dynamic>`) -> `FailureParam`
  static FailureParam resolve({
    required Map<String, dynamic> data,
    required ModuleParam module,
  }) {
    // ============ name ============
    final rawName = data[FailureResolverKeys.name];
    if (rawName == null) {
      throw const FormatException('Failure name is required.');
    }
    if (rawName is! String) {
      throw const FormatException('Failure name must be String type.');
    }

    final failureName = rawName.trim();
    if (failureName.isEmpty) {
      throw const FormatException('Failure name cannot be empty.');
    }

    if (!Rules.failureNameRegExp.hasMatch(failureName)) {
      throw FormatException(
        'Invalid failure name format: "$failureName".\n'
        '${Rules.failureNameDescription}',
      );
    }

    // ============ message ============
    final rawMessage = data[FailureResolverKeys.message];
    if (rawMessage == null) {
      throw const FormatException('Failure message is required.');
    }
    if (rawMessage is! String) {
      throw const FormatException('Failure message must be String type.');
    }

    final failureMessage = rawMessage.trim();
    if (failureMessage.isEmpty) {
      throw const FormatException('Failure message cannot be empty.');
    }

    return FailureParam.fromModule(
      module: module,
      name: failureName,
      message: failureMessage,
    );
  }

  /// Resolve batch list (`List<dynamic>`) from CLI (`--failure`) or YAML (`failure:`)
  static List<FailureParam> resolveAll({
    required Map<String, dynamic> data,
    required ModuleParam module,
  }) {
    final rawList = data[FailureResolverKeys.failure];
    if (rawList == null) {
      throw const FormatException(
        'At least one failure definition is required.',
      );
    }
    if (rawList is! List || rawList.isEmpty) {
      throw const FormatException(
        'Failure definitions must be a non-empty List.',
      );
    }

    final results = <FailureParam>[];
    for (final item in rawList) {
      final mapData = item is String
          ? fromDelimiter(item)
          : item is Map<String, dynamic>
          ? item
          : throw const FormatException(
              'Each failure must be a String ("<name>:<message>") or a Map.',
            );

      results.add(resolve(data: mapData, module: module));
    }

    return results;
  }

  static Map<String, dynamic> fromDelimiter(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Failure string cannot be empty.');
    }

    final colonIndex = trimmed.indexOf(':');
    if (colonIndex == -1 ||
        colonIndex == 0 ||
        colonIndex == trimmed.length - 1) {
      throw FormatException(
        'Invalid format: "$trimmed". Expected format "<name>:<message>".',
      );
    }

    return {
      FailureResolverKeys.name: trimmed.substring(0, colonIndex).trim(),
      FailureResolverKeys.message: trimmed.substring(colonIndex + 1).trim(),
    };
  }
}
