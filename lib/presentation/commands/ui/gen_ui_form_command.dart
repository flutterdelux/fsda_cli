import '../../../domain/enums/input_type.dart';
import '../../../domain/models/form_field_model.dart';
import '../../../domain/params/ui/ui_form_param.dart';
import '../../../domain/params/ui/ui_gate_param.dart';
import '../../../infrastructure/services/ui_service.dart';
import '../wrapper/ui_gate_command.dart';

class GenUIFormCommand extends UiGateCommand {
  final UiService _uiService;

  GenUIFormCommand({
    required UiService uiService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _uiService = uiService {
    argParser.addOption(
      'fields',
      help:
          'Comma-separated fields (e.g., "text:String:title,number:double:price:0.0").',
    );
    argParser.addFlag(
      'initial',
      negatable: false,
      help: 'Indicates if the form receives initial data.',
      defaultsTo: false,
    );
  }

  @override
  String get name => 'gen-ui-form';

  @override
  String get description =>
      'Generates a feature slice UI form widget with field inputs and validations.';

  @override
  String get invocation =>
      'fsda gen-ui-form -s <slice> -f <feature> -m <module> --model <object> --fields "input_type:valueType:field_name[:default],..." [--initial]';

  @override
  Future<int> handleUiGate(UiGateParam uiGate) async {
    final fieldsArg = argResults?['fields'] as String?;
    if (fieldsArg == null || fieldsArg.isEmpty) {
      logger.error('Missing required option (--fields).');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    // Parsing dipisahkan dengan koma (seperti --props)
    final fieldsList = <FormFieldModel>[];
    final rawFields = fieldsArg.split(',');

    for (final raw in rawFields) {
      final parts = raw.split(':');
      final inputTypeStr = parts.isNotEmpty ? parts[0].trim() : '';
      final valueType = parts.length > 1 ? parts[1].trim() : '';
      final fieldName = parts.length > 2 ? parts[2].trim() : '';
      final defaultValue = parts.length > 3 ? parts[3].trim() : '';

      if (inputTypeStr.isEmpty) {
        logger.error('Invalid field: input_type is empty in "$raw".');
        logger.log('Usage: $invocation');
        return errorUsage;
      }

      final inputType = InputType.tryParse(inputTypeStr);
      if (inputType == null) {
        logger.error('Invalid input_type "$inputTypeStr" in "$raw".');
        logger.log(
          'Supported input types: ${InputType.values.map((e) => e.name).join(', ')}.',
        );
        logger.log('Usage: $invocation');
        return errorUsage;
      }

      if (valueType.isEmpty) {
        logger.error('Invalid field: valueType is empty in "$raw".');
        logger.log('Usage: $invocation');
        return errorUsage;
      }

      if (fieldName.isEmpty) {
        logger.error('Invalid field: field_name is empty in "$raw".');
        logger.log('Usage: $invocation');
        return errorUsage;
      }

      fieldsList.add(
        FormFieldModel(
          inputType: inputType,
          valueType: valueType,
          fieldName: fieldName,
          defaultValue: defaultValue.isNotEmpty ? defaultValue : null,
        ),
      );
    }

    final hasInitial = argResults?['initial'] as bool? ?? false;

    final uiFormParam = UiFormParam.fromUiGate(
      ui: uiGate,
      fields: fieldsList,
      hasInitial: hasInitial,
    );

    final progress = logger.progress('Generating UI Form slice...');

    try {
      await _uiService.generateForm(
        ui: uiFormParam,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('UI Form slice successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'UI Form Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate UI Form slice: $e');
      return errorSystem;
    }
  }
}
