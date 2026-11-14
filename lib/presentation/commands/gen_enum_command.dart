import 'package:path/path.dart' as p;

import '../../core/constants/rules.dart';
import '../../domain/params/enum_param.dart';
import '../../domain/params/feature_gate_param.dart';
import '../../infrastructure/services/enum_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import 'wrapper/feature_gate_command.dart';

class GenEnumCommand extends FeatureGateCommand {
  final EnumService _enumService;
  final FileService _fileService;

  GenEnumCommand({
    required EnumService enumService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _enumService = enumService,
       _fileService = fileService {
    argParser.addOption(
      'values',
      abbr: 'v',
      help:
          'Comma-separated enum values (e.g., --values cashier,admin_backoffice,owner).',
    );
    argParser.addFlag(
      'lower',
      negatable: false,
      help:
          "Set value converter as lower constanta (snake case) such as 'in_progress'. If not using upper constanta such as 'IN_PROGRESS'.",
      defaultsTo: false,
    );
  }

  @override
  String get name => 'gen-enum';

  @override
  String get description =>
      'Generates an Enum, Converter, UI Extension, and injects ARB labels into a feature.';

  @override
  String get invocation =>
      'fsda gen-enum <name> --values <value_1>,<value_2>,... -f <feature> -m <module>';

  @override
  Future<int> handleFeatureGate(FeatureGateParam featureGateParam) async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      logger.error('Enum name is required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (rest.length > 1) {
      logger.error('Invalid enum name: "$rest".');
      logger.log(Rules.enumDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final enumName = rest.first;
    if (!Rules.enumRegExp.hasMatch(enumName)) {
      logger.error('Invalid enum name: "$enumName".');
      logger.log(Rules.enumDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final values = argResults?['values'] as String?;

    if (values == null || values.isEmpty) {
      logger.error('Missing required arguments.\nUsage: $invocation');
      return errorUsage;
    }

    final cleanValues = values
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (cleanValues.isEmpty) {
      logger.error('At least one enum value is required.');
      return errorUsage;
    }

    final isLower = argResults?['lower'] as bool;

    final enumPath = p.join(
      featureGateParam.featurePath,
      'domain',
      'enums',
      '$enumName.dart',
    );
    if (await _fileService.exists(enumPath)) {
      logger.error('Enum "$enumName" already exists at $enumPath');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating enum "$enumName" in feature "${featureGateParam.featureName}" (${featureGateParam.moduleName})...',
    );

    final enumParam = EnumParam(
      name: enumName,
      path: enumPath,
      values: cleanValues,
      isLower: isLower,
      featureName: featureGateParam.featureName,
      featurePath: featureGateParam.featurePath,
      moduleName: featureGateParam.moduleName,
      modulePath: featureGateParam.modulePath,
    );

    try {
      await _enumService.generateEnum(
        enumParam: enumParam,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Enum "$enumName" successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Enum Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate enum $enumName: $e');
      return errorSystem;
    }
  }
}
