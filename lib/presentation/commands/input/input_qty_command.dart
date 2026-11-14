import '../../../domain/params/inputs/input_gate_param.dart';
import '../../../domain/params/inputs/input_qty_param.dart';
import '../../../infrastructure/services/input_service.dart';
import '../wrapper/input_gate_command.dart';

class InputQtyCommand extends InputGateCommand {
  final InputService _inputService;

  InputQtyCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
    required InputService inputService,
  }) : _inputService = inputService;

  @override
  String get name => 'input-qty';

  @override
  String get description =>
      'Generates a feature presentation quantity input widget.';

  @override
  String get invocation => 'fsda input-qty <field> -f <feature> -m <module>';

  @override
  bool get isGeneration => true;

  @override
  Future<int> handleInputGate(InputGateParam inputGateParam) async {
    final progress = logger.progress('Generating input qty...');

    try {
      await _inputService.generateQty(
        input: InputQtyParam.fromInputGate(inputGate: inputGateParam),
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Input qty successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Input Qty Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate input qty: $e');
      return errorSystem;
    }
  }
}
