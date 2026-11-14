import 'package:args/command_runner.dart';

import '../../../infrastructure/services/helpers/config_service.dart';
import '../../../infrastructure/services/helpers/directory_service.dart';
import '../../../infrastructure/services/helpers/operation_report_service.dart';
import '../../../infrastructure/services/package_sync_service.dart';
import '../../cli_logger.dart';
import 'pkg_add_command.dart';
import 'pkg_get_command.dart';
import 'pkg_list_command.dart';
import 'pkg_rm_command.dart';

class PkgCommand extends Command {
  @override
  String get name => 'pkg';

  @override
  String get description => 'Manage workspace packages.';

  PkgCommand({
    required CliLogger logger,
    required ConfigService configService,
    required PackageSyncService packageSyncService,
    required OperationReportService reportService,
    required DirectoryService directoryService,
  }) {
    addSubcommand(PkgListCommand(logger: logger));
    addSubcommand(
      PkgGetCommand(
        logger: logger,
        configService: configService,
        packageSyncService: packageSyncService,
        reportService: reportService,
        directoryService: directoryService,
      ),
    );
    addSubcommand(
      PkgAddCommand(
        logger: logger,
        configService: configService,
        packageSyncService: packageSyncService,
        reportService: reportService,
        directoryService: directoryService,
      ),
    );
    addSubcommand(
      PkgRmCommand(
        logger: logger,
        configService: configService,
        packageSyncService: packageSyncService,
        reportService: reportService,
        directoryService: directoryService,
      ),
    );
  }
}
