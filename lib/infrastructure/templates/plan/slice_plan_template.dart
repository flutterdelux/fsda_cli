import 'parts/logic_flow_plan_template.dart';
import 'parts/logic_plan_template.dart';
import 'parts/model_plan_template.dart';
import 'parts/sequence_plan_template.dart';
import 'parts/ui_plan_template.dart';

abstract final class SlicePlanTemplate {
  static String build({
    required String moduleName,
    required String featureName,
    required String sliceName,
    bool isExample = false,
  }) => isExample
      ? _buildExample(moduleName, featureName, sliceName)
      : _buildRule(moduleName, featureName, sliceName);

  static String _buildRule(
    String moduleName,
    String featureName,
    String sliceName,
  ) =>
      '''
module: $moduleName
feature: $featureName
slice: $sliceName

# Optional feature-level prerequisites (auto-skipped if already exist)
# ds:
#   remote:
#     base-path: "/<endpoint>"

# enum:
#   - name: <enum_name>
#     values: "<val1>, <val2>"
#     lower: <true | false>

# model:
#   - name: <name>_<entity | dto | param | request | response>
#     with-dto: <true | false>
#     with-request: <true | false>
#     l10n: <true | false>
#     prop:
#       - "<Type>:<name>[:<default>[:<Converter>]]"

# Sequence -> Logic/Flow -> Input -> UI
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
#   - slice: ${sliceName}_form
#     control: <cubit | riverpod | getx | provider>
#     prop:
#       - "<Type>:<name>"

# logic-flow:
#   - slice: $sliceName
#     type: <m | r | pag>
#     uc: <name>_use_case
#     control: <cubit | riverpod | getx | provider>

# input:
#   - type: <input_type>
#     field: <field_name>

# ui:
#   - slice: $sliceName
#     type: <standard | form | lsv | lsh | pag>
#     model: <model_name>
''';

  static String _buildExample(
    String moduleName,
    String featureName,
    String sliceName,
  ) =>
      '''
module: $moduleName
feature: $featureName
slice: $sliceName

model:
  ${ModelPlanTemplate.perSlice(featureName: featureName, sliceName: sliceName).trim()}

sequence:
  ${SequencePlanTemplate.perSlice(featureName: featureName, sliceName: sliceName).trim()}

logic:
  ${LogicPlanTemplate.perSlice(featureName: featureName, sliceName: sliceName).trim()}

logic-flow:
  ${LogicFlowPlanTemplate.perSlice(featureName: featureName, sliceName: sliceName).trim()}

ui:
  ${UiPlanTemplate.perSlice(featureName: featureName, sliceName: sliceName).trim()}
''';
}
