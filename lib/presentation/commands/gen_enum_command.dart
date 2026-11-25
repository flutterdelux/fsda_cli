import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/enum_param_x.dart';
import '../../domain/params/enum_param.dart';
import '../../domain/params/feature_param.dart';
import '../../infrastructure/services/enum_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../resolvers/enum_resolver.dart';
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
      EnumResolverKeys.name,
      abbr: 'n',
      help: 'Name of the enum in PascalCase (e.g., UserRole).',
    );
    argParser.addOption(
      EnumResolverKeys.values,
      abbr: 'v',
      help:
          'Comma-separated enum values (e.g., --values "cashier,admin_backoffice,owner").',
    );
    argParser.addFlag(
      EnumResolverKeys.isLower,
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
      'fsda $name -n <name> -v "<value_1>,<value_2>,..." -f <feature> -m <module>';

  @override
  bool get featureShouldExists => true;

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    EnumParam param;

    try {
      param = EnumResolver.resolve(
        feature: feature,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (await _fileService.exists(param.enumPath)) {
      logger.error(
        'Enum "${param.enumName}" already exists at ${param.enumPath}',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating enum "${param.enumName}" in "${feature.moduleName}/${feature.featureName}"...',
    );

    try {
      await _enumService.generate(
        enumParam: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Enum "${param.enumName}" successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Enum Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate enum ${param.enumName}: $e');
      return errorSystem;
    }
  }
}
