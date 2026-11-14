import '../../core/constants/rules.dart';
import '../../core/extensions/logic_param_x.dart';
import '../../domain/enums/state_control.dart';
import '../../domain/models/prop_model.dart';
import '../../domain/params/logic_param.dart';
import '../../domain/params/slice_gate_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/logic_service.dart';
import 'wrapper/slice_gate_command.dart';

class GenLogicCommand extends SliceGateCommand {
  final LogicService _logicService;
  final FileService _fileService;

  GenLogicCommand({
    required LogicService logicService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _logicService = logicService,
       _fileService = fileService {
    argParser.addOption(
      'props',
      abbr: 'p',
      help: 'Comma-separated properties (e.g., "String:id,String:name").',
    );
    argParser.addOption(
      'control',
      abbr: 'c',
      help:
          'State control or can be called state management. Available: $_availableControlStates.',
      defaultsTo: StateControl.cubit.value,
    );
  }

  String get _availableControlStates => StateControl.values.join(', ');

  @override
  String get name => 'gen-logic';

  @override
  String get description =>
      'Generates a feature slice logic (Cubit) and Freezed state pair.';

  @override
  String get invocation =>
      'fsda gen-logic -s <slice> -p "<props>" -f <feature> -m <module>';

  @override
  Future<int> handleSliceGate(SliceGateParam sliceGateParam) async {
    final rest = argResults?.rest ?? [];
    if (rest.isNotEmpty) {
      logger.error('Invalid command.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final propsArg = argResults?['props'] as String?;
    if (propsArg == null || propsArg.isEmpty) {
      logger.error('props required.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final parsedProps = _parseProps(propsArg);
    if (parsedProps == null) return errorUsage;

    final controlArg = argResults?['control'] as String;
    final control = StateControl.tryParse(controlArg);
    if (control == null) {
      logger.error('Invalid control state: $controlArg');
      logger.log('Available control state: $_availableControlStates.');
      return errorUsage;
    }

    final progress = logger.progress('Inspecting use case metadata...');

    try {
      final logicParam = LogicParam.fromSliceGate(
        sliceGate: sliceGateParam,
        props: parsedProps,
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

      await _logicService.generate(
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

  List<PropModel>? _parseProps(String propsArg) {
    final propsList = <PropModel>[];
    final rawProps = propsArg.split(',');
    for (final raw in rawProps) {
      final parts = raw.split(':');
      final type = parts.isNotEmpty ? parts[0].trim() : '';
      final propName = parts.length > 1 ? parts[1].trim() : '';
      final defaultValue = parts.length > 2 ? parts[2].trim() : '';

      if (type.isEmpty) {
        logger.error('Invalid property type: type is empty.');
        logger.log('Usage: $invocation');
        return null;
      }

      if (propName.isEmpty) {
        logger.error('Invalid property name: name is empty.');
        logger.log('Usage: $invocation');
        return null;
      }

      if (!Rules.propNameRegExp.hasMatch(propName)) {
        logger.error('Invalid property name: "$propName".');
        logger.log(Rules.propNameDescription);
        logger.log('Usage: $invocation');
        return null;
      }

      propsList.add(
        PropModel(
          type: type,
          name: propName,
          defaultValue: defaultValue,
          converter: '',
        ),
      );
    }
    return propsList;
  }
}
