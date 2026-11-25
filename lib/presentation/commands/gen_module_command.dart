import '../../domain/params/module_param.dart';
import '../../infrastructure/services/module_service.dart';
import 'wrapper/module_gate_command.dart';

class GenModuleCommand extends ModuleGateCommand {
  final ModuleService _moduleService;

  GenModuleCommand({
    required ModuleService moduleService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _moduleService = moduleService;

  @override
  String get name => 'module';

  @override
  String get description =>
      'Generates a new FSDA Architecture module template.';

  @override
  String get invocation => 'fsda gen -m <module>';

  @override
  bool get moduleShouldExists => false;

  @override
  Future<int> handleModuleGate(ModuleParam module) async {
    final progress = logger.progress(
      'Generating module "${module.moduleName}"...',
    );

    try {
      await _moduleService.generate(
        module: module,
        onProgress: (msg) => progress.update(msg),
      );

      progress.update('Generating report...');
      final reportBuffer = reportService.generateReport(
        operationLabel: 'Module Generation Summary',
      );

      progress.complete(
        'Module "${module.moduleName}" successfully generated and configured!',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate module: $e');
      return errorSystem;
    }
  }
}
