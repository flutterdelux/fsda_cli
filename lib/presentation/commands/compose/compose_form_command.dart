import '../../../core/extensions/compose_form_param_x.dart';
import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/params/app_integration/compose_form_param.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../../infrastructure/services/compose_service.dart';
import '../wrapper/compose_gate_command.dart';

class ComposeFormCommand extends ComposeGateCommand {
  final ComposeService _composeService;

  ComposeFormCommand({
    required ComposeService composeService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
  }) : _composeService = composeService {
    argParser.addOption(
      'logic',
      help: 'The Logic slice name of the feature (e.g., detail, list, active).',
    );
    argParser.addOption(
      'ui',
      help: 'The ui slice name of the feature (e.g., detail, list, active).',
    );
  }

  @override
  String get name => 'compose-form';

  @override
  String get description =>
      'Composes and scaffolds a form UI wrapper artifact (Page, Section, Sheet, Dialog) for a specific feature slice in a target app module.';

  @override
  String get invocation =>
      'fsda compose-r -a <app> -m <module> -f <feature> --logic-flow <slice> --logic <slice> --ui <slice> -t <target>';

  @override
  Future<int> handleCompose(ComposeParam compose) async {
    final logicSlice = argResults?['logic'] as String?;
    if (logicSlice == null || logicSlice.isEmpty) {
      logger.error('Missing required option: --logic.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final uiSlice = argResults?['ui'] as String?;
    if (uiSlice == null || uiSlice.isEmpty) {
      logger.error('Missing required option: --ui.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final param = ComposeFormParam.fromCompose(
      compose: compose,
      logicSlice: logicSlice,
      uiSlice: uiSlice,
    );

    if (!await directoryService.exists(param.logicSlicePath)) {
      logger.error('Logic slice not found: $logicSlice');
      return errorUsage;
    }

    if (!await directoryService.exists(param.uiSlicePath)) {
      logger.error('UI slice not found: $uiSlice');
      return errorUsage;
    }

    final progress = logger.progress(
      'Composing form for "${compose.target}"...',
    );

    try {
      await _composeService.composeForm(
        param: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Form artifact "${compose.targetPascal}" successfully generated at ${compose.targetPath}!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Compose Form Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to compose form: $e');
      return errorSystem;
    }
  }
}
