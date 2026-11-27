abstract final class AppPlanTemplate {
  static String build({required String appName, bool isExample = false}) =>
      isExample ? _buildExample(appName) : _buildRule(appName);

  static String _buildRule(String appName) =>
      '''
app: $appName

# compose:
#   - module: <module_name>
#     feature: <feature_name>
#     type: <m | r | pag | form>
#     target: <target_widget_name>
#     logic-flow: <slice_name>
#     ui: <slice_name>          # optional when type is m
#     logic: <slice_name>       # required when type is form
#     route: <bool>       # Only if _page
''';

  static String _buildExample(String appName) =>
      '''
app: $appName

compose:
  - module: management
    feature: task
    type: r
    target: task_list_page
    logic-flow: list
    ui: list
    route: true

  - module: management
    feature: task
    type: r
    target: task_detail_page
    logic-flow: detail
    ui: detail
    route: true

  - module: management
    feature: task
    type: form
    target: task_create_page
    logic-flow: create
    logic: create_form
    ui: create_form
    route: true

  - module: management
    feature: task
    type: form
    target: task_update_page
    logic-flow: update
    logic: update_form
    ui: update_form
    route: true

  - module: management
    feature: task
    type: m
    target: task_delete_dialog
    logic-flow: delete
''';
}
