<Tabs groupId="finish-target">
  <TabItem value="TaskUpdatePage" label="TaskUpdatePage" default>

```dart title="TaskUpdatePage"
...

class TaskUpdatePage extends ConsumerStatefulWidget {
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
...

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  ...
  // add-start
  late final _taskDetailProvider =
      AutoDisposeNotifierProvider<TaskDetailProvider, TaskDetailState>(
    () => sl<TaskDetailProvider>(),
  );
  // add-end

  // add-start
  void _getTaskDetail() {
    ref.read(_taskDetailProvider.notifier).getTaskDetail(TaskDetailParam(id: widget.id));
  }
  // add-end

  ...

  @override
  void initState() {
    super.initState();
    ref.listenManual(_taskUpdateFormProvider, (_, _) {});
    // add-start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _getTaskDetail();
    });
    // add-end
  }  

  ...
  
  // add-start
  Widget _buildContent(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(_taskDetailProvider);
        return state.maybeWhen(
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
              ref
                  .read(_taskUpdateFormProvider.notifier)
                  .updateState(param: param, invalidMessage: invalidMessage);
            },
          ),
        );
      },
    );
  }
  // add-end
  ...
```

</TabItem>

<TabItem value="TaskStatusUpdatePage" label="TaskStatusUpdatePage">

```dart title="TaskStatusUpdatePage"
...
class TaskStatusUpdateDialog extends ConsumerStatefulWidget {
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

class _TaskStatusUpdateDialogState
    extends ConsumerState<TaskStatusUpdateDialog> {
  ...

  // add-start
  late final _taskDetailProvider =
      AutoDisposeNotifierProvider<TaskDetailProvider, TaskDetailState>(
        () => sl<TaskDetailProvider>(),
      );
  // add-end

  // add-start
  void _getTaskDetail() {
    ref
        .read(_taskDetailProvider.notifier)
        .getTaskDetail(TaskDetailParam(id: widget.id));
  }
  // add-end

  ...

  @override
  void initState() {
    super.initState();
    ref.listenManual(_taskStatusUpdateFormProvider, (_, _) {});
    // add-start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _getTaskDetail();
    });
    // add-end
  }  

  ...
  
  // add-start
  Widget _buildContent(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(_taskDetailProvider);
        return state.maybeWhen(
          orElse: () => const AppLoading(),
          failure: (failure) => TaskDetailErrorFeedback(
            message: failure.localizeAny(context),
            onRetry: _getTaskDetail,
          ),
          loaded: (data) => TaskStatusUpdateForm(
            initialData: TaskStatusUpdateParam(
              id: data.id,
              status: data.status,
            ),
            onListen: (context, param, invalidMessage) {
              ref
                  .read(_taskStatusUpdateFormProvider.notifier)
                  .updateState(param: param, invalidMessage: invalidMessage);
            },
          ),
        );
      },
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
            _buildContent(),
            _buildOverlay(context),
          ],
        );
      },
      ...

  // add-start
  Widget _buildContent() {
    return AppConfirmationDialog(
      title: 'Delete',
      message: 'Are you sure want to delete this task?',
      onConfirm: () {
        _deleteTask();
      },
      isDestructive: true,
    );
  }
  // add-end
  ...
```

</TabItem>

<TabItem value="Main" label="main">

```dart title="main"
...
// add-next-line
import 'package:flutter_riverpod/flutter_riverpod.dart';
...

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggingConfig.init();
  await initDI();

  // add-next-line
  runApp(const ProviderScope(child: MainApp()));
}
```

</TabItem>
</Tabs>
