---
id: crud-examples
title: CRUD Examples
slug: /crud-examples
---

import CubitWorkspace from './crud/_cubit_workspace.md';
import GetxWorkspace from './crud/_getx_workspace.md';
import ProviderWorkspace from './crud/_provider_workspace.md';
import RiverpodWorkspace from './crud/_riverpod_workspace.md';

import CubitPlan from './crud/_cubit_plan.md';
import GetxPlan from './crud/_getx_plan.md';
import ProviderPlan from './crud/_provider_plan.md';
import RiverpodPlan from './crud/_riverpod_plan.md';

import CubitSlice from './crud/_cubit_slice.md';
import GetxSlice from './crud/_getx_slice.md';
import ProviderSlice from './crud/_provider_slice.md';
import RiverpodSlice from './crud/_riverpod_slice.md';

import CubitCompose from './crud/_cubit_compose.md';
import GetxCompose from './crud/_getx_compose.md';
import ProviderCompose from './crud/_provider_compose.md';
import RiverpodCompose from './crud/_riverpod_compose.md';

import CubitRunConfigure from './crud/_cubit_run_configure.md';
import GetxRunConfigure from './crud/_getx_run_configure.md';
import ProviderRunConfigure from './crud/_provider_run_configure.md';
import RiverpodRunConfigure from './crud/_riverpod_run_configure.md';

import CubitModifyTarget from './crud/_cubit_modify_target.md';
import GetxModifyTarget from './crud/_getx_modify_target.md';
import ProviderModifyTarget from './crud/_provider_modify_target.md';
import RiverpodModifyTarget from './crud/_riverpod_modify_target.md';

import CubitWireNavigation from './crud/_cubit_wire_navigation.md';
import GetxWireNavigation from './crud/_getx_wire_navigation.md';
import ProviderWireNavigation from './crud/_provider_wire_navigation.md';
import RiverpodWireNavigation from './crud/_riverpod_wire_navigation.md';

# End-to-End CRUD Examples

This guide demonstrates how to build a complete **Task Management CRUD** feature by combining **Declarative YAML plans** (to define models, sequences, logic, inputs, UI, and app composition) with **CLI script automation** via `.fsda/run.sh` (`fsda run`).

Choose your preferred state management approach:

<Tabs groupId="state-management" className="sticky-tabs">
  <TabItem value="cubit" label="Cubit" default/>
  <TabItem value="getx" label="GetX" />
  <TabItem value="provider" label="Provider" />
  <TabItem value="riverpod" label="Riverpod" />
</Tabs>

## 1. Initialize workspace

Create a new FSDA workspace and open it in your IDE (such as VS Code):

<Tabs groupId="state-management">

  <TabItem value="cubit" label="Cubit">
  <CubitWorkspace />
  </TabItem>

  <TabItem value="getx" label="GetX">
  <GetxWorkspace />
  </TabItem>

  <TabItem value="provider" label="Provider">
  <ProviderWorkspace />
  </TabItem>

  <TabItem value="riverpod" label="Riverpod">
  <RiverpodWorkspace />
  </TabItem>

</Tabs>

---

## 2. Prepare declarative YAML plans

Create the following YAML plan files under `.fsda/plans/` (or scaffold them first with `fsda plan` and replace their contents).

Use these command to create plans then modify or copy-paste from code block below.

<Tabs groupId="state-management">

  <TabItem value="cubit" label="Cubit">
  <CubitPlan />
  </TabItem>

  <TabItem value="getx" label="GetX">
  <GetxPlan />
  </TabItem>

  <TabItem value="provider" label="Provider">
  <ProviderPlan />
  </TabItem>

  <TabItem value="riverpod" label="Riverpod">
  <RiverpodPlan />
  </TabItem>

</Tabs>

### Module Plan

```yaml title=".fsda/plans/modules/management/index.yaml"
module: management

failure:
  - name: task_creation_failed
    message: Failed to create task. Please try again later.
  - name: task_updating_failed
    message: Failed to update task. Please try again later.
  - name: task_deleting_failed
    message: Failed to delete task. Please try again later.
```

### Feature Plan

```yaml title=".fsda/plans/modules/management/features/task/index.yaml"
module: management
feature: task

ds:
  remote:
    base-path: "/tasks"

enum:
  - name: task_status
    values: todo, in_progress, completed
    lower: true

model:
  - name: task_entity
    with-dto: true
    l10n: true
    prop:
      - "int:id"
      - "String:title"
      - "String:description"
      - "TaskStatus:status::TaskStatusConverter"
      - "DateTime:created_at::UtcDateTimeConverter"
      - "DateTime:updated_at::UtcDateTimeConverter"

input:
  - type: text
    field: title
  - type: text_area
    field: description
    min: 5
    max: 5
  - type: dropdown_enum
    field: status
    data-type: TaskStatus
```

