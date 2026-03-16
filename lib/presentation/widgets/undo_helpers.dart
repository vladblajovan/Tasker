import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/presentation/blocs/task/task_bloc.dart';
import 'package:tasker/presentation/blocs/task/task_event.dart';

class UndoHelpers {
  static void showUndoToggleSnackBar(BuildContext context, Task task) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          task.isCompleted ? 'Task marked incomplete' : 'Task completed',
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            context.read<TaskBloc>().add(ToggleTaskEvent(task.id));
          },
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showUndoDeleteSnackBar(BuildContext context, Task task) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Because our repository uses upsert essentially for 'put' operations in Hive,
            // dispatching CreateTaskEvent will restore the deleted task using its original ID.
            context.read<TaskBloc>().add(CreateTaskEvent(task));
          },
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
