import '../../../domain/params/inputs/input_gate_param.dart';
import '../../../domain/params/inputs/input_number_param.dart';
import '../../../infrastructure/services/input_service.dart';
import '../wrapper/input_gate_command.dart';

class InputNumberCommand extends InputGateCommand {
  final InputService _inputService;

  InputNumberCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
    required InputService inputService,
  }) : _inputService = inputService {
    argParser.addOption(
      'type',
      defaultsTo: 'int',
      help: 'The data type for the number input (e.g., int, double, BigInt).',
    );
  }

  @override
  String get name => 'input-number';

  @override
  String get description =>
      'Generates a feature presentation number input widget.';

  @override
  String get invocation =>
      'fsda input-number <field> -f <feature> -m <module> [--type <int>]';

  @override
  bool get isGeneration => true;

  @override
  Future<int> handleInputGate(InputGateParam inputGateParam) async {
    final type = argResults?['type'] as String? ?? 'int';
    final supportedTypes = ['int', 'double'];
    if (!supportedTypes.contains(type)) {
      logger.error('Type is not supported.');
      logger.log('Supported types: ${supportedTypes.join(', ')}.');
      return errorUsage;
    }

    final progress = logger.progress('Generating input number...');

    try {
      await _inputService.generateNumber(
        input: InputNumberParam.fromInputGate(
          inputGate: inputGateParam,
          type: type,
        ),
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Input number successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Input Number Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate input number: $e');
      return errorSystem;
    }
  }
}
