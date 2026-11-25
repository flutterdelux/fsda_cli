import 'package:path/path.dart' as p;

import '../../domain/params/workspace_param.dart';
import '../constants/cli_info.dart';

extension WorkspaceParamX on WorkspaceParam {
  String get configPath =>
      p.join(workspacePath, CliInfo.fsdaDirName, CliInfo.configFileName);
  String get relativeConfigPath => p.relative(configPath, from: workspacePath);

  String get runPath =>
      p.join(workspacePath, CliInfo.fsdaDirName, CliInfo.runFileName);
  String get relativeRunPath => p.relative(runPath, from: workspacePath);
}
