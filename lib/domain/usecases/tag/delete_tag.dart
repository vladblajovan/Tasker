import 'package:test_app/domain/repositories/tag_repository.dart';
import 'package:test_app/domain/repositories/task_repository.dart';

class DeleteTag {
  DeleteTag(this._tagRepository, this._taskRepository);

  final TagRepository _tagRepository;
  final TaskRepository _taskRepository;

  Future<void> call(String tagId) async {
    final affectedTasks = await _taskRepository.getTasksByTagId(tagId);

    for (final task in affectedTasks) {
      final updatedTags = List<String>.from(task.tags)..remove(tagId);
      final updatedTask = task.copyWith(tags: updatedTags);
      await _taskRepository.updateTask(updatedTask);
    }

    await _tagRepository.deleteTag(tagId);
  }
}
