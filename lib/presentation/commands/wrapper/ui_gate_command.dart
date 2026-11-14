import '../../../core/constants/rules.dart';
import '../../../domain/params/slice_gate_param.dart';
import '../../../domain/params/ui/ui_gate_param.dart';
import 'slice_gate_command.dart';

abstract class UiGateCommand extends SliceGateCommand {
  UiGateCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) {
    argParser.addOption(
      'model',
      help: 'Data type for content (e.g. product_entity, task_create_param).',
    );
  }

  @override
  Future<int> handleSliceGate(SliceGateParam sliceGate) async {
    final model = argResults?['model'] as String?;

    if (model == null || model.isEmpty) {
      logger.error('Option --model is required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (!Rules.modelTypeRegExp.hasMatch(model) ||
        !(model.endsWith('_entity') || model.endsWith('_param'))) {
      logger.error('Invalid object model: "$model".');
      logger.log(Rules.modelTypeDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final input = UiGateParam.fromSliceGate(sliceGate: sliceGate, model: model);

    return handleUiGate(input);
  }

  Future<int> handleUiGate(UiGateParam sliceGateParam);
}
