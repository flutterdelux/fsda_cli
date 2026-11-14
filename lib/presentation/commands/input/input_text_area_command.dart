import '../../../domain/params/inputs/input_gate_param.dart';
import '../../../domain/params/inputs/input_text_area_param.dart';
import '../../../infrastructure/services/input_service.dart';
import '../wrapper/input_gate_command.dart';

class InputTextAreaCommand extends InputGateCommand {
  final InputService _inputService;

  InputTextAreaCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
    required InputService inputService,
  }) : _inputService = inputService {
    argParser.addOption(
      'min',
      defaultsTo: '3',
      help: 'Minimum lines for the text area.',
    );
    argParser.addOption(
      'max',
      defaultsTo: '3',
      help: 'Maximum lines for the text area.',
    );
  }

  @override
  String get name => 'input-text-area';

  @override
  String get description =>
      'Generates a feature presentation text area input widget.';

  @override
  String get invocation =>
      'fsda input-text-area <field> -f <feature> -m <module> [--min <int>] [--max <int>]';

  @override
  bool get isGeneration => true;

  @override
  Future<int> handleInputGate(InputGateParam inputGateParam) async {
    final minLines = int.tryParse(argResults?['min'] as String? ?? '3') ?? 3;
    final maxLines = int.tryParse(argResults?['max'] as String? ?? '3') ?? 3;

    final progress = logger.progress('Generating text area...');

    try {
      await _inputService.generateTextArea(
        input: InputTextAreaParam.fromInputGate(
          inputGate: inputGateParam,
          minLines: minLines,
          maxLines: maxLines,
        ),
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Input text area successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Input Text Area Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate input text area: $e');
      return errorSystem;
    }
  }
}
