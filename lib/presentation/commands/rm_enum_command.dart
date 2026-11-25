import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/enum_param_x.dart';
import '../../domain/params/enum_param.dart';
import '../../domain/params/feature_param.dart';
import '../../infrastructure/services/enum_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../resolvers/enum_resolver.dart';
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
       _fileService = fileService {
    argParser.addOption(
      EnumResolverKeys.name,
      abbr: 'n',
      help: 'Name of the enum in PascalCase (e.g., UserRole).',
    );
  }

  @override
  String get name => 'rm-enum';

  @override
  String get description =>
      'Removes an existing Enum, Converter, UI Extension, and uninjects ARB labels from a feature.';

  @override
  String get invocation => 'fsda $name -n <name> -f <feature> -m <module>';

  @override
  bool get featureShouldExists => true;

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    final String enumName;
    try {
      enumName = EnumResolver.resolveName(argResults?.toMap() ?? {});
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final initParam = EnumParam.fromFeature(
      feature: feature,
      enumName: enumName,
      values: const [],
      isLower: false,
    );

    if (!await _fileService.exists(initParam.enumPath)) {
      logger.error('Enum "$enumName" not found at ${initParam.enumPath}');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final values = await _enumService.getValuesFromEnumFile(initParam.enumPath);

    final param = EnumParam.fromFeature(
      feature: feature,
      enumName: enumName,
      values: values,
      isLower: false,
    );

    final progress = logger.progress(
      'Removing enum "$enumName" from feature "${param.featureName}" (${param.moduleName})...',
    );

    try {
      await _enumService.remove(
        enumParam: param,
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
