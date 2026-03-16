import 'package:test_app/domain/repositories/task_repository.dart';

class DeleteTask {
  DeleteTask(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<void> call(String taskId) async {
    final subtasks = await _taskRepository.getTasksByParentId(taskId);
    for (final subtask in subtasks) {
      await _taskRepository.deleteTask(subtask.id);
    }
    await _taskRepository.deleteTask(taskId);
  }
}
