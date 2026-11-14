import '../../../domain/params/ui/ui_gate_param.dart';
import '../../../domain/params/ui/ui_param.dart';
import '../../../infrastructure/services/ui_service.dart';
import '../wrapper/ui_gate_command.dart';

class GenUICommand extends UiGateCommand {
  final UiService _uiService;

  GenUICommand({
    required UiService uiService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _uiService = uiService;

  @override
  String get name => 'gen-ui';

  @override
  String get description => 'Generates a feature slice ui.';

  @override
  String get invocation =>
      'fsda gen-ui -s <slice> -f <feature> -m <module> --model <object>';

  @override
  Future<int> handleUiGate(UiGateParam uiGate) async {
    final uiParam = UiParam.fromUiGate(uiGate);

    final progress = logger.progress('Generating UI slice...');

    try {
      await _uiService.generate(
        ui: uiParam,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('UI slice successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Ui Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate ui slice: $e');
      return errorSystem;
    }
  }
}
