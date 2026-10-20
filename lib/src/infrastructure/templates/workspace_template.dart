import '../../core/constants/cli_info.dart';

abstract final class WorkspaceTemplate {
  static StringBuffer buildFsda({
    required String workspaceName,
    required List<String> packages,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('workspace: $workspaceName');
    buffer.writeln();
    buffer.writeln('fsda_cli: "${CliInfo.version}"');
    buffer.writeln();
    buffer.writeln('packages:');
    for (final pkg in packages) {
      buffer.writeln('  # - $pkg');
    }
    return buffer;
  }
}
