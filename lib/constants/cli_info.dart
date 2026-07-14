abstract final class CliInfo {
  static const name = 'fsda_cli';
  static const executable = 'fsda';
  static const version = '1.0.4';
  static const description = 'Feature Slice Driven Architecture CLI';

  static String getConfigYaml({
    required String workspaceName,
    required List<String> packages,
  }) =>
      '''
workspace: $workspaceName
created_at: '${DateTime.now().toIso8601String()}'

fsda_cli: '$version'

packages:
${packages.map((e) => e.startsWith('infra_') && !e.contains('logging') ? '  # - $e' : '  - $e').join('\n')}
''';

  static const retrievalCheckpoint = '// ------- Retrieval -------';
  static const mutationCheckpoint = '// ------- Mutation -------';
}
