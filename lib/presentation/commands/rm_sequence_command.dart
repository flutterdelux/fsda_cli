import 'package:path/path.dart' as p;

import '../../core/constants/rules.dart';
import '../../domain/enums/action.dart';
import '../../domain/enums/ds_mode.dart';
import '../../domain/enums/flow_type.dart';
import '../../domain/params/feature_gate_param.dart';
import '../../domain/params/sequence_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/sequence_service.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import 'wrapper/feature_gate_command.dart';

class RmSequenceCommand extends FeatureGateCommand {
  final SequenceService _sequenceService;
  final FileService _fileService;

  RmSequenceCommand({
    required SequenceService sequenceService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
    required FileService fileService,
  }) : _sequenceService = sequenceService,
       _fileService = fileService {
    argParser.addOption(
      'uc',
      help: 'Use case name in snake_case (e.g., --uc task_create).',
    );
    argParser.addOption(
      'method',
      abbr: 'd',
      help: 'Repository/Datasource method name (e.g., -d create_task).',
    );
    argParser.addOption('ds', help: 'Datasource mode: remote or local.');
  }

  @override
  String get name => 'rm-sequence';

  @override
  String get description =>
      'Removes an existing data-to-domain sequence (UseCase, Repository method, and DataSource method).';

  @override
  String get invocation =>
      'fsda rm-sequence -f <feature> -m <module> --uc <usecase> -d <method> --ds <mode>';

  @override
  Future<int> handleFeatureGate(FeatureGateParam featureGateParam) async {
    final rest = argResults?.rest ?? [];
    if (rest.isNotEmpty) {
      logger.error('Invalid argument.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final usecase = argResults?['uc'] as String?;
    final method = argResults?['method'] as String?;
    final dsStr = argResults?['ds'] as String?;

    if (usecase == null ||
        usecase.isEmpty ||
        method == null ||
        method.isEmpty ||
        dsStr == null ||
        dsStr.isEmpty) {
      logger.error(
        'Missing required options: --uc, --method (-d), and --ds are mandatory.',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    // Validasi aturan regex usecase & method
    if (!Rules.usecaseRegExp.hasMatch(usecase)) {
      logger.error('Invalid use case name: "$usecase".');
      logger.log(Rules.usecaseDescription);
      return errorUsage;
    }

    if (!usecase.endsWith('_use_case')) {
      logger.error(
        'Invalid use case name: "$usecase". Must end with "_use_case" (e.g., --uc task_create_use_case).',
      );
      return errorUsage;
    }

    final usecasePath = p.join(
      featureGateParam.featurePath,
      'domain',
      'usecases',
      '$usecase.dart',
    );
    if (!await _fileService.exists(usecasePath)) {
      logger.error('Use case not found at $usecasePath');
      return errorUsage;
    }

    if (!Rules.methodRegExp.hasMatch(method)) {
      logger.error('Invalid method name: "$method".');
      logger.log(Rules.methodDescription);
      return errorUsage;
    }

    final dsMode = DsMode.fromValue(dsStr);
    if (dsMode == null) {
      logger.error(
        'Invalid ds mode: "$dsStr". Allowed: ${[DsMode.local.value, DsMode.remote.value].join(', ')}.',
      );
      return errorUsage;
    }

    final dsInterfacePath = p.join(
      featureGateParam.featurePath,
      'data',
      'datasources',
      '${featureGateParam.featureName}_${dsMode.value}_data_source.dart',
    );
    if (!await _fileService.exists(dsInterfacePath)) {
      logger.error(
        '${dsMode.value.titleCase} data source interface not found.',
      );
      return errorUsage;
    }

    final dsImplPath = p.join(
      featureGateParam.featurePath,
      'data',
      'datasources',
      '${featureGateParam.featureName}_${dsMode.value}_data_source_impl.dart',
    );
    if (!await _fileService.exists(dsImplPath)) {
      logger.error(
        '${dsMode.value.titleCase} data source implementation not found.',
      );
      return errorUsage;
    }

    final sequenceParam = SequenceParam(
      action: Action.post,
      usecase: usecase,
      usecasePath: usecasePath,
      method: method,
      featureName: featureGateParam.featureName,
      featurePath: featureGateParam.featurePath,
      moduleName: featureGateParam.moduleName,
      modulePath: featureGateParam.modulePath,
      flow: FlowType.asynchronous,
      dsMode: dsMode,
    );

    final progress = logger.progress(
      'Removing sequence "$usecase" for feature "${featureGateParam.featureName}"...',
    );

    try {
      await _sequenceService.remove(
        sequence: sequenceParam,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Sequence "$usecase" successfully removed and un-wired!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Sequence Removal Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to remove sequence: $e');
      return errorSystem;
    }
  }
}
