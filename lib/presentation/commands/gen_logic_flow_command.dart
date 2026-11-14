import 'package:path/path.dart' as p;

import '../../core/extensions/logic_flow_param_x.dart';
import '../../domain/enums/logic_flow_type.dart';
import '../../domain/enums/state_control.dart';
import '../../domain/params/logic_flow_param.dart';
import '../../domain/params/slice_gate_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/helpers/logic_uc_service.dart';
import '../../infrastructure/services/logic_service.dart';
import 'wrapper/slice_gate_command.dart';

class GenLogicFlowCommand extends SliceGateCommand {
  final LogicService _logicService;
  final LogicUcService _logicUcService;
  final FileService _fileService;

  GenLogicFlowCommand({
    required LogicService logicService,
    required LogicUcService logicUcService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _logicService = logicService,
       _logicUcService = logicUcService,
       _fileService = fileService {
    argParser.addOption(
      'uc',
      help:
          'Target use case name ending with _use_case (e.g., task_create_use_case).',
    );
    argParser.addOption(
      'control',
      abbr: 'c',
      help:
          'State control or can be called state management. Available: $_availableControlStates.',
      defaultsTo: StateControl.cubit.value,
    );
    argParser.addOption(
      'props',
      help: 'Custom state properties (e.g., "String:name,int:age:18").',
    );
    argParser.addOption(
      'param',
      help: 'Custom param type override for logic method call.',
    );
  }

  String get _availableControlStates => StateControl.values.join(', ');

  @override
  String get name => 'gen-logic-flow';

  @override
  String get description =>
      'Generates a feature slice logic (Cubit) and Freezed state pair.';

  @override
  String get invocation =>
      'fsda gen-logic-flow <type> [-c <control>] -s <slice> --uc <usecase_use_case> -f <feature> -m <module>';

  @override
  Future<int> handleSliceGate(SliceGateParam sliceGateParam) async {
    final allowedLogicTypes = LogicFlowType.values
        .map((e) => e.value)
        .join(', ');

    final rest = argResults?.rest ?? [];
    if (rest.isEmpty) {
      logger.error('Logic type argument is required ($allowedLogicTypes).');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (rest.length > 1) {
      logger.error('Logic type invalid: $rest');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final typeStr = rest.first;
    final logicType = LogicFlowType.fromvalue(typeStr);
    if (logicType == null) {
      logger.error(
        'Invalid logic type: "$typeStr". Allowed: $allowedLogicTypes',
      );
      return errorUsage;
    }

    final ucName = argResults?['uc'] as String?;

    if (ucName == null || ucName.isEmpty) {
      logger.error('Missing required options: --uc.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (!ucName.endsWith('_use_case')) {
      logger.error(
        'Invalid use case name: "$ucName". Must end with "_use_case" (e.g., --uc task_create_use_case).',
      );
      return errorUsage;
    }

    final usecasePath = p.join(
      sliceGateParam.featurePath,
      'domain',
      'usecases',
      '$ucName.dart',
    );

    if (!await _fileService.exists(usecasePath)) {
      logger.error('Use case file not found at $usecasePath');
      return errorUsage;
    }

    final controlArg = argResults?['control'] as String;
    final control = StateControl.tryParse(controlArg);
    if (control == null) {
      logger.error('Invalid control state: $controlArg');
      logger.log('Available control state: $_availableControlStates.');
      return errorUsage;
    }

    final progress = logger.progress('Inspecting use case AST metadata...');

    try {
      // Analisis UseCase via AST Inspector
      final logicUc = await _logicUcService.inspectUseCase(
        usecaseName: ucName,
        usecasePath: usecasePath,
      );

      final logicParam = LogicFlowParam.fromSliceGate(
        sliceGate: sliceGateParam,
        type: logicType,
        uc: logicUc,
        control: control,
      );

      if (await _fileService.exists(logicParam.controllerPath)) {
        progress.fail(
          'Logic file already exists at ${logicParam.controllerPath}',
        );
        return errorUsage;
      }

      progress.update(
        'Generating logic slice for "${logicParam.controllerPascal}"...',
      );

      await _logicService.generateFlow(
        logic: logicParam,
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
