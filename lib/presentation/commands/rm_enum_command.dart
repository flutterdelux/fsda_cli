import 'package:path/path.dart' as p;

import '../../core/constants/rules.dart';
import '../../domain/params/enum_param.dart';
import '../../domain/params/feature_gate_param.dart';
import '../../infrastructure/services/enum_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import 'wrapper/feature_gate_command.dart';

class RmEnumCommand extends FeatureGateCommand {
  final EnumService _enumService;
  final FileService _fileService;

  RmEnumCommand({
    required EnumService enumService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _enumService = enumService,
       _fileService = fileService;

  @override
  String get name => 'rm-enum';

  @override
  String get description =>
      'Removes an existing Enum, Converter, UI Extension, and uninjects ARB labels from a feature.';

  @override
  String get invocation => 'fsda rm-enum <name> -f <feature> -m <module>';

  @override
  Future<int> handleFeatureGate(FeatureGateParam featureGateParam) async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      logger.error('Enum name is required.\nUsage: $invocation');
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

    final enumPath = p.join(
      featureGateParam.featurePath,
      'domain',
      'enums',
      '$enumName.dart',
    );
    if (!await _fileService.exists(enumPath)) {
      logger.error('Enum "$enumName" not found at $enumPath');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final enumParam = EnumParam(
      name: enumName,
      path: enumPath,
      values: await _enumService.getValuesFromEnumFile(enumPath),
      featureName: featureGateParam.featureName,
      featurePath: featureGateParam.featurePath,
      moduleName: featureGateParam.moduleName,
      modulePath: featureGateParam.modulePath,
      isLower: false,
    );

    final progress = logger.progress(
      'Removing enum "$enumName" from feature "${enumParam.featureName}" (${enumParam.moduleName})...',
    );

    try {
      await _enumService.removeEnum(
        enumParam: enumParam,
        onProgress: (msg) => progress.update(msg),
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Enum Removal Summary',
      );

      progress.complete('Enum "$enumName" successfully removed!');
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to remove enum $enumName: $e');
      return errorSystem;
    }
  }
}
