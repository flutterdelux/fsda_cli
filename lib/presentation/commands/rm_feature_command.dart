import '../../../domain/params/feature_param.dart';
import '../../../infrastructure/services/feature_service.dart';
import 'wrapper/feature_gate_command.dart';

class RmFeatureCommand extends FeatureGateCommand {
  final FeatureService _featureService;

  RmFeatureCommand({
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
      'Removes an existing FSDA Architecture feature structure inside a target module.';

  @override
  String get invocation => 'fsda rm $name -m <module> -f <feature>';

  @override
  bool get featureShouldExists => true;

  @override
  Future<int> handleFeatureGate(FeatureParam feature) async {
    final progress = logger.progress(
      'Removing feature "${feature.featureName}" from module "${feature.moduleName}"...',
    );

    try {
      await _featureService.feature(
        feature: feature,
        onProgress: (msg) => progress.update(msg),
      );

      progress.update('Generating report...');
      final reportBuffer = reportService.generateReport(
        operationLabel: 'Feature Removal Summary',
      );

      progress.complete(
        'Feature "${feature.featureName}" successfully removed from module "${feature.moduleName}"!',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to remove feature "${feature.featureName}": $e');
      return errorSystem;
    }
  }
}
