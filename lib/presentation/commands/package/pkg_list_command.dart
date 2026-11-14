import 'dart:collection';

import '../../../infrastructure/bundles/package_bundle.dart';
import '../../cli_logger.dart';
import '../wrapper/base_command.dart';

class PkgListCommand extends BaseCommand {
  final CliLogger logger;

  PkgListCommand({required this.logger});

  @override
  String get name => 'list';

  @override
  String get description =>
      'List all available package templates bundled within FSDA CLI.';

  @override
  String get invocation => 'fsda pkg list';

  @override
  Future<int> run() async {
    final rest = argResults?.rest ?? [];
    if (rest.isNotEmpty) {
      logger.error('Invalid command.');
      logger.log('Usage: $invocation');
      return errorUsage;
    }

    final packages = SplayTreeSet<String>.from(packageBundle.keys);

    logger.log('');
    logger.log('============================================================');
    logger.log('Available Package Templates (${packages.length}):');
    logger.log('============================================================');

    if (packages.isEmpty) {
      logger.log('  - No package templates available.');
    } else {
      for (final pkg in packages) {
        logger.log('  - $pkg');
      }
    }

    logger.log('------------------------------------------------------------');
    logger.log(
      'Tip: Run "fsda pkg add <package_name>" to add and synchronize,',
    );
    logger.log('     or edit "fsda.yaml" and run "fsda pkg get".');
    logger.log('------------------------------------------------------------');

    return successCode;
  }
}
