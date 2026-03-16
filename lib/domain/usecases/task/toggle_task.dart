import 'package:test_app/core/error/failures.dart';
import 'package:test_app/domain/entities/recurrence.dart';
import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/domain/repositories/notification_repository.dart';
import 'package:test_app/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

class ToggleTask {
  ToggleTask(this._taskRepository, this._notificationRepository);

  final TaskRepository _taskRepository;
  final NotificationRepository _notificationRepository;
  final _uuid = const Uuid();

  Future<Task> call(String taskId, {DateTime? now}) async {
    final currentTime = now ?? DateTime.now();

    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw NotFoundFailure('Task with id $taskId not found');
    }

    if (task.isCompleted) {
      // Uncompleting a task
      final updatedTask = task.copyWith(
        isCompleted: false,
        completedAt: null,
        updatedAt: currentTime,
      );
      await _taskRepository.updateTask(updatedTask);

      if (updatedTask.dueDate != null) {
        await _notificationRepository.scheduleNotification(updatedTask);
      }

      return updatedTask;
    }

    // Completing a task
    final completedTask = task.copyWith(
      isCompleted: true,
      completedAt: currentTime,
      updatedAt: currentTime,
    );
    await _taskRepository.updateTask(completedTask);
    await _notificationRepository.cancelNotification(taskId);

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
