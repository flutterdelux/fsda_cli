import 'package:args/args.dart';
import 'package:args/command_runner.dart' show UsageException;
import 'package:mason/mason.dart';

import '../../constants/cli_rules.dart';

class SliceArtifactOptions {
  const SliceArtifactOptions._();

  static ({String param, String request, String paramName, String requestName})
  resolveParamRequest({required ArgResults results, required String usage}) {
    final shortcut = _read(results, 'param-request');
    final explicitParam = _read(results, 'param');
    final explicitRequest = _read(results, 'request');
    final usesShortcut =
        shortcut != null && (explicitParam == null || explicitRequest == null);
    final prefix = usesShortcut
        ? _validatePrefix(shortcut, 'Param/Request', usage)
        : null;

    final param = explicitParam ?? (prefix == null ? null : '${prefix}_param');
    final request =
        explicitRequest ?? (prefix == null ? null : '${prefix}_request');
    final missing = <String>[];
    if (param == null) missing.add('--param or --param-request');
    if (request == null) missing.add('--request or --param-request');
    if (missing.isNotEmpty) {
      throw UsageException(
        'Missing required option(s): ${missing.join(', ')}',
        usage,
      );
    }

    _validateArtifact(param!, label: 'Param', usage: usage);
    _validateArtifact(request!, label: 'Request', usage: usage);
    return (
      param: param,
      request: request,
      paramName: param,
      requestName: request,
    );
  }

  static ({String dto, String entity, String modelPrefix}) resolveEntityDto({
    required ArgResults results,
    required String usage,
  }) {
    final shortcut = _read(results, 'entity-dto');
    final explicitDto = _read(results, 'dto');
    final explicitEntity = _read(results, 'entity');
    final usesShortcut =
        shortcut != null && (explicitDto == null || explicitEntity == null);
    final prefix = usesShortcut
        ? _validatePrefix(shortcut, 'Entity/DTO', usage)
        : null;

    final dto = explicitDto ?? (prefix == null ? null : '${prefix}_dto');
    final entity =
        explicitEntity ?? (prefix == null ? null : '${prefix}_entity');
    final missing = <String>[];
    if (dto == null) missing.add('--dto or --entity-dto');
    if (entity == null) missing.add('--entity or --entity-dto');
    if (missing.isNotEmpty) {
      throw UsageException(
        'Missing required option(s): ${missing.join(', ')}',
        usage,
      );
    }

    _validateArtifact(dto!, label: 'DTO', usage: usage);
    _validateArtifact(entity!, label: 'Entity', usage: usage);
    final dtoPrefix = _stripConventionSuffix(dto, 'dto');
    final dtoModel = dtoPrefix.pascalCase;

    return (dto: dto, entity: entity, modelPrefix: dtoModel);
  }

  static String? _read(ArgResults results, String name) {
    final value = (results[name] as String?)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static String _validatePrefix(String prefix, String label, String usage) {
    if (!RegExp(CliRules.sliceNamePattern).hasMatch(prefix)) {
      throw UsageException(
        'Invalid $label prefix "$prefix". Use a lowercase snake_case prefix without artifact suffixes.',
        usage,
      );
    }
    return prefix;
  }

  static void _validateArtifact(
    String name, {
    required String label,
    required String usage,
  }) {
    final pattern = RegExp(CliRules.sliceArtifactNamePattern);
    if (!pattern.hasMatch(name)) {
      throw UsageException(
        'Invalid $label name "$name". Use a lowercase snake_case filename stem.\n${CliRules.sliceArtifactNameRule}',
        usage,
      );
    }
  }

  static String _stripConventionSuffix(String name, String suffix) {
    final suffixWithSeparator = '_$suffix';
    if (name.endsWith(suffixWithSeparator)) {
      return name.substring(0, name.length - suffixWithSeparator.length);
    }
    return name;
  }
}
