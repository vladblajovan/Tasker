import 'package:tasker/core/error/failures.dart';
import 'package:tasker/domain/entities/recurrence.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/notification_repository.dart';
import 'package:tasker/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

class ToggleTask {
  ToggleTask(this._taskRepository, this._notificationRepository);

  final TaskRepository _taskRepository;
  final NotificationRepository _notificationRepository;
  final _uuid = const Uuid();

  Future<Task> call(
    String taskId, {
    DateTime? now,
    bool shouldCompleteSubtasks = true,
    bool shouldCompleteParent = true,
  }) async {
    final currentTime = now ?? DateTime.now();

    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw NotFoundFailure('Task with id $taskId not found');
    }

    if (task.isCompleted) {
      return await _uncompleteTask(task, currentTime);
    } else {
      return await _completeTask(
        task,
        currentTime,
        shouldCompleteSubtasks: shouldCompleteSubtasks,
        shouldCompleteParent: shouldCompleteParent,
      );
    }
  }

  Future<Task> _uncompleteTask(Task task, DateTime currentTime) async {
    final updatedTask = task.copyWith(
      isCompleted: false,
      completedAt: null,
      updatedAt: currentTime,
    );
    await _taskRepository.updateTask(updatedTask);

    if (updatedTask.dueDate != null) {
      await _notificationRepository.scheduleNotification(updatedTask);
    }

    // If it's a subtask, we should also uncomplete the parent
    if (updatedTask.parentTaskId != null) {
      final parentTask =
          await _taskRepository.getTaskById(updatedTask.parentTaskId!);
      if (parentTask != null && parentTask.isCompleted) {
        await _uncompleteTask(parentTask, currentTime);
      }
    }

    return updatedTask;
  }

  Future<Task> _completeTask(
    Task task,
    DateTime currentTime, {
    required bool shouldCompleteSubtasks,
    required bool shouldCompleteParent,
  }) async {
    final completedTask = task.copyWith(
      isCompleted: true,
      completedAt: currentTime,
      updatedAt: currentTime,
    );
    await _taskRepository.updateTask(completedTask);
    await _notificationRepository.cancelNotification(task.id);

    // 1. Complete all subtasks if requested
    if (shouldCompleteSubtasks) {
      final subtasks = await _taskRepository.getTasksByParentId(task.id);
      for (final subtask in subtasks) {
        if (!subtask.isCompleted) {
          await _completeTask(
            subtask,
            currentTime,
            shouldCompleteSubtasks: true,
            shouldCompleteParent: false, // Don't trigger parent logic recursively
          );
        }
      }
    }

    // 2. If it's a subtask, check if we should complete the parent
    if (shouldCompleteParent && task.parentTaskId != null) {
      final siblings =
          await _taskRepository.getTasksByParentId(task.parentTaskId!);
      final allCompleted = siblings.every((s) => s.isCompleted);
      if (allCompleted) {
        final parentTask =
            await _taskRepository.getTaskById(task.parentTaskId!);
        if (parentTask != null && !parentTask.isCompleted) {
          await _completeTask(
            parentTask,
            currentTime,
            shouldCompleteSubtasks: false, // Don't re-complete subtasks
            shouldCompleteParent: true, // Allow cascading up if needed
          );
        }
      }
    }

    // Handle recurring task: create next occurrence
    if (task.recurrence != null && task.dueDate != null) {
      final nextDueDate = _calculateNextDueDate(
        task.dueDate!,
        task.recurrence!,
      );

      if (nextDueDate != null) {
        final shouldCreate = task.recurrence!.endDate == null ||
            nextDueDate.isBefore(task.recurrence!.endDate!) ||
            nextDueDate.isAtSameMomentAs(task.recurrence!.endDate!);

        if (shouldCreate) {
          final nextTask = Task(
            id: _uuid.v4(),
            title: task.title,
            description: task.description,
            isCompleted: false,
            createdAt: currentTime,
            updatedAt: currentTime,
            dueDate: nextDueDate,
            priority: task.priority,
            categoryId: task.categoryId,
            tags: task.tags,
            parentTaskId: task.parentTaskId,
            recurrence: task.recurrence,
          );

          await _taskRepository.createTask(nextTask);
          await _notificationRepository.scheduleNotification(nextTask);
        }
      }
    }

    return completedTask;
  }

  DateTime? _calculateNextDueDate(
    DateTime currentDueDate,
    Recurrence recurrence,
  ) {
    switch (recurrence.type) {
      case RecurrenceType.daily:
        return currentDueDate.add(Duration(days: recurrence.interval));

      case RecurrenceType.weekly:
        return currentDueDate.add(Duration(days: 7 * recurrence.interval));

      case RecurrenceType.monthly:
        return DateTime(
          currentDueDate.year,
          currentDueDate.month + recurrence.interval,
          currentDueDate.day,
          currentDueDate.hour,
          currentDueDate.minute,
        );

      case RecurrenceType.custom:
        return _calculateNextCustomDueDate(currentDueDate, recurrence);
    }
  }

  DateTime? _calculateNextCustomDueDate(
    DateTime currentDueDate,
    Recurrence recurrence,
  ) {
    if (recurrence.weekdays == null || recurrence.weekdays!.isEmpty) {
      return null;
    }

    final sortedWeekdays = List<int>.from(recurrence.weekdays!)..sort();
    final currentWeekday = currentDueDate.weekday;

    // Find the next weekday in the current cycle
    for (final weekday in sortedWeekdays) {
      if (weekday > currentWeekday) {
        final daysUntil = weekday - currentWeekday;
        return currentDueDate.add(Duration(days: daysUntil));
      }
    }

    // No more weekdays this cycle — jump to the first weekday of the next cycle
    final daysUntilNextMonday = 8 - currentWeekday; // days until next Monday
    final nextCycleStart = currentDueDate.add(
      Duration(days: daysUntilNextMonday + (recurrence.interval - 1) * 7),
    );

    // Find the first matching weekday in the next cycle
    final firstWeekday = sortedWeekdays.first;
    final daysToAdd = firstWeekday - nextCycleStart.weekday;
    return nextCycleStart.add(
      Duration(days: daysToAdd >= 0 ? daysToAdd : daysToAdd + 7),
    );
  }
}
