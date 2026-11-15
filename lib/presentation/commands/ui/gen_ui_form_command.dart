import '../../../core/constants/rules.dart';
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
    argParser.addMultiOption(
      'field',
      help:
          'Define a form field (e.g., --field "text:String:title" --field "number:double:price:0.0").',
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
      'fsda gen-ui-form -s <slice> -f <feature> -m <module> --type <object> --field "input_type:valueType:field_name[:default]" [--initial]';

  @override
  Future<int> handleUiGate(UiGateParam uiGate) async {
    final fieldArgs = argResults?['field'] as List<String>?;
    if (fieldArgs == null || fieldArgs.isEmpty) {
      logger.error(
        'Missing required option (--field). At least one field is required.',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final fieldsList = _parseFields(fieldArgs);
    if (fieldsList == null) return errorUsage;

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

  List<FormFieldModel>? _parseFields(List<String> rawFields) {
    final fieldsList = <FormFieldModel>[];

    for (final raw in rawFields) {
      final parts = raw.split(':');
      final inputTypeStr = parts.isNotEmpty ? parts[0].trim() : '';
      final valueType = parts.length > 1 ? parts[1].trim() : '';
      final fieldName = parts.length > 2 ? parts[2].trim() : '';
      final defaultValue = parts.length > 3 ? parts[3].trim() : '';

      if (inputTypeStr.isEmpty) {
        logger.error('Invalid field: input_type is empty in "$raw".');
        logger.log('Usage: $invocation');
        return null;
      }

      final inputType = InputType.tryParse(inputTypeStr);
      if (inputType == null) {
        logger.error('Invalid input_type "$inputTypeStr" in "$raw".');
        logger.log(
          'Supported input types: ${InputType.values.map((e) => e.name).join(', ')}.',
        );
        logger.log('Usage: $invocation');
        return null;
      }

      if (valueType.isEmpty) {
        logger.error('Invalid field: valueType is empty in "$raw".');
        logger.log('Usage: $invocation');
        return null;
      }

      if (fieldName.isEmpty) {
        logger.error('Invalid field: field_name is empty in "$raw".');
        logger.log('Usage: $invocation');
        return null;
      }

      if (!Rules.fieldNameRegExp.hasMatch(fieldName)) {
        logger.error('Invalid field name: "$fieldName" in "$raw".');
        logger.log(Rules.fieldNameDescription);
        logger.log('Usage: $invocation');
        return null;
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

    return fieldsList;
  }
}
