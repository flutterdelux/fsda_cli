import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/logic_flow_param_x.dart';
import '../../domain/enums/logic_flow_type.dart';
import '../../domain/enums/state_control.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/logic_flow_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/logic_service.dart';
import '../resolvers/logic_resolver.dart';
import 'wrapper/feature_gate_command.dart';

class GenLogicFlowCommand extends FeatureGateCommand {
  final LogicService _logicService;
  final FileService _fileService;

  GenLogicFlowCommand({
    required LogicService logicService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _logicService = logicService,
       _fileService = fileService {
    argParser.addOption(
      LogicResolverKeys.slice,
      abbr: 's',
      help: 'Feature slice name in snake_case (e.g., create, status_update).',
    );
    argParser.addOption(
      LogicResolverKeys.type,
      abbr: 't',
      help:
          'Logic flow type: ${LogicFlowType.values.map((e) => e.value).join(', ')}.',
    );
    argParser.addOption(
      LogicResolverKeys.uc,
      help:
          'Target use case name ending with _use_case (e.g., task_create_use_case).',
    );
    argParser.addOption(
      LogicResolverKeys.control,
      abbr: 'c',
      help:
          'State control or can be called state management. Available: ${StateControl.available}.',
    );
  }

  @override
  bool get featureShouldExists => true;

  @override
  String get name => 'gen-logic-flow';

  @override
  String get description =>
      'Generates a feature slice logic flow and Freezed state pair.';

  @override
  String get invocation =>
      'fsda $name -m <module> -f <feature> -s <slice> -t <type> --uc <usecase_use_case> [-c <control>]';

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    final LogicFlowParam param;
    try {
      param = LogicResolver.resolveFlow(
        feature: feature,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (await _fileService.exists(param.controllerPath)) {
      logger.error('Logic file already exists at ${param.controllerPath}');
      return errorUsage;
    }

    if (await _fileService.exists(param.statePath)) {
      logger.error('State file already exists at ${param.controllerPath}');
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating logic flow "${param.controllerPascal}"...',
    );
    try {
      await _logicService.generateFlow(
        logic: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Logic slice successfully generated!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Logic Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate logic slice: $e');
      return errorSystem;
    }
  }
}
