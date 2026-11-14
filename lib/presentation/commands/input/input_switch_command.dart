import '../../../domain/params/inputs/input_gate_param.dart';
import '../../../domain/params/inputs/input_switch_param.dart';
import '../../../infrastructure/services/input_service.dart';
import '../wrapper/input_gate_command.dart';

class InputSwitchCommand extends InputGateCommand {
  final InputService _inputService;

  InputSwitchCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
    required InputService inputService,
  }) : _inputService = inputService;

  @override
  String get name => 'input-switch';

  @override
  String get description =>
      'Generates a feature presentation text input widget.';

  @override
  String get invocation => 'fsda input-switch <field> -f <feature> -m <module>';

  @override
  bool get isGeneration => true;

  @override
  Future<int> handleInputGate(InputGateParam inputGateParam) async {
    final progress = logger.progress('Generating input text...');

    try {
      await _inputService.generateSwitch(
        input: InputSwitchParam.fromInputGate(inputGate: inputGateParam),
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Input switch successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Input Switch Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate input switch: $e');
      return errorSystem;
    }
  }
}
