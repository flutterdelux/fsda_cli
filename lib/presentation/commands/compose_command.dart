import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/compose_param_x.dart';
import '../../domain/enums/compose_type.dart';
import '../../domain/params/app_integration/compose_param.dart';
import '../../domain/params/app_integration/reg_feature_param.dart';
import '../../infrastructure/services/compose_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../resolvers/compose_resolver.dart';
import 'wrapper/reg_feature_gate_command.dart';

class ComposeCommand extends RegFeatureGateCommand {
  final ComposeService _composeService;
  final FileService _fileService;

  ComposeCommand({
    required ComposeService composeService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _composeService = composeService,
       _fileService = fileService {
    argParser.addOption(
      ComposeResolverKeys.type,
      abbr: 't',
      help: 'Compose type. Available: ${ComposeType.available}.',
    );
    argParser.addOption(
      ComposeResolverKeys.target,
      help:
          'The target artifact name (e.g., product_detail_page, product_delete_dialog).',
    );
    argParser.addOption(
      ComposeResolverKeys.logicFlow,
      help:
          'The logic flow slice name of the feature (e.g., detail, list, active).',
    );
    argParser.addOption(
      ComposeResolverKeys.ui,
      help: 'The UI slice name of the feature (required for r, pag, form).',
    );
    argParser.addOption(
      ComposeResolverKeys.logic,
      help: 'The Logic slice name of the feature (required for form).',
    );
    argParser.addFlag(
      ComposeResolverKeys.route,
      help: 'Injects a GoRoute into <feature>Base in <module>_route.dart.',
      negatable: false,
    );
  }

  @override
  String get name => 'compose';

  @override
  String get description =>
      'Composes and scaffolds a UI wrapper artifact (Page, Section, Sheet, Dialog) in a target app.';

  @override
  String get invocation =>
      'fsda $name -a <app> -m <module> -f <feature> -t <type> -target <target> --logic-flow <slice> [--ui <slice>] [--logic <slice>] [--route]';

  @override
  Future<int> handleRegFeature(RegFeatureParam regFeature) async {
    final rest = argResults?.rest ?? [];
    if (rest.isNotEmpty) {
      logger.error('Invalid command.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final ComposeParam param;
    try {
      param = ComposeResolver.resolve(
        regFeature: regFeature,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (!await directoryService.exists(param.logicFlowSlicePath)) {
      logger.error('Logic flow slice not found at ${param.logicFlowSlicePath}');
      return errorUsage;
    }

    if (param.uiSlice != null &&
        !await directoryService.exists(param.uiSlicePath)) {
      logger.error('UI slice not found at ${param.uiSlicePath}');
      return errorUsage;
    }

    if (param.logicSlice != null &&
        !await directoryService.exists(param.logicSlicePath)) {
      logger.error('Logic slice not found at ${param.logicSlicePath}');
      return errorUsage;
    }

    if (await _fileService.exists(param.targetPath)) {
      logger.error('Target already exists at ${param.targetPath}');
      return errorUsage;
    }

    final progress = logger.progress(
      'Composing ${param.type.value} artifact for "${param.target}"...',
    );

    try {
      await _composeService.compose(
        param: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Artifact "${param.targetPascal}" successfully generated at ${param.targetPath}!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Compose Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to compose artifact: $e');
      return errorSystem;
    }
  }
}
