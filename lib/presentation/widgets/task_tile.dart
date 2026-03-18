import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
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
import 'package:tasker/presentation/widgets/undo_helpers.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    this.subtaskCount = 0,
    this.onTap,
  });

  final Task task;
  final int subtaskCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
              UndoHelpers.showUndoDeleteSnackBar(context, task);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => _handleToggle(context, value ?? false),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: _buildSubtitle(context),
        trailing: PriorityBadge(priority: task.priority),
      ),
    );
  }

  Future<void> _handleToggle(BuildContext context, bool isChecked) async {
    final taskBloc = context.read<TaskBloc>();
    final taskState = taskBloc.state;

    if (taskState is! TaskLoaded) return;

    if (isChecked) {
      // 1. Check for subtasks if this is a parent task
      final subtasks =
          taskState.allTasks.where((t) => t.parentTaskId == task.id).toList();
      final incompleteSubtasks = subtasks.where((s) => !s.isCompleted).toList();

      bool shouldCompleteSubtasks = true;
      if (incompleteSubtasks.isNotEmpty) {
        final result = await _showConfirmationDialog(
          context,
          title: 'Complete Subtasks?',
          content:
              'This task has ${incompleteSubtasks.length} incomplete subtasks. Do you want to complete them as well?',
          confirmLabel: 'Complete All',
          cancelLabel: 'Only Main Task',
        );
        if (result == null) return; // User cancelled the toggle entirely
        shouldCompleteSubtasks = result;
      }

      // 2. Check if this is the last subtask being completed
      bool shouldCompleteParent = true;
      if (task.parentTaskId != null) {
        final parent =
            taskState.allTasks.where((t) => t.id == task.parentTaskId).firstOrNull;
        if (parent != null && !parent.isCompleted) {
          final siblings = taskState.allTasks
              .where((t) => t.parentTaskId == task.parentTaskId && t.id != task.id)
              .toList();
          final allSiblingsCompleted = siblings.every((s) => s.isCompleted);

          if (allSiblingsCompleted) {
            final result = await _showConfirmationDialog(
              context,
              title: 'Complete Main Task?',
              content:
                  'All subtasks are now completed. Do you want to complete the main task "${parent.title}" too?',
              confirmLabel: 'Complete Main Task',
              cancelLabel: 'Keep Main Incomplete',
            );
            if (result == null) return;
            shouldCompleteParent = result;
          }
        }
      }

      taskBloc.add(
        ToggleTaskEvent(
          task.id,
          shouldCompleteSubtasks: shouldCompleteSubtasks,
          shouldCompleteParent: shouldCompleteParent,
        ),
      );
    } else {
      // Uncompleting - usually we just do it, but we follow the same pattern
      taskBloc.add(ToggleTaskEvent(task.id));
    }

    if (context.mounted) {
      UndoHelpers.showUndoToggleSnackBar(context, task);
    }
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    required String cancelLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelLabel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final parts = <Widget>[];

    if (task.dueDate != null) {
      final formatted = DateFormat.yMMMd().format(task.dueDate!);
      final isOverdue =
          task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted;
      parts.add(
        Text(
          formatted,
          style: TextStyle(
            fontSize: 12,
            color: isOverdue ? Colors.red : Colors.grey[600],
          ),
        ),
      );
    }

    if (task.categoryId != null) {
      final categoryState = context.read<CategoryBloc>().state;
      if (categoryState is CategoryLoaded) {
        final category = categoryState.categories
            .where((c) => c.id == task.categoryId)
            .firstOrNull;
        if (category != null) {
          parts.add(CategoryChip(category: category));
        }
      }
    }

    if (task.tags.isNotEmpty) {
      final tagState = context.read<TagBloc>().state;
      if (tagState is TagLoaded) {
        for (final tagId in task.tags) {
          final tag = tagState.tags.where((t) => t.id == tagId).firstOrNull;
          if (tag != null) {
            parts.add(TagChip(tag: tag));
          }
        }
      }
    }

    if (subtaskCount > 0) {
      parts.add(
        Text(
          '$subtaskCount subtask${subtaskCount == 1 ? '' : 's'}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      );
    }

    if (task.recurrence != null) {
      parts.add(Icon(Icons.repeat, size: 14, color: Colors.grey[600]));
    }

    if (parts.isEmpty) return null;

    return Wrap(spacing: 4, runSpacing: 4, children: parts);
  }
}
