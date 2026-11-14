import '../../../core/constants/rules.dart';
import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/params/app_integration/app_integration_param.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../../infrastructure/services/helpers/file_service.dart';
import '../wrapper/app_integration_command.dart';

abstract class ComposeGateCommand extends AppIntegrationCommand {
  final FileService _fileService;

  ComposeGateCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required FileService fileService,
  }) : _fileService = fileService {
    argParser.addOption(
      'target',
      abbr: 't',
      help:
          'The target artifact name (e.g. product_detail_page, product_delete_dialog).',
    );
    argParser.addOption(
      'logic-flow',
      help:
          'The logic flow slice name of the feature (e.g., detail, list, active).',
    );
  }

  @override
  Future<int> handleAppIntegration(AppIntegrationParam appIntegration) async {
    final target = argResults?['target'] as String?;
    if (target == null || target.isEmpty) {
      logger.error('Missing required option: -t, --target.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (!Rules.composeTargetRegExp.hasMatch(target)) {
      logger.error('Invalid target name: "$target".');
      logger.log(Rules.composeTargetDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final logicFlowSlice = argResults?['logic-flow'] as String?;
    if (logicFlowSlice == null || logicFlowSlice.isEmpty) {
      logger.error('Missing required option: --logic-flow.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final featureName = appIntegration.featureName;
    if (featureName == null || featureName.isEmpty) {
      logger.error('Missing required option: -f, --feature.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final compose = ComposeParam.fromAppIntegration(
      param: appIntegration,
      logicFlowSlice: logicFlowSlice,
      target: target,
    );

    if (!await directoryService.exists(compose.logicFlowSlicePath)) {
      logger.error(
        'Logic flow slice not found at ${compose.logicFlowSlicePath}',
      );
      return errorUsage;
    }

    if (await _fileService.exists(compose.targetPath)) {
      logger.error('Target already exists at ${compose.targetPath}');
      return errorUsage;
    }

    return handleCompose(compose);
  }

  Future<int> handleCompose(ComposeParam compose);
}
