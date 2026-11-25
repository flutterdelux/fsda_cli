import '../../domain/params/feature_param.dart';
import '../../infrastructure/services/feature_service.dart';
import 'wrapper/feature_gate_command.dart';

class GenFeatureCommand extends FeatureGateCommand {
  final FeatureService _featureService;

  GenFeatureCommand({
    required FeatureService featureService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _featureService = featureService;

  @override
  String get name => 'feature';

  @override
  String get description =>
      'Generates a new FSDA Architecture feature structure inside a target module.';

  @override
  String get invocation => 'fsda gen $name -m <module> -f <feature>';

  @override
  bool get featureShouldExists => false;

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    final progress = logger.progress(
      'Generating feature "${feature.featureName}" in module "${feature.moduleName}"...',
    );

    try {
      await _featureService.generate(
        feature: feature,
        onProgress: (msg) => progress.update(msg),
      );

      progress.update('Generating report...');
      final reportBuffer = reportService.generateReport(
        operationLabel: 'Feature Generation Summary',
      );

      progress.complete(
        'Feature "${feature.featureName}" successfully generated in module "${feature.moduleName}"!',
      );

      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate feature "${feature.featureName}": $e');
      return errorSystem;
    }
  }
}
