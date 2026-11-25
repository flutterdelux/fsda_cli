import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/slice_param_x.dart';
import '../../domain/enums/ui_type.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/ui_param.dart';
import '../../infrastructure/services/ui_service.dart';
import '../resolvers/ui_resolver.dart';
import 'wrapper/feature_gate_command.dart';

class GenUiCommand extends FeatureGateCommand {
  final UiService _uiService;

  GenUiCommand({
    required UiService uiService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _uiService = uiService {
    argParser.addOption(
      UiResolverKeys.slice,
      abbr: 's',
      help: 'Feature slice name in snake_case (e.g., create, list, detail).',
    );
    argParser.addOption(
      UiResolverKeys.type,
      abbr: 't',
      help: 'UI widget type. Available: ${UiType.available}.',
    );
    argParser.addOption(
      UiResolverKeys.model,
      help: 'Data type for content (e.g., product_entity, task_create_param).',
    );
    argParser.addMultiOption(
      UiResolverKeys.field,
      help:
          'Define a form field (for form type, e.g., --field "text:String:title").',
    );
    argParser.addFlag(
      UiResolverKeys.initial,
      negatable: false,
      help: 'Indicates if the form receives initial data (for form type).',
      defaultsTo: false,
    );
  }

  @override
  String get name => 'gen-ui';

  @override
  String get description =>
      'Generates a feature slice UI widget (${UiType.available}).';

  @override
  String get invocation =>
      'fsda $name -m <module> -f <feature> -s <slice> --model <model> [-t <type>] [--field "<input_type>:<value_type>:<name>[:default]"] [--initial]';

  @override
  bool get featureShouldExists => true;

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    final rest = argResults?.rest ?? [];
    if (rest.isNotEmpty) {
      logger.error('Invalid command.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final UiParam param;
    try {
      param = UiResolver.resolve(
        feature: feature,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (await directoryService.exists(param.uiSlicePath)) {
      logger.error('UI slice already exists at ${param.uiSlicePath}');
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating ${param.type.value} UI slice "${param.sliceName}"...',
    );

    try {
      await _uiService.generate(
        ui: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'UI slice "${param.sliceName}" successfully generated!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'UI Generation Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate UI slice: $e');
      return errorSystem;
    }
  }
}
