import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/input_param_x.dart';
import '../../domain/enums/input_type.dart';
import '../../domain/params/feature_param.dart';
import '../../domain/params/input_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/input_service.dart';
import '../resolvers/input_resolver.dart';
import 'wrapper/feature_gate_command.dart';

class GenInputCommand extends FeatureGateCommand {
  final InputService _inputService;
  final FileService _fileService;

  GenInputCommand({
    required InputService inputService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _inputService = inputService,
       _fileService = fileService {
    argParser.addOption(
      InputResolverKeys.type,
      abbr: 't',
      help: 'Input widget type. Available: ${InputType.available}.',
    );
    argParser.addOption(
      InputResolverKeys.field,
      help: 'Field name in snake_case (e.g., --field user_name).',
    );
    argParser.addOption(
      InputResolverKeys.dataType,
      help:
          'Data/enum/model type for number, image, dropdown, dropdown_enum, or selector.',
    );
    argParser.addOption(
      InputResolverKeys.min,
      help: 'Minimum lines for text_area input.',
    );
    argParser.addOption(
      InputResolverKeys.max,
      help: 'Maximum lines for text_area input.',
    );
    argParser.addFlag(
      InputResolverKeys.isList,
      negatable: false,
      help: 'Generate a selector list widget (for selector type).',
      defaultsTo: false,
    );
  }

  @override
  String get name => 'gen-input';

  @override
  String get description =>
      'Generates a feature presentation input widget (${InputType.available}).';

  @override
  String get invocation =>
      'fsda $name -m <module> -f <feature> -t <type> --field <field> [--data-type <type>] [--min <int>] [--max <int>] [--list]';

  @override
  bool get featureShouldExists => true;

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    final InputParam param;
    try {
      param = InputResolver.resolve(
        feature: feature,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (await _fileService.exists(param.widgetPath)) {
      logger.error('Input widget already exists at ${param.widgetPath}');
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating input widget for field "${param.field}"...',
    );

    try {
      await _inputService.generate(
        input: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Input widget "${param.field}" successfully generated!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Input Generation Summary',
      );
      logger.log(reportBuffer.toString());

      if (param.type == InputType.dropdown) {
        logger.log(
          '\n⚠️ Reminder: Please modify the items or data source for this dropdown widget accordingly.',
        );
      }

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate input widget: $e');
      return errorSystem;
    }
  }
}