### Slice Plans

<Tabs groupId="state-management">

  <TabItem value="cubit" label="Cubit">
  <CubitSlice />
  </TabItem>

  <TabItem value="getx" label="GetX">
  <GetxSlice />
  </TabItem>

  <TabItem value="provider" label="Provider">
  <ProviderSlice />
  </TabItem>

  <TabItem value="riverpod" label="Riverpod">
  <RiverpodSlice />
  </TabItem>

</Tabs>


### App Compose Plan

<Tabs groupId="state-management">

  <TabItem value="cubit" label="Cubit">
  <CubitCompose />
  </TabItem>

  <TabItem value="getx" label="GetX">
  <GetxCompose />
  </TabItem>

  <TabItem value="provider" label="Provider">
  <ProviderCompose />
  </TabItem>

  <TabItem value="riverpod" label="Riverpod">
  <RiverpodCompose />
  </TabItem>

</Tabs>

---

## 3. Run Configure

<Tabs groupId="state-management">

  <TabItem value="cubit" label="Cubit">
  <CubitRunConfigure />
  </TabItem>

  <TabItem value="getx" label="GetX">
  <GetxRunConfigure />
  </TabItem>

  <TabItem value="provider" label="Provider">
  <ProviderRunConfigure />
  </TabItem>

  <TabItem value="riverpod" label="Riverpod">
  <RiverpodRunConfigure />
  </TabItem>

</Tabs>


---

## 4. Finish and verify

1. **Modify Target Artifact** that are generated so it will work on.


<Tabs groupId="state-management">

  <TabItem value="cubit" label="Cubit">
  <CubitModifyTarget />
  </TabItem>

  <TabItem value="getx" label="GetX">
  <GetxModifyTarget />
  </TabItem>

  <TabItem value="provider" label="Provider">
  <ProviderModifyTarget />
  </TabItem>

  <TabItem value="riverpod" label="Riverpod">
  <RiverpodModifyTarget />
  </TabItem>

</Tabs>

2. **Wire navigation & actions**: Since `route: true` was set on the page targets (`task_list_page`, `task_detail_page`, `task_create_page`, and `task_update_page`), verify the generated routes in your app router, set `task_list_page` as the initial or home destination, and hook up triggers for `task_status_update_dialog` and `task_delete_dialog`.

<Tabs groupId="state-management">

  <TabItem value="cubit" label="Cubit">
  <CubitWireNavigation />
  </TabItem>

  <TabItem value="getx" label="GetX">
  <GetxWireNavigation />
  </TabItem>

  <TabItem value="provider" label="Provider">
  <ProviderWireNavigation />
  </TabItem>

  <TabItem value="riverpod" label="Riverpod">
  <RiverpodWireNavigation />
  </TabItem>

</Tabs>


3. **Implement remote endpoints**: Update task_remote_data_source_impl.dart with your actual API endpoints and payload serialization.

```dart title="TaskRemoteDataSourceImpl"
  ...

  @override
  Future<void> statusUpdateTask(TaskStatusUpdateRequest request) async {
    // add-next-line
    final path = '$_basePath/${request.id}/status';
    final apiResponse = await _apiClient.patch<Map<String, dynamic>>(
      path,
      body: request.toJson(),
    );
    if (apiResponse.statusCode == 200) return;
    throw ManagementException.fromApiResponse(
      apiResponse,
      st: StackTrace.current,
    );
  }

  ...
```

4. **Modify Arb**: Edit and fix generated arb entries.
5. **Run the app**: Launch crud_cubit on a simulator or device to verify the full CRUD lifecycle.

### Screenshot

<div className="screenshot-grid">
  <img src="/fsda_cli/images/crud-cubit/ss1.png" alt="Task List" />
  <img src="/fsda_cli/images/crud-cubit/ss2.png" alt="Task Create" />
  <img src="/fsda_cli/images/crud-cubit/ss3.png" alt="Task Detail" />
  <img src="/fsda_cli/images/crud-cubit/ss4.png" alt="Task Status Update" />
  <img src="/fsda_cli/images/crud-cubit/ss5.png" alt="Task Update" />
  <img src="/fsda_cli/images/crud-cubit/ss6.png" alt="Task Delete" />
</div>
