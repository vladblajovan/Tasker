import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasker/presentation/blocs/category/category_bloc.dart';
import 'package:tasker/presentation/blocs/category/category_event.dart';
import 'package:tasker/presentation/blocs/category/category_state.dart';
import 'package:tasker/presentation/blocs/notification/notification_bloc.dart';
import 'package:tasker/presentation/blocs/notification/notification_state.dart';
import 'package:tasker/presentation/blocs/tag/tag_bloc.dart';
import 'package:tasker/presentation/blocs/tag/tag_event.dart';
import 'package:tasker/presentation/blocs/tag/tag_state.dart';
import 'package:tasker/presentation/blocs/task/task_bloc.dart';
import 'package:tasker/presentation/blocs/task/task_event.dart';
import 'package:tasker/presentation/blocs/task/task_state.dart';
import 'package:tasker/presentation/blocs/theme/theme_cubit.dart';
import 'package:tasker/presentation/pages/category/category_management_page.dart';
import 'package:tasker/presentation/pages/tag/tag_management_page.dart';
import 'package:tasker/presentation/widgets/filter_bar.dart';
import 'package:tasker/presentation/widgets/empty_state.dart';
import 'package:tasker/presentation/widgets/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasks());
    context.read<CategoryBloc>().add(const LoadCategories());
    context.read<TagBloc>().add(const LoadTags());
  }

  String get _appBarTitle => switch (_currentIndex) {
    0 => 'Tasks',
    1 => 'Categories',
    2 => 'Tags',
    _ => 'Tasks',
  };

  Widget _buildTaskList() {
    return Column(
      children: [
        const FilterBar(),
        Expanded(
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TaskError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              if (state is TaskLoaded) {
                final topLevelTasks = state.filteredTasks
                    .where((t) => t.parentTaskId == null)
                    .toList();
                if (topLevelTasks.isEmpty) {
                  return const EmptyState(
                    icon: Icons.checklist,
                    title: 'No tasks yet',
                    subtitle: 'Tap + to create your first task',
                  );
                }
                return ReorderableListView.builder(
                  itemCount: topLevelTasks.length,
                  onReorder: (oldIndex, newIndex) {
                    context.read<TaskBloc>().add(
                      ReorderTasksEvent(oldIndex, newIndex),
                    );
                  },
                  itemBuilder: (context, index) {
                    final task = topLevelTasks[index];
                    final subtaskCount = state.allTasks
                        .where((t) => t.parentTaskId == task.id)
                        .length;
                    return TaskTile(
                      key: ValueKey('task-${task.id}'),
                      task: task,
                      subtaskCount: subtaskCount,
                      onTap: () => context.push('/task/${task.id}'),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return switch (_currentIndex) {
      0 => _buildTaskList(),
      1 => const CategoryManagementPage(),
      2 => const TagManagementPage(),
      _ => _buildTaskList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryLoaded) {
              context.read<TaskBloc>().add(const LoadTasks());
            }
          },
        ),
        BlocListener<TagBloc, TagState>(
          listener: (context, state) {
            if (state is TagLoaded) {
              context.read<TaskBloc>().add(const LoadTasks());
            }
          },
        ),
        BlocListener<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationNavigate) {
              context.push('/task/${state.taskId}');
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitle),
          actions: [
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDark =
                    themeMode == ThemeMode.dark ||
                    (themeMode == ThemeMode.system &&
                        MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark);
                return IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  tooltip: 'Toggle Theme',
                  onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                );
              },
            ),
            if (_currentIndex == 0) ...[
              IconButton(
                icon: const Icon(Icons.pie_chart),
                tooltip: 'Dashboard',
                onPressed: () => context.push('/dashboard'),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.push('/search'),
              ),
            ],
            if (_currentIndex == 1)
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Category',
                onPressed: () => CategoryManagementPage.showAddDialog(context),
              ),
            if (_currentIndex == 2)
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Tag',
                onPressed: () => TagManagementPage.showAddDialog(context),
              ),
          ],
        ),
        body: _buildBody(),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: () => context.push('/task/new'),
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.checklist), label: 'Tasks'),
            NavigationDestination(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
            NavigationDestination(icon: Icon(Icons.label), label: 'Tags'),
          ],
        ),
      ),
    );
  }
}
