import 'package:test_app/core/error/failures.dart';
import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/domain/repositories/task_repository.dart';

class CreateTask {
  CreateTask(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<void> call(Task task) async {
    if (task.title.trim().isEmpty) {
      throw const ValidationFailure('Task title cannot be empty');
    }

    if (task.parentTaskId != null) {
      final parentTask = await _taskRepository.getTaskById(task.parentTaskId!);
      if (parentTask == null) {
        throw NotFoundFailure(
          'Parent task with id ${task.parentTaskId} not found',
        );
      }
      if (parentTask.parentTaskId != null) {
        throw const ValidationFailure(
          'Subtasks cannot have their own subtasks (only one level of nesting allowed)',
        );
      }
    }

    await _taskRepository.createTask(task);
  }
}
