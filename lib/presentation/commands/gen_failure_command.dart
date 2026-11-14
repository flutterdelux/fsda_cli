import '../../core/constants/rules.dart';
import '../../core/extensions/failure_param_x.dart';
import '../../domain/params/failure_param.dart';
import '../../domain/params/module_gate_param.dart';
import '../../infrastructure/services/failure_service.dart';
import '../../infrastructure/services/helpers/file_service.dart';
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
       _fileService = fileService;

  @override
  String get name => 'gen-failure';

  @override
  String get description =>
      'Injects a new failure option into module exception, failure, extension, and ARB files.';

  @override
  String get invocation => 'fsda gen-failure "<name>:<message>" -m <module>';

  @override
  Future<int> handleModuleGate(ModuleGateParam moduleGate) async {
    final rest = argResults?.rest;
    if (rest == null || rest.isEmpty) {
      logger.error(
        'Failure definition argument "<name>:<message>" is required.',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (rest.length > 1) {
      logger.error(
        'Invalid arguments: "$rest". Expected single argument format "<name>:<message>".',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final argString = rest.first;
    final colonIndex = argString.indexOf(':');

    if (colonIndex == -1 ||
        colonIndex == 0 ||
        colonIndex == argString.length - 1) {
      logger.error(
        'Invalid format: "$argString". Expected format "<name>:<message>".',
      );
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final failureName = argString.substring(0, colonIndex).trim();
    final failureMessage = argString.substring(colonIndex + 1).trim();

    if (!Rules.failureNameRegExp.hasMatch(failureName)) {
      logger.error('Invalid failure name format: "$failureName".');
      logger.log(Rules.failureNameDescription);
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    if (failureMessage.isEmpty) {
      logger.error('Failure message cannot be empty.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final failureParam = FailureParam(
      moduleName: moduleGate.moduleName,
      modulePath: moduleGate.modulePath,
      name: failureName,
      message: failureMessage,
    );

    if (!await _fileService.exists(failureParam.exceptionPath)) {
      logger.error('Exception file not found at ${failureParam.exceptionPath}');
      return errorSystem;
    }

    if (!await _fileService.exists(failureParam.failurePath)) {
      logger.error('Failure file not found at ${failureParam.failurePath}');
      return errorSystem;
    }

    if (!await _fileService.exists(failureParam.extensionPath)) {
      logger.error(
        'Failure extension file not found at ${failureParam.exceptionPath}',
      );
      return errorSystem;
    }

    final progress = logger.progress(
      'Injecting failure "$failureName" into module "${moduleGate.moduleName}"...',
    );

    try {
      await _failureService.generateFailure(
        failureParam: failureParam,
        onProgress: (msg) => progress.update(msg),
      );

      progress.complete('Failure "$failureName" successfully injected!');

      final reportBuffer = reportService.generateReport(
        operationLabel: 'Failure Injection Summary',
      );
      logger.log(reportBuffer.toString());

      return successCode;
    } catch (e) {
      progress.fail('Failed to inject failure $failureName: $e');
      return errorSystem;
    }
  }
}
