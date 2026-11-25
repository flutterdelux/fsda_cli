import '../../domain/params/app_integration/reg_feature_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/reg_feature_service.dart';
import 'wrapper/reg_feature_gate_command.dart';

class RegFeatureCommand extends RegFeatureGateCommand {
  final RegFeatureService _regFeatureService;

  RegFeatureCommand({
    required RegFeatureService regFeatureService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _regFeatureService = regFeatureService;

  @override
  String get name => 'feature';

  @override
  String get description =>
      'Registers and injects a feature configuration (DI, Routes, Pages/Widgets scaffolding) into a target module within an app.';

  @override
  String get invocation => 'fsda reg -f <feature> -m <module> -a <app>';

  @override
  Future<int> handleRegFeature(RegFeatureParam regFeature) async {
    final param = regFeature;

    final progress = logger.progress(
      'Registering feature "${param.featureName}" into "${param.appName}/${param.moduleName}"...',
    );

    try {
      await _regFeatureService.registerFeature(
        param: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Feature "${param.featureName}" successfully registered into module "${param.appName}/${param.moduleName}"!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Feature Registration Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to register feature: $e');
      return errorSystem;
    }
  }
}
