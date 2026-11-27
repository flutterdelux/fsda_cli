<Tabs groupId="finish-target">
  <TabItem value="TaskUpdatePage" label="TaskUpdatePage" default>

```dart title="TaskUpdatePage"
...

class TaskUpdatePage extends StatelessWidget with PageBlocMixin {
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

  // add-start
  void _getTaskDetail(BuildContext context) {
    context.read<TaskDetailCubit>().getTaskDetail();
  }
  // add-end

  ...

  @override
  Widget build(BuildContext context) {
    final managementL10n = ManagementLocalizations.of(context)!;
    return buildPage(
      providers: [
        // add-start
        BlocProvider<TaskDetailCubit>(
          create: (_) =>
              sl<TaskDetailCubit>(param1: TaskDetailParam(id: id))
                ..getTaskDetail(),
        ),
        // add-end
        BlocProvider<TaskUpdateCubit>(create: (_) => sl<TaskUpdateCubit>()),
        BlocProvider<TaskUpdateFormCubit>(
          create: (_) => sl<TaskUpdateFormCubit>(),
        ),
      ],
      ...
  
  // add-start
  Widget _buildContent(BuildContext context) {
    return BlocBuilder<TaskDetailCubit, TaskDetailState>(
      builder: (_, state) => state.maybeWhen(
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
            context.read<TaskUpdateFormCubit>().updateState(
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
class TaskStatusUpdateDialog extends StatelessWidget with PageBlocMixin {
  final int id;
  // remove-next-line
  final TaskStatus status;

  const TaskStatusUpdateDialog({
    super.key,
    required this.id,
    // remove-next-line
    required this.status,
  });

  // add-start
  void _getTaskDetail(BuildContext context) {
    context.read<TaskDetailCubit>().getTaskDetail();
  }
  // add-end

  ...

  @override
  Widget build(BuildContext context) {
    final managementL10n = ManagementLocalizations.of(context)!;
    return buildPage(
      providers: [
        // add-start
        BlocProvider<TaskDetailCubit>(
          create: (_) =>
              sl<TaskDetailCubit>(param1: TaskDetailParam(id: id))
                ..getTaskDetail(),
        ),
        // add-end
        BlocProvider<TaskStatusUpdateCubit>(
          create: (_) => sl<TaskStatusUpdateCubit>(),
        ),
        BlocProvider<TaskStatusUpdateFormCubit>(
          create: (_) => sl<TaskStatusUpdateFormCubit>(),
        ),
      ],
      ...
  
  // add-start
  Widget _buildContent(BuildContext context) {
    return BlocBuilder<TaskDetailCubit, TaskDetailState>(
      builder: (_, state) => state.maybeWhen(
        orElse: () => const AppLoading(),
        failure: (failure) => TaskDetailErrorFeedback(
          message: failure.localizeAny(context),
          onRetry: () => _getTaskDetail(context),
        ),
        loaded: (data) => TaskStatusUpdateForm(
          initialData: TaskStatusUpdateParam(id: data.id, status: data.status),
          onListen: (context, param, invalidMessage) {
            context.read<TaskStatusUpdateFormCubit>().updateState(
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
