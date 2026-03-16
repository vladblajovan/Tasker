import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/models/task_model.dart';
import 'package:test_app/domain/entities/priority.dart';
import 'package:test_app/domain/entities/task.dart';

void main() {
  group('TaskModel', () {
    test('toEntity and fromEntity round-trip preserves all fields', () {
      final task = Task(
        id: 'task-1',
        title: 'Test Task',
        description: 'A description',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
        dueDate: DateTime(2026, 2, 1),
        priority: Priority.high,
        categoryId: 'cat-1',
        tags: const ['tag-1', 'tag-2'],
        parentTaskId: 'parent-1',
        recurrence: null,
        completedAt: null,
      );

      final model = TaskModel.fromEntity(task);
      final result = model.toEntity();

      expect(result.id, task.id);
      expect(result.title, task.title);
      expect(result.description, task.description);
      expect(result.isCompleted, task.isCompleted);
      expect(result.createdAt, task.createdAt);
      expect(result.updatedAt, task.updatedAt);
      expect(result.dueDate, task.dueDate);
      expect(result.priority, task.priority);
      expect(result.categoryId, task.categoryId);
      expect(result.tags, task.tags);
      expect(result.parentTaskId, task.parentTaskId);
    });
  });
}
