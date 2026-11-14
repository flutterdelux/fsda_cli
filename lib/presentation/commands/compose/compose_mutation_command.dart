import '../../../core/extensions/compose_param_x.dart';
import '../../../domain/params/app_integration/compose_mutation_param.dart';
import '../../../domain/params/app_integration/compose_param.dart';
import '../../../infrastructure/services/compose_service.dart';
import '../wrapper/compose_gate_command.dart';

class ComposeMutationCommand extends ComposeGateCommand {
  final ComposeService _composeService;

  ComposeMutationCommand({
    required ComposeService composeService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
  }) : _composeService = composeService;

  @override
  String get name => 'compose-m';

  @override
  String get description =>
      'Composes and scaffolds a retrieval UI wrapper artifact (Page, Section, Sheet, Dialog) for a specific feature slice in a target app module.';

  @override
  String get invocation =>
      'fsda $name -a <app> -m <module> -f <feature> --logic-flow <slice> -t <target>';

  @override
  Future<int> handleCompose(ComposeParam compose) async {
    final param = ComposeMutationParam.fromCompose(compose: compose);

    final progress = logger.progress(
      'Composing retrieval for "${compose.target}"...',
    );

    try {
      await _composeService.composeMutation(
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
