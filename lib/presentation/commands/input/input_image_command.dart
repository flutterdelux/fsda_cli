import '../../../domain/params/inputs/input_gate_param.dart';
import '../../../domain/params/inputs/input_image_param.dart';
import '../../../infrastructure/services/input_service.dart';
import '../wrapper/input_gate_command.dart';

class InputImageCommand extends InputGateCommand {
  final InputService _inputService;

  InputImageCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
    required InputService inputService,
  }) : _inputService = inputService {
    argParser.addOption(
      'type',
      defaultsTo: 'NetworkFile',
      help: 'The value type for the image input.',
    );
  }

  @override
  String get name => 'input-image';

  @override
  String get description =>
      'Generates a feature presentation image input widget.';

  @override
  String get invocation =>
      'fsda input-image <field> -f <feature> -m <module> [--type <string>]';

  @override
  bool get isGeneration => true;

  @override
  Future<int> handleInputGate(InputGateParam inputGateParam) async {
    final valueType = argResults?['type'] as String? ?? 'NetworkFile';
    final progress = logger.progress('Generating input image...');

    try {
      await _inputService.generateImage(
        input: InputImageParam.fromInputGate(
          inputGate: inputGateParam,
          valueType: valueType,
        ),
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Input image successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Input Image Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate input image: $e');
      return errorSystem;
    }
  }
}
