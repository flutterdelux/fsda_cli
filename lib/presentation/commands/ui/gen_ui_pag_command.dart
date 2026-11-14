import '../../../domain/params/ui/ui_gate_param.dart';
import '../../../domain/params/ui/ui_pag_param.dart';
import '../../../infrastructure/services/ui_service.dart';
import '../wrapper/ui_gate_command.dart';

class GenUIPagCommand extends UiGateCommand {
  final UiService _uiService;

  GenUIPagCommand({
    required UiService uiService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _uiService = uiService;

  @override
  String get name => 'gen-ui-pag';

  @override
  String get description =>
      'Generates a feature slice Paginated ListView UI with infinite scroll & feedback variants.';

  @override
  String get invocation =>
      'fsda gen-ui-pag -s <slice> -f <feature> -m <module> --model <object>';

  @override
  Future<int> handleUiGate(UiGateParam uiGate) async {
    final uiParam = UiPagParam.fromUiGate(uiGate);

    final progress = logger.progress(
      'Generating Paginated ListView UI slice...',
    );

    try {
      await _uiService.generatePag(
        ui: uiParam,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Paginated ListView UI slice successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Paginated ListView Ui Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate Paginated ListView UI slice: $e');
      return errorSystem;
    }
  }
}
