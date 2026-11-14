import '../../../domain/params/inputs/input_gate_param.dart';
import '../../../domain/params/inputs/input_password_param.dart';
import '../../../infrastructure/services/input_service.dart';
import '../wrapper/input_gate_command.dart';

class InputPasswordCommand extends InputGateCommand {
  final InputService _inputService;

  InputPasswordCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
    required InputService inputService,
  }) : _inputService = inputService;

  @override
  String get name => 'input-password';

  @override
  String get description =>
      'Generates a feature presentation password input widget.';

  @override
  String get invocation =>
      'fsda input-password <field> -f <feature> -m <module>';

  @override
  bool get isGeneration => true;

  @override
  Future<int> handleInputGate(InputGateParam inputGateParam) async {
    final progress = logger.progress('Generating input password...');

    try {
      await _inputService.generatePassword(
        input: InputPasswordParam.fromInputGate(inputGate: inputGateParam),
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Input password successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Input Password Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate input password widget: $e');
      return errorSystem;
    }
  }
}
