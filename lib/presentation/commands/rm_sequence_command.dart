import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/sequence_param_x.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/sequence_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/sequence_service.dart';
import '../../infrastructure/text_modifiers/string_extension.dart';
import '../resolvers/sequence_resolver.dart';
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
      SequenceResolverKeys.uc,
      help: 'Use case name in snake_case (e.g., --uc task_create_use_case).',
    );
    argParser.addOption(
      SequenceResolverKeys.method,
      abbr: 'd',
      help: 'Repository/Datasource method name (e.g., -d create_task).',
    );
    argParser.addOption(
      SequenceResolverKeys.ds,
      help: 'Datasource mode: remote or local.',
    );
  }

  @override
  String get name => 'rm-sequence';

  @override
  String get description =>
      'Removes an existing data-to-domain sequence (UseCase, Repository method, and DataSource method).';

  @override
  String get invocation =>
      'fsda $name -f <feature> -m <module> --uc <usecase> -d <method> --ds <mode>';

  @override
  bool get featureShouldExists => true;

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    final rest = argResults?.rest ?? [];
    if (rest.isNotEmpty) {
      logger.error('Invalid argument.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final SequenceParam param;
    try {
      param = SequenceResolver.resolveRemoval(
        feature: feature,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (!await _fileService.exists(param.ucPath)) {
      logger.error('Use case not found at ${param.ucPath}');
      return errorUsage;
    }

    if (!await _fileService.exists(param.dsInterfacePath)) {
      logger.error(
        '${param.dsMode.value.titleCase} data source interface not found.',
      );
      return errorUsage;
    }

    if (!await _fileService.exists(param.dsImplPath)) {
      logger.error(
        '${param.dsMode.value.titleCase} data source implementation not found.',
      );
      return errorUsage;
    }

    final progress = logger.progress(
      'Removing sequence "${param.usecase}" for feature "${feature.featureName}"...',
    );

    try {
      await _sequenceService.remove(
        sequence: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Sequence "${param.usecase}" successfully removed and un-wired!',
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
