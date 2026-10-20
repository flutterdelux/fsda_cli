import 'package:get_it/get_it.dart';

import '../../infrastructure/services/operation_report_service.dart';
import '../../infrastructure/services/workspace_service.dart';
import '../cli_logger.dart';

final sl = GetIt.instance;

void configureDependencies() {
  sl.registerLazySingleton<CliLogger>(() => CliLogger());

  sl.registerLazySingleton<OperationReportService>(
    () => OperationReportService(),
  );
  sl.registerLazySingleton<WorkspaceService>(
    () => WorkspaceService(reportService: sl()),
  );
}
