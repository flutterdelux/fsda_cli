import 'package:args/command_runner.dart';

import '../generated/package_bundle.dart';
import '../services/logger_service.dart';
import '../services/workspace_service.dart';

class ListPckgCommand extends Command<void> {
  final LoggerService logger;
  final WorkspaceService workspaceService;

  ListPckgCommand({required this.logger, required this.workspaceService});

  @override
  String get name => 'list-pckg';

  @override
  String get description => 'List all available package templates.';

  @override
  String get invocation => 'fsda list-pckg';

  @override
  Future<void> run() async {
    workspaceService.ensureInsideWorkspace(usage);

    final args = argResults!.rest;

    if (args.isNotEmpty) {
      final strayArgs = args.join(' ');
      throw UsageException('Unexpected argument(s): "$strayArgs".', usage);
    }

    final allPackages = packageBundle.keys.toList()..sort();

    _renderSection(
      'Available Package Templates (Use full name for "fsda add-pckg <name>"):',
      allPackages,
    );
  }

  void _renderSection(String title, List<String> items) {
    logger.info(title);
    if (items.isEmpty) {
      logger.info('  (none)');
      return;
    }
    for (final item in items) {
      logger.log('  - $item');
    }
  }
}
