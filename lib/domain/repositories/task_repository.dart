import 'package:test_app/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<List<Task>> getTasksByParentId(String parentTaskId);
  Future<List<Task>> getTasksByCategoryId(String categoryId);
  Future<List<Task>> getTasksByTagId(String tagId);
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<List<Task>> searchTasks(String query);
}
