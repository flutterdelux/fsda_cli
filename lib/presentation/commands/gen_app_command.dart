import '../../core/constants/rules.dart';
import '../../core/extensions/arg_results_x.dart';
import '../../domain/params/app_param.dart';
import '../../domain/params/gen_app_param.dart';
import '../../infrastructure/services/app_service.dart';
import '../resolvers/gen_app_resolver.dart';
import 'wrapper/app_gate_command.dart';

class GenAppCommand extends AppGateCommand {
  final AppService _appService;

  GenAppCommand({
    required super.configService,
    required super.logger,
    required super.directoryService,
    required super.reportService,
    required AppService appService,
  }) : _appService = appService {
    argParser.addOption(
      GenAppResolverKeys.org,
      help: 'The organization identifier (e.g., com.example).',
      defaultsTo: Rules.orgDefault,
    );
    argParser.addOption(
      GenAppResolverKeys.title,
      help: 'The title or label of the app.',
    );
    argParser.addOption(
      GenAppResolverKeys.orgName,
      help: 'The Organization name.',
    );
  }

  @override
  String get name => 'app';

  @override
  String get description =>
      'Generates a new Flutter application project inside apps/.';

  @override
  String get invocation =>
      'fsda gen -a <app> [--org <org>] [--title "<App Name>"] [--org-name "<Organization Name>"]';

  @override
  bool get appShouldExists => false;

  @override
  Future<int> handleAppGate(AppParam app) async {
    final data = argResults?.toMap() ?? {};

    GenAppParam genApp;
    try {
      genApp = GenAppResolver.resolve(data: data, app: app);
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final progress = logger.progress(
      'Generating app "${genApp.appName}" with org "${genApp.org}"...',
    );

    try {
      await _appService.generate(
        genApp: genApp,
        onProgress: (msg) => progress.update(msg),
      );
      progress.update('Generating report...');
      final reportBuffer = reportService.generateReport(
        operationLabel: 'App Generation Summary',
      );

      progress.complete(
        'App "${genApp.appName}" successfully generated under apps/${genApp.appName}!',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to generate app ${genApp.appName}: $e');
      return errorSystem;
    }
  }
}
