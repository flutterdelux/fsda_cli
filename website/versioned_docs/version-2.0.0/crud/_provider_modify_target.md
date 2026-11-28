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

class _TaskUpdatePageState extends State<TaskUpdatePage>
    with PageProviderMixin {
  ...

  // add-start
  void _getTaskDetail(BuildContext context) {
    context.read<TaskDetailProvider>().getTaskDetail();
  }
  // add-end

  ...

  @override
  Widget build(BuildContext context) {
    final managementL10n = ManagementLocalizations.of(context)!;
    return buildPage(
      providers: [
        // add-start
        ChangeNotifierProvider<TaskDetailProvider>(
          create: (_) =>
              sl<TaskDetailProvider>(param1: TaskDetailParam(id: widget.id))
                ..getTaskDetail(),
        ),
        // add-end
        ChangeNotifierProvider<TaskUpdateProvider>.value(
          value: _taskUpdateProvider,
        ),
        ChangeNotifierProvider<TaskUpdateFormProvider>.value(
          value: _taskUpdateFormProvider,
        ),
      ],
      ...
  
  // add-start
  Widget _buildContent(BuildContext context) {
    return Consumer<TaskDetailProvider>(
      builder: (context, provider, _) => provider.state.maybeWhen(
        orElse: () => const AppLoading(),
        failure: (failure) => TaskDetailErrorFeedback(
          message: failure.localizeAny(context),
          onRetry: () => _getTaskDetail(context),
        ),
        loaded: (data) => TaskUpdateForm(
          initialData: TaskUpdateParam(
            id: data.id,
            title: data.title,
            description: data.description,
          ),
          onListen: (context, param, invalidMessage) {
            _taskUpdateFormProvider.updateState(
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

  ...
}

class _TaskStatusUpdateDialogState extends State<TaskStatusUpdateDialog>
    with PageProviderMixin {
  ...

  // add-start
  void _getTaskDetail(BuildContext context) {
    context.read<TaskDetailProvider>().getTaskDetail();
  }
  // add-end

  ...

  @override
  Widget build(BuildContext context) {
    final managementL10n = ManagementLocalizations.of(context)!;
    return buildPage(
      providers: [
        // add-start
        ChangeNotifierProvider<TaskDetailProvider>(
          create: (_) =>
              sl<TaskDetailProvider>(param1: TaskDetailParam(id: widget.id))
                ..getTaskDetail(),
        ),
        // add-end
        ChangeNotifierProvider<TaskStatusUpdateProvider>.value(
          value: _taskStatusUpdateProvider,
        ),
        ChangeNotifierProvider<TaskStatusUpdateFormProvider>.value(
          value: _taskStatusUpdateFormProvider,
        ),
      ],
      ...
  
  // add-start
  Widget _buildContent(BuildContext context) {
    return Consumer<TaskDetailProvider>(
      builder: (context, provider, _) => provider.state.maybeWhen(
        orElse: () => const AppLoading(),
        failure: (failure) => TaskDetailErrorFeedback(
          message: failure.localizeAny(context),
          onRetry: () => _getTaskDetail(context),
        ),
        loaded: (data) => TaskStatusUpdateForm(
          initialData: TaskStatusUpdateParam(
            id: data.id,
            status: data.status,
          ),
          onListen: (context, param, invalidMessage) {
            _taskStatusUpdateFormProvider.updateState(
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
