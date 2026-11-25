import '../../domain/params/app_integration/reg_module_param.dart';
import '../../infrastructure/services/reg_module_service.dart';
import 'wrapper/reg_module_gate_command.dart';

class RegModuleCommand extends RegModuleGateCommand {
  final RegModuleService _regModuleService;

  RegModuleCommand({
    required RegModuleService regModuleService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _regModuleService = regModuleService;

  @override
  String get name => 'module';

  @override
  String get description =>
      'Registers and injects a module configuration (DI, Router, Localizations, FailureX) into a target application.';

  @override
  String get invocation => 'fsda reg -m <module> -a <app>';

  @override
  Future<int> handleRegModule(RegModuleParam regModule) async {
    final param = regModule;
    final progress = logger.progress(
      'Registering module "${param.moduleName}" into target app "${param.appName}"...',
    );

    try {
      await _regModuleService.registerModule(
        param: param,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete(
        'Module "${param.moduleName}" successfully registered into "${param.appName}"!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Module Registration Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to register module: $e');
      return errorSystem;
    }
  }
}
