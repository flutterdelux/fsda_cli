import '../../../core/constants/rules.dart';
import '../../../domain/params/feature_gate_param.dart';
import '../../../domain/params/slice_gate_param.dart';
import 'feature_gate_command.dart';

abstract class SliceGateCommand extends FeatureGateCommand {
  SliceGateCommand({
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) {
    argParser.addOption(
      'slice',
      abbr: 's',
      help: 'Feature slice name in snake_case (e.g., create, status_update).',
    );
  }

  @override
  Future<int> handleFeatureGate(FeatureGateParam featureGateParam) async {
    final slice = argResults?['slice'] as String?;

    if (slice == null) {
      logger.error('Missing required options: --slice (-s).');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (!Rules.sliceRegExp.hasMatch(slice)) {
      logger.error('Invalid slice name: "$slice".');
      logger.log(Rules.sliceDescription);
      return errorUsage;
    }

    final input = SliceGateParam.fromFeatureGate(
      featureGate: featureGateParam,
      slice: slice,
    );

    return handleSliceGate(input);
  }

  Future<int> handleSliceGate(SliceGateParam sliceGateParam);
}
