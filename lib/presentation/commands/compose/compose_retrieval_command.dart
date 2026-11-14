import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/compose_retrieval_param_x.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../../domain/params/app_integration/compose_retrieval_param.dart';
import '../../../infrastructure/services/compose_service.dart';
import '../wrapper/compose_gate_command.dart';

class ComposeRetrievalCommand extends ComposeGateCommand {
  final ComposeService _composeService;

  ComposeRetrievalCommand({
    required ComposeService composeService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
  }) : _composeService = composeService {
    argParser.addOption(
      'ui',
      help: 'The ui slice name of the feature (e.g., detail, list, active).',
    );
  }

  @override
  String get name => 'compose-r';

  @override
  String get description =>
      'Composes and scaffolds a retrieval UI wrapper artifact (Page, Section, Sheet, Dialog) for a specific feature slice in a target app module.';

  @override
  String get invocation =>
      'fsda compose-r -a <app> -m <module> -f <feature> --logic-flow <slice> --ui <slice> -t <target>';

  @override
  Future<int> handleCompose(ComposeParam compose) async {
    final uiSlice = argResults?['ui'] as String?;
    if (uiSlice == null || uiSlice.isEmpty) {
      logger.error('Missing required option: --ui.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final param = ComposeRetrievalParam.fromCompose(
      compose: compose,
      uiSlice: uiSlice,
    );

    if (!await directoryService.exists(param.uiSlicePath)) {
      logger.error('UI slice not found: $uiSlice');
      return errorUsage;
    }

    final progress = logger.progress(
      'Composing retrieval for "${compose.target}"...',
    );

    try {
      await _composeService.composeRetrieval(
        param: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Retrieval artifact "${compose.targetPascal}" successfully generated at ${compose.targetPath}!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Compose Retrieval Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to compose retrieval: $e');
      return errorSystem;
    }
  }
}
