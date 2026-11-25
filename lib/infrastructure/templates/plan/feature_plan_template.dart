import 'parts/logic_flow_plan_template.dart';
import 'parts/logic_plan_template.dart';
import 'parts/model_plan_template.dart';
import 'parts/sequence_plan_template.dart';
import 'parts/ui_plan_template.dart';

abstract final class FeaturePlanTemplate {
  static String build({
    required String moduleName,
    required String featureName,
    bool isExample = false,
  }) => isExample
      ? _buildExample(moduleName, featureName)
      : _buildRule(moduleName, featureName);

  static String _buildRule(String moduleName, String featureName) =>
      '''
module: $moduleName
feature: $featureName

# ds:
#   remote:
#     base-path: "/<endpoint>"
#   local:
#     cache-key: "<cache_key>"

# enum:
#   - name: <enum_name>
#     values: "<val1>, <val2>, <val3>"
#     lower: <true | false>

# model:
#   - name: <name>_<entity | dto | param | request | response>
#     with-dto: <true | false>      # entity only
#     with-request: <true | false>  # param only
#     l10n: <true | false>          # entity only
#     prop:
#       - "<Type>:<name>[:<default>[:<Converter>]]"

# sequence:
#   - uc: <name>_use_case
#     act: <get | post | put | patch | delete>
#     method: <method_name>
#     flow: <async | stream>
#     ds: <remote | local>
#     list: <true | false>
#     model:
#       - <model_name>

# logic:
#   - slice: <slice_name>
#     control: <cubit | riverpod | getx | provider>
#     prop:
#       - "<Type>:<name>[:<default>]"

# logic-flow:
#   - slice: <slice_name>
#     type: <m | r | pag>
#     uc: <name>_use_case
#     control: <cubit | riverpod | getx | provider>

# input:
#   - type: <text | text_area | password | email | number | phone | dropdown_enum | ...>
#     field: <field_name>
#     data-type: <Type>
#     min: <int>
#     max: <int>
#     list: <bool>

# ui:
#   - slice: <slice_name>
#     type: <standard | form | lsv | lsh | pag>
#     model: <model_name>
#     initial: <true | false>
#     field:
#       - "<input_type>:<Type>:<field_name>"
''';

  static String _buildExample(String moduleName, String featureName) =>
      '''
module: $moduleName
feature: $featureName

ds:
  remote:
    base-path: "/${featureName}s"

enum:
  - name: ${featureName}_status
    values: draft, published, archived
    lower: true

model:
  ${ModelPlanTemplate.all(featureName).trim()}

sequence:
  ${SequencePlanTemplate.all(featureName).trim()}

logic:
  ${LogicPlanTemplate.all(featureName).trim()}

logic-flow:
  ${LogicFlowPlanTemplate.all(featureName).trim()}

input:
  - type: text
    field: title
  - type: text_area
    field: description
    min: 3
    max: 5

ui:
  ${UiPlanTemplate.all(featureName).trim()}
''';
}
