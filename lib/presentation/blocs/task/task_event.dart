import 'package:equatable/equatable.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}

class CreateTaskEvent extends TaskEvent {
  const CreateTaskEvent(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  const UpdateTaskEvent(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  const DeleteTaskEvent(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class ToggleTaskEvent extends TaskEvent {
  const ToggleTaskEvent(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class FilterTasks extends TaskEvent {
  const FilterTasks({this.categoryId, this.tagIds = const [], this.priority});

  final String? categoryId;
  final List<String> tagIds;
  final Priority? priority;

  @override
  List<Object?> get props => [categoryId, tagIds, priority];
}

class SortTasks extends TaskEvent {
  const SortTasks(this.sortBy, this.ascending);

  final String sortBy;
  final bool ascending;

  @override
  List<Object?> get props => [sortBy, ascending];
}

class LoadSubtasks extends TaskEvent {
  const LoadSubtasks(this.parentTaskId);

  final String parentTaskId;

  @override
  List<Object?> get props => [parentTaskId];
}

class ReorderTasksEvent extends TaskEvent {
  const ReorderTasksEvent(this.oldIndex, this.newIndex);

  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [oldIndex, newIndex];
}
