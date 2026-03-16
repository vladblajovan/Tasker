import 'package:test_app/core/error/failures.dart';
import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/domain/repositories/task_repository.dart';

class UpdateTask {
  UpdateTask(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<void> call(Task task) async {
    if (task.title.trim().isEmpty) {
      throw const ValidationFailure('Task title cannot be empty');
    }

    await _taskRepository.updateTask(task);
  }
}
