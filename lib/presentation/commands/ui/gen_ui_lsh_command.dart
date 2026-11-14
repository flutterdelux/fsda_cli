import '../../../domain/params/ui/ui_gate_param.dart';
import '../../../domain/params/ui/ui_lsh_param.dart';
import '../../../infrastructure/services/ui_service.dart';
import '../wrapper/ui_gate_command.dart';

class GenUILshCommand extends UiGateCommand {
  final UiService _uiService;

  GenUILshCommand({
    required UiService uiService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _uiService = uiService;

  @override
  String get name => 'gen-ui-lsh';

  @override
  String get description =>
      'Generates a feature slice Horizontal ListView UI with item & feedback variants.';

  @override
  String get invocation =>
      'fsda gen-ui-lsh -s <slice> -f <feature> -m <module> --model <object>';

  @override
  Future<int> handleUiGate(UiGateParam uiGate) async {
    final uiParam = UiLshParam.fromUiGate(uiGate);

    final progress = logger.progress(
      'Generating Horizontal ListView UI slice...',
    );

    try {
      await _uiService.generateLsh(
        ui: uiParam,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Horizontal ListView UI slice successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Horizontal ListView Ui Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate Horizontal ListView UI slice: $e');
      return errorSystem;
    }
  }
}
