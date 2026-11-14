import '../../../domain/params/inputs/input_dropdown_param.dart';
import '../../../domain/params/inputs/input_gate_param.dart';
import '../../../infrastructure/services/input_service.dart';
import '../wrapper/input_gate_command.dart';

class InputDropdownCommand extends InputGateCommand {
  final InputService _inputService;

  InputDropdownCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
    required InputService inputService,
  }) : _inputService = inputService {
    argParser.addOption(
      'type',
      help: 'The item type name for the dropdown (required).',
    );
  }

  @override
  String get name => 'input-dropdown';

  @override
  String get description =>
      'Generates a feature presentation dropdown input widget.';

  @override
  String get invocation =>
      'fsda input-dropdown <field> -f <feature> -m <module> --type <string>';

  @override
  bool get isGeneration => true;

  @override
  Future<int> handleInputGate(InputGateParam inputGateParam) async {
    final typeName = argResults?['type'] as String?;
    if (typeName == null || typeName.isEmpty) {
      logger.error('Option --type is required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final progress = logger.progress('Generating input dropdown...');

    try {
      await _inputService.generateDropdown(
        input: InputDropdownParam.fromInputGate(
          inputGate: inputGateParam,
          typeName: typeName,
        ),
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Input dropdown successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Input Dropdown Generation Summary',
      );
      logger.log(reportBuffer.toString());

      logger.log(
        '\n⚠️ Reminder: Please modify the items or data source for this dropdown widget accordingly.',
      );

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate input dropdown: $e');
      return errorSystem;
    }
  }
}
