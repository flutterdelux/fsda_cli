
<Tabs groupId="wire-navigation">
  <TabItem value="ManagementRoute" label="ManagementRoute" default>

```dart title="ManagementRoute"
...
abstract final class ManagementRoute {
  static const _taskUpdate = 'task-update';
  static const _taskCreate = 'task-create';
  static const _taskDetail = 'task-detail';
  static const _taskList = 'task-list';
  // remove-next-line
  static const _task = 'task';
...

  // add-start
  static RouteBase get taskBase => GoRoute(
    path: '/tasks',
    name: _taskList,
    builder: (context, state) => const TaskListPage(),
    routes: [
      GoRoute(
        path: 'create',
        name: _taskCreate,
        builder: (context, state) {
          return const TaskCreatePage();
        },
      ),
      GoRoute(
        path: ':id',
        name: _taskDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'].toString());
          if (id == null) return const NotFoundPage();
          return TaskDetailPage(id: id);
        },
        routes: [
          GoRoute(
            path: 'update',
            name: _taskUpdate,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'].toString());
              if (id == null) return const NotFoundPage();
              return TaskUpdatePage(id: id);
            },
          ),
        ],
      ),
    ],
  );
  // add-end

  ...

  static Future<dynamic> toTaskUpdate(
    BuildContext context, {
    required int id,
    // remove-start
    required String title,
    required String description,
    // remove-end
  }) {
    return context.pushNamed(
      _taskUpdate,
      pathParameters: {
        'id': '$id',
        // remove-start
        'title': '$title',
        'description': '$description',
        // remove-end
      },
    );
  }

}
```

</TabItem>
<TabItem value="DashboardRoute" label="DashboardRoute">

```dart title="DashboardRoute"
  ...
// add-next-line
import '../../modules/management/management_route.dart';
...

class DashboardRoute {
  ...
  static RouteBase get base => StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return Dashboard(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          // remove-start
          GoRoute(
            name: home,
            path: homePath,
            builder: (context, state) => const HomePage(),
          ),
          // remove-end
          // add-next-line
          ManagementRoute.taskBase,
        ],
      ),
  ...
  
  static void toHome(BuildContext context) {
    // remove-next-line
    context.goNamed(home);
    // add-next-line
    ManagementRoute.toTaskList(context);
  }

  ...
}
```

</TabItem>
<TabItem value="TaskListpage" label="TaskListpage">

```dart title="TaskListpage"
...
// add-next-line
import '../../../management_route.dart';

...

        return Scaffold(
          appBar: AppBar(title: Text(managementL10n.taskListTitle)),
          body: _buildContent(context),
          // add-start
          floatingActionButton: FloatingActionButton(
            onPressed: () {              
              ManagementRoute.toTaskCreate(context).then((value) {
                if (value == 'refresh') _getTaskList();
              });              
            },
            child: const Icon(Icons.add),
          ),
          // add-end
        );

        ...

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<TaskListCubit, TaskListState>(
      builder: (_, state) => state.maybeWhen(
        orElse: () => const TaskListSkeleton(itemCount: 10),
        failure: (failure) => TaskListErrorFeedback(
          message: failure.localizeAny(context),
          onRetry: () => _getTaskList(context),
        ),
        loaded: (data) => TaskListContent(
          data: data,
          onItemTap: (item) {
            // add-start
            ManagementRoute.toTaskDetail(context, id: item.id).then((value) {
              if (value == 'refresh') _getTaskList();
            });
            // add-end
          },
        ),
      ),
    );
  }

```


</TabItem>
<TabItem value="TaskDetailPage" label="TaskDetailPage">

```dart title="TaskDetailPage"
...
// add-start
import '../../../management_route.dart';
import '../widgets/task_delete_dialog.dart';
import '../widgets/task_status_update_dialog.dart';
// add-end
...

  Widget _buildContent(BuildContext context) {
    return Obx(
      () => _taskDetailController.state.maybeWhen(
        orElse: () => const AppLoading(),
        failure: (failure) => TaskDetailErrorFeedback(
          message: failure.localizeAny(context),
          onRetry: _getTaskDetail,
        ),
        // add-start
        loaded: (data) => Column(
          children: [
            TaskDetailContent(data: data),
            AppGap.md,
            _buildAction(),
          ],
        ),
        // add-end
      ),
    );
  }

  // add-start
  Widget _buildAction(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final appL10n = AppLocalizations.of(context)!;
    final managementL10n = ManagementLocalizations.of(context)!;
    return AppSection(
      header: AppSectionHeader(titleText: appL10n.action),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: AppCard(
        children: [
          AppActionTile(
            title: appL10n.update,
            leadingIcon: const Icon(Icons.edit),
            onTap: () {
              ManagementRoute.toTaskUpdate(context, id: id).then((value) {
                if (value == 'refresh') _getTaskDetail(context);
              });
            },
          ),
          AppActionTile(
            title: managementL10n.taskStatus,
            leadingIcon: const Icon(Icons.edit),
            onTap: () {
              TaskStatusUpdateDialog(id: id).show(context).then((value) {
                if (value == 'refresh') _getTaskDetail(context);
              });
            },
          ),
          AppActionTile(
            title: appL10n.delete,
            leadingIcon: Icon(Icons.delete, color: colorScheme.error),
            isDestructive: true,
            onTap: () {
              TaskDeleteDialog(id: id).show(context).then((value) {
                if (value == 'refresh') _getTaskDetail(context);
              });
            },
          ),
        ],
      ),
    );
  }
  // add-end
...
```

</TabItem>
</Tabs>