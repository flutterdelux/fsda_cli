import '../../domain/params/app_param.dart';
import '../../infrastructure/services/configure_app_service.dart';
import 'wrapper/app_gate_command.dart';

class ConfigureAppCommand extends AppGateCommand {
  final ConfigureAppService _configureAppService;

  ConfigureAppCommand({
    required super.configService,
    required super.logger,
    required super.directoryService,
    required super.reportService,
    required ConfigureAppService configureAppService,
  }) : _configureAppService = configureAppService;

  @override
  String get name => 'app';

  @override
  String get description =>
      'Configures an existing Flutter application project inside apps/.';

  @override
  String get invocation => 'fsda configure -a <app>';

  @override
  bool get appShouldExists => true;

  @override
  Future<int> handleAppGate(AppParam app) async {
    final progress = logger.progress('Configure app "${app.appName}"...');

    try {
      await _configureAppService.configure(
        app: app,
        onProgress: (msg) => progress.update(msg),
      );
      progress.update('Generating report...');
      final reportBuffer = reportService.generateReport(
        operationLabel: 'App Configuration Summary',
      );

      progress.complete(
        'App "${app.appName}" successfully configured under apps/${app.appName}!',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to configure app ${app.appName}: $e');
      return errorSystem;
    }
  }
}
