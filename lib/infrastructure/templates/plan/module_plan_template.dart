abstract final class ModulePlanTemplate {
  static String build({required String moduleName, bool isExample = false}) =>
      isExample ? _buildExample(moduleName) : _buildRule(moduleName);

  static String _buildRule(String moduleName) =>
      '''
module: $moduleName

# failure:
#   - "<failure_name>:<default_message>"
#   - name: <failure_name>
#     message: <default_message>
''';

  static String _buildExample(String moduleName) =>
      '''
module: $moduleName

failure:
  - name: task_invalid_status
    message: Task status field format not recognized.
  - name: task_creating_failed
    message: Failed to create task.
''';
}
