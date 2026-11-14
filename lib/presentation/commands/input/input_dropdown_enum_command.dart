import '../../../domain/params/inputs/input_dropdown_enum_param.dart';
import '../../../domain/params/inputs/input_gate_param.dart';
import '../../../infrastructure/services/input_service.dart';
import '../wrapper/input_gate_command.dart';

class InputDropdownEnumCommand extends InputGateCommand {
  final InputService _inputService;

  InputDropdownEnumCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required super.fileService,
    required InputService inputService,
  }) : _inputService = inputService {
    argParser.addOption(
      'type',
      help: 'The enum type name for the dropdown (required).',
    );
  }

  @override
  String get name => 'input-dropdown-enum';

  @override
  String get description =>
      'Generates a feature presentation enum dropdown input widget.';

  @override
  String get invocation =>
      'fsda input-dropdown-enum <field> -f <feature> -m <module> --type <string>';

  @override
  bool get isGeneration => true;

  @override
  Future<int> handleInputGate(InputGateParam inputGateParam) async {
    final enumType = argResults?['type'] as String?;
    if (enumType == null || enumType.isEmpty) {
      logger.error('Option --type is required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final progress = logger.progress('Generating input dropdown enum...');

    try {
      await _inputService.generateDropdownEnum(
        input: InputDropdownEnumParam.fromInputGate(
          inputGate: inputGateParam,
          enumType: enumType,
        ),
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Input dropdown enum successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Input Dropdown Enum Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate input dropdown enum: $e');
      return errorSystem;
    }
  }
}
