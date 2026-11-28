<Tabs groupId="finish-target">
  <TabItem value="TaskUpdatePage" label="TaskUpdatePage" default>

```dart title="TaskUpdatePage"
...

class TaskUpdatePage extends StatefulWidget {
  final int id;
  // remove-start
  final String title;
  final String description;
  // remove-end

  const TaskUpdatePage({
    super.key,
    required this.id,
    // remove-start
    required this.title,
    required this.description,
    // remove-end
  });
}

class _TaskUpdatePageState extends State<TaskUpdatePage> {
  ...
  // add-next-line
  late final TaskDetailController _taskDetailController;

  // add-start
  void _getTaskDetail() {
    _taskDetailController.getTaskDetail();
  }
  // add-end

  ...

  @override
  void initState() {
    super.initState();    
    _taskUpdateController = Get.put(sl<TaskUpdateController>());
    _taskUpdateFormController = Get.put(sl<TaskUpdateFormController>());
    _taskUpdateControllerSubscription = _taskUpdateController.rxState.listen(
      _taskUpdateListener,
    );
    // add-start
    _taskDetailController = Get.put(
      sl<TaskDetailController>(param1: TaskDetailParam(id: widget.id)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _getTaskDetail();
    });
    // add-end
  }

  @override
  void dispose() {
    _taskUpdateControllerSubscription.cancel();
    Get.delete<TaskUpdateController>();
    Get.delete<TaskUpdateFormController>();
    // add-next-line
    Get.delete<TaskDetailController>();
    super.dispose();
  }

  ...
  
  // add-start
  Widget _buildContent(BuildContext context) {
    return Obx(
      () => _taskDetailController.state.maybeWhen(
        orElse: () => const AppLoading(),
        failure: (failure) => TaskDetailErrorFeedback(
          message: failure.localizeAny(context),
          onRetry: _getTaskDetail,
        ),
        loaded: (data) => TaskUpdateForm(
          initialData: TaskUpdateParam(
            id: data.id,
            title: data.title,
            description: data.description,
          ),
          onListen: (context, param, invalidMessage) {
            _taskUpdateFormController.updateState(
              param: param,
              invalidMessage: invalidMessage,
            );
          },
        ),
      ),
    );
  }
  // add-end
  ...
```

</TabItem>

<TabItem value="TaskStatusUpdatePage" label="TaskStatusUpdatePage">

```dart title="TaskStatusUpdatePage"
...
class TaskStatusUpdateDialog extends StatefulWidget {
  final int id;
  // remove-next-line
  final TaskStatus status;

  const TaskStatusUpdateDialog({
    super.key,
    required this.id,
    // remove-next-line
    required this.status,
  });

class _TaskStatusUpdateDialogState extends State<TaskStatusUpdateDialog> {
  ...
  // add-next-line
  late final TaskDetailController _taskDetailController;

  // add-start
  void _getTaskDetail() {
    _taskDetailController.getTaskDetail();
  }
  // add-end

  ...

  @override
  void initState() {
    super.initState();
    _taskStatusUpdateController = Get.put(sl<TaskStatusUpdateController>());
    _taskStatusUpdateFormController = Get.put(
      sl<TaskStatusUpdateFormController>(),
    );
    _taskStatusUpdateControllerSubscription = _taskStatusUpdateController
        .rxState
        .listen(_taskStatusUpdateListener);
    // add-start
    _taskDetailController = Get.put(
      sl<TaskDetailController>(param1: TaskDetailParam(id: widget.id)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _getTaskDetail();
    });
    // add-end
  }

  @override
  void dispose() {
    _taskStatusUpdateControllerSubscription.cancel();
    Get.delete<TaskStatusUpdateController>();
    Get.delete<TaskStatusUpdateFormController>();
    // add-next-line
    Get.delete<TaskDetailController>();
    super.dispose();
  }

  ...
  
  // add-start
  Widget _buildContent(BuildContext context) {
    return Obx(
      () => _taskDetailController.state.maybeWhen(
        orElse: () => const AppLoading(),
        failure: (failure) => TaskDetailErrorFeedback(
          message: failure.localizeAny(context),
          onRetry: _getTaskDetail,
        ),
        loaded: (data) => TaskStatusUpdateForm(
          initialData: TaskStatusUpdateParam(id: data.id, status: data.status),
          onListen: (context, param, invalidMessage) {
            _taskStatusUpdateFormController.updateState(
              param: param,
              invalidMessage: invalidMessage,
            );
          },
        ),
      ),
    );
  }
  // add-end
  ...
```

</TabItem>

<TabItem value="TaskDeleteDialog" label="TaskDeleteDialog">

```dart title="TaskDeleteDialog"
      ...
      builder: (context) {
        return Stack(
          children: [
            // add-next-line
            _buildContent(context),
            _buildOverlay(context),
          ],
        );
      },
      ...

  // add-start
  Widget _buildContent(BuildContext context) {
    return AppConfirmationDialog(
      title: 'Delete',
      message: 'Are you sure want to delete this task?',
      onConfirm: () {
        _deleteTask(context);
      },
      isDestructive: true,
    );
  }
  // add-end
  ...
```

</TabItem>
</Tabs>
