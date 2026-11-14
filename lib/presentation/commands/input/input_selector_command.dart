import '../../../domain/params/inputs/input_gate_param.dart';
import '../../../domain/params/inputs/input_selector_param.dart';
import '../../../infrastructure/services/input_service.dart';
import '../wrapper/input_gate_command.dart';

class InputSelectorCommand extends InputGateCommand {
  final InputService _inputService;

  InputSelectorCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
    required InputService inputService,
  }) : _inputService = inputService {
    argParser.addOption(
      'type',
      help: 'The value type name for the selector (required).',
    );
    argParser.addFlag(
      'list',
      defaultsTo: false,
      help: 'Generate a selector list widget.',
    );
  }

  @override
  String get name => 'input-selector';

  @override
  String get description =>
      'Generates a feature presentation selector or selector list input widget.';

  @override
  String get invocation =>
      'fsda input-selector <field> -f <feature> -m <module> --type <string> [--list]';

  @override
  bool get isGeneration => true;

  @override
  Future<int> handleInputGate(InputGateParam inputGateParam) async {
    final valueType = argResults?['type'] as String?;
    if (valueType == null || valueType.isEmpty) {
      logger.error('Option --type is required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final isList = argResults?['list'] as bool? ?? false;
    final progress = logger.progress(
      isList
          ? 'Generating input selector list...'
          : 'Generating input selector...',
    );

    try {
      await _inputService.generateSelector(
        input: InputSelectorParam.fromInputGate(
          inputGate: inputGateParam,
          valueType: valueType,
          isList: isList,
        ),
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        isList
            ? 'Input selector list successfully generated!'
            : 'Input selector successfully generated!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: isList
            ? 'Input Selector List Generation Summary'
            : 'Input Selector Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate input selector: $e');
      return errorSystem;
    }
  }
}
