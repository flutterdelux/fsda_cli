import '../../../domain/params/ui/ui_gate_param.dart';
import '../../../domain/params/ui/ui_lsv_param.dart';
import '../../../infrastructure/services/ui_service.dart';
import '../wrapper/ui_gate_command.dart';

class GenUILsvCommand extends UiGateCommand {
  final UiService _uiService;

  GenUILsvCommand({
    required UiService uiService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _uiService = uiService;

  @override
  String get name => 'gen-ui-lsv';

  @override
  String get description =>
      'Generates a feature slice ListView UI with item & feedback variants.';

  @override
  String get invocation =>
      'fsda gen-ui-lsv -s <slice> -f <feature> -m <module> --model <object>';

  @override
  Future<int> handleUiGate(UiGateParam uiGate) async {
    final uiParam = UiLsvParam.fromUiGate(uiGate);

    final progress = logger.progress('Generating ListView UI slice...');

    try {
      await _uiService.generateLsv(
        ui: uiParam,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('ListView UI slice successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'ListView Ui Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate ListView UI slice: $e');
      return errorSystem;
    }
  }
}
