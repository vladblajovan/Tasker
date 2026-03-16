import 'package:flutter_test/flutter_test.dart';
import 'package:tasker/data/datasources/remote/task_remote_datasource.dart';
import 'package:tasker/data/models/recurrence_model.dart';
import 'package:tasker/data/models/task_model.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/recurrence.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  final tTaskModel = TaskModel(
    id: 'task-1',
    title: 'Test Task',
    description: 'A test task',
    isCompleted: false,
    createdAt: now,
    updatedAt: now,
    priority: Priority.medium,
    tags: ['tag-1'],
  );

  group('toSupabaseRow / fromSupabaseRow', () {
    test('round-trips a TaskModel correctly', () {
      final row = TaskRemoteDatasourceImpl.toSupabaseRow(tTaskModel);
      final result = TaskRemoteDatasourceImpl.fromSupabaseRow(row);

      expect(result.id, tTaskModel.id);
      expect(result.title, tTaskModel.title);
      expect(result.description, tTaskModel.description);
      expect(result.isCompleted, tTaskModel.isCompleted);
      expect(result.priority, tTaskModel.priority);
      expect(result.tags, tTaskModel.tags);
      expect(result.recurrence, isNull);
    });

    test('round-trips a TaskModel with recurrence', () {
      final taskWithRecurrence = TaskModel(
        id: 'task-2',
        title: 'Recurring',
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
        priority: Priority.high,
        tags: [],
        recurrence: RecurrenceModel(
          type: RecurrenceType.weekly,
          interval: 2,
          weekdays: [1, 3, 5],
          endDate: DateTime(2026, 12, 31),
        ),
      );

      final row = TaskRemoteDatasourceImpl.toSupabaseRow(taskWithRecurrence);
      final result = TaskRemoteDatasourceImpl.fromSupabaseRow(row);

      expect(result.recurrence, isNotNull);
      expect(result.recurrence!.type, RecurrenceType.weekly);
      expect(result.recurrence!.interval, 2);
      expect(result.recurrence!.weekdays, [1, 3, 5]);
      expect(result.recurrence!.endDate, DateTime(2026, 12, 31));
    });
  });
}
