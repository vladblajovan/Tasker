import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tasker/domain/entities/category.dart';
import 'package:tasker/domain/entities/recurrence.dart';
import 'package:tasker/domain/entities/tag.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/presentation/blocs/category/category_bloc.dart';
import 'package:tasker/presentation/blocs/category/category_state.dart';
import 'package:tasker/presentation/blocs/tag/tag_bloc.dart';
import 'package:tasker/presentation/blocs/tag/tag_state.dart';
import 'package:tasker/presentation/blocs/task/task_bloc.dart';
import 'package:tasker/presentation/blocs/task/task_event.dart';
import 'package:tasker/presentation/blocs/task/task_state.dart';
import 'package:tasker/presentation/widgets/category_chip.dart';
import 'package:tasker/presentation/widgets/priority_badge.dart';
import 'package:tasker/presentation/widgets/tag_chip.dart';
import 'package:tasker/presentation/widgets/task_tile.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadSubtasks(widget.taskId));
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
      context.pop();
    }
  }

  Widget _buildRecurrenceInfo(Recurrence recurrence) {
    final typeLabel = switch (recurrence.type) {
      RecurrenceType.daily => 'Daily',
      RecurrenceType.weekly => 'Weekly',
      RecurrenceType.monthly => 'Monthly',
      RecurrenceType.custom => 'Custom',
    };

    final intervalLabel = recurrence.interval == 1
        ? typeLabel
        : 'Every ${recurrence.interval} ${typeLabel.toLowerCase()}s';

    String label = intervalLabel;
    if (recurrence.endDate != null) {
      label += ' until ${DateFormat.yMMMd().format(recurrence.endDate!)}';
    }

    return Row(
      children: [
        const Icon(Icons.repeat, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildDetailBody(
    BuildContext context,
    Task task,
    List<Task> subtasks,
    List<Category> categories,
    List<Tag> tags,
  ) {
    final category = categories
        .where((c) => c.id == task.categoryId)
        .firstOrNull;
    final taskTags = tags.where((t) => task.tags.contains(t.id)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title row with priority badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.isCompleted ? Colors.grey : null,
                ),
              ),
            ),
            if (task.priority.name != 'none') ...[
              const SizedBox(width: 8),
              PriorityBadge(priority: task.priority),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Description
        if (task.description != null && task.description!.isNotEmpty) ...[
          Text(
            task.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
        ],

        // Category chip
        if (category != null) ...[
          Row(
            children: [
              const Text(
                'Category: ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              CategoryChip(category: category),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Tag chips
        if (taskTags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              const Text(
                'Tags: ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              ...taskTags.map((t) => TagChip(tag: t)),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Due date
        if (task.dueDate != null) ...[
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Due: ${DateFormat.yMMMd().format(task.dueDate!)}',
                style: TextStyle(
                  color:
                      task.dueDate!.isBefore(DateTime.now()) &&
                          !task.isCompleted
                      ? Colors.red
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Recurrence
        if (task.recurrence != null) ...[
          _buildRecurrenceInfo(task.recurrence!),
          const SizedBox(height: 8),
        ],

        const Divider(height: 32),

        // Subtasks section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtasks (${subtasks.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: () =>
                  context.push('/task/${widget.taskId}/subtask/new'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),

        if (subtasks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No subtasks yet.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...subtasks.map(
            (subtask) => TaskTile(
              task: subtask,
              onTap: () => context.push('/task/${subtask.id}'),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        // Try to find task from bloc state
        Task? task;
        List<Task> subtasks = [];

        if (state is TaskLoaded) {
          task = state.allTasks.where((t) => t.id == widget.taskId).firstOrNull;
          subtasks = state.allTasks
              .where((t) => t.parentTaskId == widget.taskId)
              .toList();
        }

        if (state is TaskLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Detail')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (task == null) {
          // Reload tasks if not found (e.g., after subtask load cleared allTasks)
          // Then try TaskBloc allTasks
          return Scaffold(
            appBar: AppBar(title: const Text('Task Detail')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Task not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TaskBloc>().add(const LoadTasks());
                    },
                    child: const Text('Reload'),
                  ),
                ],
              ),
            ),
          );
        }

        final resolvedTask = task;
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, categoryState) {
            final categories = categoryState is CategoryLoaded
                ? categoryState.categories
                : <Category>[];

            return BlocBuilder<TagBloc, TagState>(
              builder: (context, tagState) {
                final tags = tagState is TagLoaded ? tagState.tags : <Tag>[];

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Task Detail'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit',
                        onPressed: () =>
                            context.push('/task/${widget.taskId}/edit'),
                      ),
                      IconButton(
                        icon: Icon(
                          resolvedTask.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: resolvedTask.isCompleted ? Colors.green : null,
                        ),
                        tooltip: resolvedTask.isCompleted
                            ? 'Mark incomplete'
                            : 'Mark complete',
                        onPressed: () {
                          context.read<TaskBloc>().add(
                            ToggleTaskEvent(widget.taskId),
                          );
                          context.read<TaskBloc>().add(const LoadTasks());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDelete(context, resolvedTask),
                      ),
                    ],
                  ),
                  body: _buildDetailBody(
                    context,
                    resolvedTask,
                    subtasks,
                    categories,
                    tags,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
