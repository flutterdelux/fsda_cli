```yaml title=".fsda/plans/apps/crud_provider.yaml"
app: crud_provider

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
    type: form
    target: task_status_update_dialog
    logic-flow: status_update
    logic: status_update_form
    ui: status_update_form

  - module: management
    feature: task
    type: m
    target: task_delete_dialog
    logic-flow: delete
```