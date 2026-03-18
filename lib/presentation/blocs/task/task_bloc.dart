import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/usecases/task/create_task.dart';
import 'package:tasker/domain/usecases/task/delete_task.dart';
import 'package:tasker/domain/usecases/task/get_subtasks.dart';
import 'package:tasker/domain/usecases/task/get_tasks.dart';
import 'package:tasker/domain/usecases/task/search_tasks.dart';
import 'package:tasker/domain/usecases/task/toggle_task.dart';
import 'package:tasker/domain/usecases/task/update_task.dart';
import 'package:tasker/presentation/blocs/task/task_event.dart';
import 'package:tasker/presentation/blocs/task/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required GetTasks getTasks,
    required CreateTask createTask,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
    required ToggleTask toggleTask,
    required SearchTasks searchTasks,
    required GetSubtasks getSubtasks,
  }) : _getTasks = getTasks,
       _createTask = createTask,
       _updateTask = updateTask,
       _deleteTask = deleteTask,
       _toggleTask = toggleTask,
       _searchTasks = searchTasks,
       _getSubtasks = getSubtasks,
       super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskEvent>(_onToggleTask);
    on<FilterTasks>(_onFilterTasks);
    on<SortTasks>(_onSortTasks);
    on<LoadSubtasks>(_onLoadSubtasks);
    on<ReorderTasksEvent>(_onReorderTasks);
  }

  final GetTasks _getTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final ToggleTask _toggleTask;
  // ignore: unused_field
  final SearchTasks _searchTasks;
  // ignore: unused_field
  final GetSubtasks _getSubtasks;

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(const TaskLoading());
    try {
      final allTasks = await _getTasks();
      final topLevelTasks =
          allTasks.where((t) => t.parentTaskId == null).toList();
      final sorted = _applyDefaultSort(topLevelTasks);
      emit(TaskLoaded(allTasks: allTasks, filteredTasks: sorted));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _createTask(event.task);
      add(const LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _updateTask(event.task);
      add(const LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _deleteTask(event.id);
      add(const LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onToggleTask(
    ToggleTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _toggleTask(
        event.id,
        shouldCompleteSubtasks: event.shouldCompleteSubtasks,
        shouldCompleteParent: event.shouldCompleteParent,
      );
      add(const LoadTasks());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onFilterTasks(
    FilterTasks event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    final filtered = _applyFilters(
      currentState.allTasks,
      categoryId: event.categoryId,
      tagIds: event.tagIds,
      priority: event.priority,
    );

    emit(
      currentState.copyWith(
        filteredTasks: filtered,
        filterCategoryId: event.categoryId,
        clearCategoryId: event.categoryId == null,
        filterTagIds: event.tagIds,
        filterPriority: event.priority,
        clearPriority: event.priority == null,
      ),
    );
  }

  Future<void> _onSortTasks(SortTasks event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    final sorted = _applySortBy(
      List<Task>.from(currentState.filteredTasks),
      event.sortBy,
      event.ascending,
    );

    emit(currentState.copyWith(filteredTasks: sorted));
  }

  Future<void> _onLoadSubtasks(
    LoadSubtasks event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      return;
    }
    add(const LoadTasks());
  }

  Future<void> _onReorderTasks(
    ReorderTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    final visibleTasks = List<Task>.from(currentState.filteredTasks);

    final int oldIndex = event.oldIndex;
    int newIndex = event.newIndex;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final Task item = visibleTasks.removeAt(oldIndex);
    visibleTasks.insert(newIndex, item);

    final updatedTasks = <Task>[];
    for (int i = 0; i < visibleTasks.length; i++) {
      final updatedTask = visibleTasks[i].copyWith(orderIndex: i);
      updatedTasks.add(updatedTask);

      if (visibleTasks[i].orderIndex != i) {
        await _updateTask(updatedTask);
      }
    }

    final newAllTasks = List<Task>.from(currentState.allTasks);
    for (final updated in updatedTasks) {
      final idx = newAllTasks.indexWhere((t) => t.id == updated.id);
      if (idx != -1) {
        newAllTasks[idx] = updated;
      }
    }

    emit(currentState.copyWith(allTasks: newAllTasks, filteredTasks: visibleTasks));
  }

  List<Task> _applyDefaultSort(List<Task> tasks) {
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      if (a.dueDate != b.dueDate) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        final dueCmp = a.dueDate!.compareTo(b.dueDate!);
        if (dueCmp != 0) return dueCmp;
      }

      return a.orderIndex.compareTo(b.orderIndex);
    });
    return sorted;
  }

  List<Task> _applySortBy(List<Task> tasks, String sortBy, bool ascending) {
    tasks.sort((a, b) {
      int cmp;
      switch (sortBy) {
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) {
            cmp = 0;
          } else if (a.dueDate == null) {
            cmp = 1;
          } else if (b.dueDate == null) {
            cmp = -1;
          } else {
            cmp = a.dueDate!.compareTo(b.dueDate!);
          }
        case 'priority':
          cmp = _priorityOrder(b.priority).compareTo(_priorityOrder(a.priority));
        case 'title':
          cmp = a.title.compareTo(b.title);
        case 'createdAt':
          cmp = a.createdAt.compareTo(b.createdAt);
        default:
          cmp = 0;
      }
      return ascending ? cmp : -cmp;
    });
    return tasks;
  }

  int _priorityOrder(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 3;
      case Priority.medium:
        return 2;
      case Priority.low:
        return 1;
      case Priority.none:
        return 0;
    }
  }

  List<Task> _applyFilters(
    List<Task> tasks, {
    String? categoryId,
    List<String> tagIds = const [],
    Priority? priority,
  }) {
    return tasks.where((task) {
      if (categoryId != null && task.categoryId != categoryId) return false;
      if (tagIds.isNotEmpty && !tagIds.any((id) => task.tags.contains(id))) {
        return false;
      }
      if (priority != null && task.priority != priority) return false;
      return true;
    }).toList();
  }
}
