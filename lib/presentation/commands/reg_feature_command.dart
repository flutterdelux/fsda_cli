import '../../core/extensions/app_integration_param_x.dart';
import '../../domain/params/app_integration/app_integration_param.dart';
import '../../domain/params/app_integration/reg_feature_param.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../../infrastructure/services/reg_feature_service.dart';
import 'wrapper/app_integration_command.dart';

class RegFeatureCommand extends AppIntegrationCommand {
  final RegFeatureService _regFeatureService;
  final FileService _fileService;

  RegFeatureCommand({
    required RegFeatureService regFeatureService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _regFeatureService = regFeatureService,
       _fileService = fileService;

  @override
  String get name => 'reg-feature';

  @override
  String get description =>
      'Registers and injects a feature configuration (DI, Routes, Pages/Widgets scaffolding) into a target module within an app.';

  @override
  String get invocation => 'fsda reg-feature -f <feature> -m <module> -a <app>';

  @override
  Future<int> handleAppIntegration(AppIntegrationParam appIntegration) async {
    final param = RegFeatureParam.fromAppIntegration(appIntegration);

    final featureName = param.featureName;
    if (featureName == null || featureName.isEmpty) {
      logger.error('Missing required option: -f, --feature.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (!await _fileService.exists(param.appModuleDiPath)) {
      logger.error(
        'Module DI file not found at ${param.appModuleDiPath}. Make sure the module is registered via reg-module first.',
      );
      return errorUsage;
    }

    if (!await _fileService.exists(param.appModuleRoutePath)) {
      logger.error(
        'Module Route file not found at ${param.appModuleRoutePath}.',
      );
      return errorUsage;
    }

    final progress = logger.progress(
      'Registering feature "$featureName" into module "${param.moduleName}" (app: "${param.appName}")...',
    );

    try {
      await _regFeatureService.registerFeature(
        param: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Feature "$featureName" successfully registered into module "${param.moduleName}"!',
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
