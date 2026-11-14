import '../../../core/constants/rules.dart';
import '../../../core/extensions/input_gate_param_x.dart';
import '../../../domain/params/feature_gate_param.dart';
import '../../../domain/params/inputs/input_gate_param.dart';
import '../../../infrastructure/services/helpers/file_service.dart';
import 'feature_gate_command.dart';

abstract class InputGateCommand extends FeatureGateCommand {
  final FileService fileService;

  InputGateCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required this.fileService,
  });

  @override
  Future<int> handleFeatureGate(FeatureGateParam featureGateParam) async {
    final rest = argResults?.rest ?? [];
    if (rest.isEmpty) {
      logger.error('Field name argument is required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (rest.length > 1) {
      logger.error('Too many arguments provided: $rest');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final field = rest.first;

    if (!Rules.fieldNameRegExp.hasMatch(field)) {
      logger.error('Invalid field name: "$field".');
      logger.log(Rules.fieldNameDescription);
      return errorUsage;
    }

    final input = InputGateParam.fromFeatureGate(
      featureGate: featureGateParam,
      field: field,
    );

    if (isGeneration) {
      if (await fileService.exists(input.widgetPath)) {
        logger.error('Input text already exists at ${input.widgetPath}');
        return errorUsage;
      }
    }

    return handleInputGate(input);
  }

  bool get isGeneration;

  Future<int> handleInputGate(InputGateParam inputGateParam);
}
