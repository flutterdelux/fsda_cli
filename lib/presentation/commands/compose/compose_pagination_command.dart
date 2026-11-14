import '../../../core/extensions/compose_param_x.dart';
import '../../../core/extensions/compose_retrieval_param_x.dart';
import '../../../domain/params/app_integration/compose_pagination_param.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../../domain/params/app_integration/compose_retrieval_param.dart';
import '../../../infrastructure/services/compose_service.dart';
import '../wrapper/compose_gate_command.dart';

class ComposePaginationCommand extends ComposeGateCommand {
  final ComposeService _composeService;

  ComposePaginationCommand({
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
  String get name => 'compose-pag';

  @override
  String get description =>
      'Composes and scaffolds a pagination UI wrapper artifact (Page, Section, Sheet, Dialog) for a specific feature slice in a target app module.';

  @override
  String get invocation =>
      'fsda compose-pag -a <app> -m <module> -f <feature> --logic-flow <slice> --ui <slice> -t <target>';

  @override
  Future<int> handleCompose(ComposeParam compose) async {
    final uiSlice = argResults?['ui'] as String?;
    if (uiSlice == null || uiSlice.isEmpty) {
      logger.error('Missing required option: --ui.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final param = ComposePaginationParam.fromRetrieval(
      retrieval: ComposeRetrievalParam.fromCompose(
        compose: compose,
        uiSlice: uiSlice,
      ),
    );

    if (!await directoryService.exists(param.uiSlicePath)) {
      logger.error('UI slice not found: $uiSlice');
      return errorUsage;
    }

    final progress = logger.progress(
      'Composing pagination for "${compose.target}"...',
    );

    try {
      await _composeService.composePagination(
        param: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Pagination artifact "${compose.targetPascal}" successfully generated at ${compose.targetPath}!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Compose Pagination Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to compose pagination: $e');
      return errorSystem;
    }
  }
}
