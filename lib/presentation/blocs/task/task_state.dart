import 'package:equatable/equatable.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  const TaskLoaded({
    required this.allTasks,
    required this.filteredTasks,
    this.filterCategoryId,
    this.filterTagIds = const [],
    this.filterPriority,
  });

  final List<Task> allTasks;
  final List<Task> filteredTasks;
  final String? filterCategoryId;
  final List<String> filterTagIds;
  final Priority? filterPriority;

  @override
  List<Object?> get props => [
    allTasks,
    filteredTasks,
    filterCategoryId,
    filterTagIds,
    filterPriority,
  ];

  TaskLoaded copyWith({
    List<Task>? allTasks,
    List<Task>? filteredTasks,
    String? filterCategoryId,
    bool clearCategoryId = false,
    List<String>? filterTagIds,
    Priority? filterPriority,
    bool clearPriority = false,
  }) {
    return TaskLoaded(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      filterCategoryId: clearCategoryId
          ? null
          : (filterCategoryId ?? this.filterCategoryId),
      filterTagIds: filterTagIds ?? this.filterTagIds,
      filterPriority: clearPriority
          ? null
          : (filterPriority ?? this.filterPriority),
    );
  }
}

class TaskError extends TaskState {
  const TaskError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
