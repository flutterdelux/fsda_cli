import '../../core/extensions/arg_results_x.dart';
import '../../core/extensions/failure_param_x.dart';
import '../../domain/params/failure_param.dart';
import '../../domain/params/module_param.dart';
import '../../infrastructure/services/failure_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
import '../resolvers/failure_resolver.dart';
import 'wrapper/module_gate_command.dart';

class GenFailureCommand extends ModuleGateCommand {
  final FailureService _failureService;
  final FileService _fileService;

  GenFailureCommand({
    required FailureService failureService,
    required FileService fileService,
    required super.configService,
    required super.logger,
    required super.reportService,
    required super.directoryService,
  }) : _failureService = failureService,
       _fileService = fileService {
    argParser.addMultiOption(
      FailureResolverKeys.failure,
      help:
          'Define failure option (e.g., --failure "not_found:Resource not found").',
    );
  }

  @override
  String get name => 'failure';

  @override
  String get description =>
      'Injects failure options into module exception, failure, extension, and ARB files.';

  @override
  String get invocation =>
      'fsda gen -m <module> --failure "<name>:<message>" [--failure "<name>:<message>"]';

  @override
  bool get moduleShouldExists => true;

  @override
  Future<int> handleModuleGate(ModuleParam module) async {
    List<FailureParam> failures;
    try {
      failures = FailureResolver.resolveAll(
        module: module,
        data: argResults?.toMap() ?? {},
      );
    } catch (e) {
      logger.error(e is FormatException ? e.message : e.toString());
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final sample = failures.first;
    if (!await _fileService.exists(sample.exceptionPath)) {
      logger.error('Exception file not found at ${sample.exceptionPath}');
      return errorSystem;
    }

    if (!await _fileService.exists(sample.failurePath)) {
      logger.error('Failure file not found at ${sample.failurePath}');
      return errorSystem;
    }

    if (!await _fileService.exists(sample.extensionPath)) {
      logger.error(
        'Failure extension file not found at ${sample.extensionPath}',
      );
      return errorSystem;
    }

    final progress = logger.progress(
      'Injecting ${failures.length} failure(s) into module "${module.moduleName}"...',
    );

    try {
      for (final failure in failures) {
        progress.update('Injecting failure "${failure.name}"...');
        await _failureService.generate(
          failureParam: failure,
          onProgress: (msg) => progress.update(msg),
        );
      }

      progress.complete(
        'Successfully injected ${failures.length} failure(s) into "${module.moduleName}"!',
      );

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Failure Injection Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to inject failures: $e');
      return errorSystem;
    }
  }
}
