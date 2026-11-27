<Tabs groupId="crud-slices">
  <TabItem value="list" label="list.yaml" default>

```yaml title=".fsda/plans/modules/management/features/task/list.yaml"
module: management
feature: task
slice: list

model:
  - name: task_list_response
    prop:
      - "String:message"
      - "List<TaskDto>?:data"

sequence:
  - uc: task_list_use_case
    act: get
    method: get_task_list
    flow: async
    ds: remote
    list: true
    model:
      - task_dto
      - task_entity
      - task_list_response

logic:

logic-flow:
  - slice: list
    type: r
    uc: task_list_use_case
    control: riverpod

ui:
  - slice: list
    type: lsv
    model: task_entity
```

  </TabItem>
  <TabItem value="detail" label="detail.yaml">

```yaml title=".fsda/plans/modules/management/features/task/detail.yaml"
module: management
feature: task
slice: detail

model:
  - name: task_detail_response
    prop:
      - "String:message"
      - "TaskDto?:data"
  - name: task_detail_param
    with-request: true
    prop:
      - "int:id"

sequence:
  - uc: task_detail_use_case
    act: get
    method: get_task_detail
    flow: async
    ds: remote
    model:
      - task_dto
      - task_entity
      - task_detail_response
      - task_detail_param
      - task_detail_request

logic:

logic-flow:
  - slice: detail
    type: r
    uc: task_detail_use_case
    control: riverpod

ui:
  - slice: detail
    type: standard
    model: task_entity
```

  </TabItem>
  <TabItem value="create" label="create.yaml">

```yaml title=".fsda/plans/modules/management/features/task/create.yaml"
module: management
feature: task
slice: create

model:
  - name: task_create_param
    with-request: true
    prop:
      - "String:title"
      - "String:description"

sequence:
  - uc: task_create_use_case
    act: post
    method: create_task
    flow: async
    ds: remote
    model:
      - task_create_param
      - task_create_request

logic:
  - slice: create_form
    control: riverpod
    prop:
      - "TaskCreateParam?:param"
      - "String?:invalid_message"

logic-flow:
  - slice: create
    type: m
    uc: task_create_use_case
    control: riverpod

ui:
  - slice: create_form
    type: form
    model: task_create_param
    field:
      - "text:String:title"
      - "text_area:String:description"
```

  </TabItem>
  <TabItem value="update" label="update.yaml">

```yaml title=".fsda/plans/modules/management/features/task/update.yaml"
module: management
feature: task
slice: update

model:
  - name: task_update_param
    with-request: true
    prop:
      - "int:id"
      - "String:title"
      - "String:description"

sequence:
  - uc: task_update_use_case
    act: put
    method: update_task
    flow: async
    ds: remote
    model:
      - task_update_param
      - task_update_request

logic:
  - slice: update_form
    control: riverpod
    prop:
      - "TaskUpdateParam?:param"
      - "String?:invalid_message"

logic-flow:
  - slice: update
    type: m
    uc: task_update_use_case
    control: riverpod

ui:
  - slice: update_form
    type: form
    model: task_update_param
    initial: true
    field:
      - "text:String:title"
      - "text_area:String:description"
```

  </TabItem>
  <TabItem value="status_update" label="status_update.yaml">

```yaml title=".fsda/plans/modules/management/features/task/status_update.yaml"
module: management
feature: task
slice: status_update

model:
  - name: task_status_update_param
    with-request: true
    prop:
      - "int:id"
      - "TaskStatus:status::TaskStatusConverter"

sequence:
  - uc: task_status_update_use_case
    act: patch
    method: status_update_task
    flow: async
    ds: remote
    model:
      - task_status_update_param
      - task_status_update_request

logic:
  - slice: status_update_form
    control: riverpod
    prop:
      - "TaskStatusUpdateParam?:param"
      - "String?:invalid_message"

logic-flow:
  - slice: status_update
    type: m
    uc: task_status_update_use_case
    control: riverpod

ui:
  - slice: status_update_form
    type: form
    model: task_status_update_param
    initial: true
    field:
      - "dropdown_enum:TaskStatus:status"
```

  </TabItem>
  <TabItem value="delete" label="delete.yaml">

```yaml title=".fsda/plans/modules/management/features/task/delete.yaml"
module: management
feature: task
slice: delete

model:
  - name: task_delete_param
    with-request: true
    prop:
      - "int:id"

sequence:
  - uc: task_delete_use_case
    act: delete
    method: delete_task
    flow: async
    ds: remote
    model:
      - task_delete_param
      - task_delete_request

logic:

logic-flow:
  - slice: delete
    type: m
    uc: task_delete_use_case
    control: riverpod

ui:
```

  </TabItem>
</Tabs>