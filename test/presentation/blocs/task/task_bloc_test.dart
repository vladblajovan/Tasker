import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/usecases/task/create_task.dart';
import 'package:tasker/domain/usecases/task/delete_task.dart';
import 'package:tasker/domain/usecases/task/get_subtasks.dart';
import 'package:tasker/domain/usecases/task/get_tasks.dart';
import 'package:tasker/domain/usecases/task/search_tasks.dart';
import 'package:tasker/domain/usecases/task/toggle_task.dart';
import 'package:tasker/domain/usecases/task/update_task.dart';
import 'package:tasker/presentation/blocs/task/task_bloc.dart';
import 'package:tasker/presentation/blocs/task/task_event.dart';
import 'package:tasker/presentation/blocs/task/task_state.dart';

class MockGetTasks extends Mock implements GetTasks {}

class MockCreateTask extends Mock implements CreateTask {}

class MockUpdateTask extends Mock implements UpdateTask {}

class MockDeleteTask extends Mock implements DeleteTask {}

class MockToggleTask extends Mock implements ToggleTask {}

class MockSearchTasks extends Mock implements SearchTasks {}

class MockGetSubtasks extends Mock implements GetSubtasks {}

void main() {
  late MockGetTasks mockGetTasks;
  late MockCreateTask mockCreateTask;
  late MockUpdateTask mockUpdateTask;
  late MockDeleteTask mockDeleteTask;
  late MockToggleTask mockToggleTask;
  late MockSearchTasks mockSearchTasks;
  late MockGetSubtasks mockGetSubtasks;

  final now = DateTime(2026, 3, 14);

  final tTask = Task(
    id: 'task-1',
    title: 'Test Task',
    isCompleted: false,
    createdAt: now,
    updatedAt: now,
    priority: Priority.high,
  );

  final tTask2 = Task(
    id: 'task-2',
    title: 'Another Task',
    isCompleted: false,
    createdAt: now,
    updatedAt: now,
    priority: Priority.low,
  );

  final tSubtask = Task(
    id: 'subtask-1',
    title: 'Subtask',
    isCompleted: false,
    createdAt: now,
    updatedAt: now,
    parentTaskId: 'task-1',
  );

  TaskBloc buildBloc() => TaskBloc(
    getTasks: mockGetTasks,
    createTask: mockCreateTask,
    updateTask: mockUpdateTask,
    deleteTask: mockDeleteTask,
    toggleTask: mockToggleTask,
    searchTasks: mockSearchTasks,
    getSubtasks: mockGetSubtasks,
  );

  setUp(() {
    mockGetTasks = MockGetTasks();
    mockCreateTask = MockCreateTask();
    mockUpdateTask = MockUpdateTask();
    mockDeleteTask = MockDeleteTask();
    mockToggleTask = MockToggleTask();
    mockSearchTasks = MockSearchTasks();
    mockGetSubtasks = MockGetSubtasks();
  });

  group('TaskBloc', () {
    test('initial state is TaskInitial', () {
      expect(buildBloc().state, const TaskInitial());
    });

    group('LoadTasks', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoading, TaskLoaded] with all tasks in allTasks and top-level in filteredTasks',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetTasks(),
          ).thenAnswer((_) async => [tTask, tTask2, tSubtask]);
        },
        act: (bloc) => bloc.add(const LoadTasks()),
        expect: () => [
          const TaskLoading(),
          isA<TaskLoaded>()
              .having((s) => s.allTasks.length, 'allTasks includes subtasks', 3)
              .having(
                (s) => s.filteredTasks.length,
                'filteredTasks excludes subtasks',
                2,
              )
              .having(
                (s) => s.filteredTasks.any((t) => t.parentTaskId != null),
                'no subtasks in filteredTasks',
                false,
              ),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits TaskError when getTasks throws',
        build: buildBloc,
        setUp: () {
          when(() => mockGetTasks()).thenThrow(Exception('DB error'));
        },
        act: (bloc) => bloc.add(const LoadTasks()),
        expect: () => [const TaskLoading(), isA<TaskError>()],
      );

      blocTest<TaskBloc, TaskState>(
        'sorts tasks: incomplete first, then by priority descending',
        build: buildBloc,
        setUp: () {
          final completedTask = tTask.copyWith(isCompleted: true);
          when(
            () => mockGetTasks(),
          ).thenAnswer((_) async => [completedTask, tTask2]);
        },
        act: (bloc) => bloc.add(const LoadTasks()),
        expect: () => [
          const TaskLoading(),
          isA<TaskLoaded>().having(
            (s) => s.filteredTasks.first.isCompleted,
            'first task is incomplete',
            false,
          ),
        ],
      );
    });

    group('CreateTaskEvent', () {
      blocTest<TaskBloc, TaskState>(
        'calls createTask and reloads tasks',
        build: buildBloc,
        setUp: () {
          when(() => mockCreateTask(tTask)).thenAnswer((_) async {});
          when(() => mockGetTasks()).thenAnswer((_) async => [tTask]);
        },
        act: (bloc) => bloc.add(CreateTaskEvent(tTask)),
        expect: () => [const TaskLoading(), isA<TaskLoaded>()],
        verify: (_) {
          verify(() => mockCreateTask(tTask)).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'emits TaskError when createTask throws',
        build: buildBloc,
        setUp: () {
          when(() => mockCreateTask(tTask)).thenThrow(Exception('error'));
        },
        act: (bloc) => bloc.add(CreateTaskEvent(tTask)),
        expect: () => [isA<TaskError>()],
      );
    });

    group('UpdateTaskEvent', () {
      blocTest<TaskBloc, TaskState>(
        'calls updateTask and reloads tasks',
        build: buildBloc,
        setUp: () {
          when(() => mockUpdateTask(tTask)).thenAnswer((_) async {});
          when(() => mockGetTasks()).thenAnswer((_) async => [tTask]);
        },
        act: (bloc) => bloc.add(UpdateTaskEvent(tTask)),
        expect: () => [const TaskLoading(), isA<TaskLoaded>()],
        verify: (_) {
          verify(() => mockUpdateTask(tTask)).called(1);
        },
      );
    });

    group('DeleteTaskEvent', () {
      blocTest<TaskBloc, TaskState>(
        'calls deleteTask and reloads tasks',
        build: buildBloc,
        setUp: () {
          when(() => mockDeleteTask('task-1')).thenAnswer((_) async {});
          when(() => mockGetTasks()).thenAnswer((_) async => [tTask2]);
        },
        act: (bloc) => bloc.add(const DeleteTaskEvent('task-1')),
        expect: () => [const TaskLoading(), isA<TaskLoaded>()],
        verify: (_) {
          verify(() => mockDeleteTask('task-1')).called(1);
        },
      );
    });

    group('ToggleTaskEvent', () {
      blocTest<TaskBloc, TaskState>(
        'calls toggleTask and reloads tasks',
        build: buildBloc,
        setUp: () {
          when(
            () => mockToggleTask('task-1'),
          ).thenAnswer((_) async => tTask.copyWith(isCompleted: true));
          when(() => mockGetTasks()).thenAnswer((_) async => [tTask]);
        },
        act: (bloc) => bloc.add(const ToggleTaskEvent('task-1')),
        expect: () => [const TaskLoading(), isA<TaskLoaded>()],
        verify: (_) {
          verify(() => mockToggleTask('task-1')).called(1);
        },
      );
    });

    group('FilterTasks', () {
      blocTest<TaskBloc, TaskState>(
        'filters tasks by categoryId in-memory',
        build: buildBloc,
        seed: () => TaskLoaded(
          allTasks: [
            tTask.copyWith(categoryId: 'cat-1'),
            tTask2.copyWith(categoryId: 'cat-2'),
          ],
          filteredTasks: [
            tTask.copyWith(categoryId: 'cat-1'),
            tTask2.copyWith(categoryId: 'cat-2'),
          ],
        ),
        act: (bloc) => bloc.add(const FilterTasks(categoryId: 'cat-1')),
        expect: () => [
          isA<TaskLoaded>()
              .having((s) => s.filteredTasks.length, 'filteredTasks length', 1)
              .having(
                (s) => s.filteredTasks.first.categoryId,
                'correct category',
                'cat-1',
              )
              .having(
                (s) => s.filterCategoryId,
                'filterCategoryId set',
                'cat-1',
              ),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'filters tasks by priority in-memory',
        build: buildBloc,
        seed: () => TaskLoaded(
          allTasks: [tTask, tTask2],
          filteredTasks: [tTask, tTask2],
        ),
        act: (bloc) => bloc.add(const FilterTasks(priority: Priority.high)),
        expect: () => [
          isA<TaskLoaded>().having(
            (s) => s.filteredTasks.length,
            'filteredTasks length',
            1,
          ),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'filters tasks by tagIds in-memory',
        build: buildBloc,
        seed: () => TaskLoaded(
          allTasks: [
            tTask.copyWith(tags: ['tag-1']),
            tTask2.copyWith(tags: ['tag-2']),
          ],
          filteredTasks: [
            tTask.copyWith(tags: ['tag-1']),
            tTask2.copyWith(tags: ['tag-2']),
          ],
        ),
        act: (bloc) => bloc.add(const FilterTasks(tagIds: ['tag-1'])),
        expect: () => [
          isA<TaskLoaded>().having(
            (s) => s.filteredTasks.length,
            'filteredTasks length',
            1,
          ),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'does nothing when state is not TaskLoaded',
        build: buildBloc,
        act: (bloc) => bloc.add(const FilterTasks(categoryId: 'cat-1')),
        expect: () => [],
      );
    });

    group('SortTasks', () {
      blocTest<TaskBloc, TaskState>(
        'sorts tasks by title ascending',
        build: buildBloc,
        seed: () => TaskLoaded(
          allTasks: [tTask, tTask2],
          filteredTasks: [
            tTask,
            tTask2,
          ], // [Test Task, Another Task] — unsorted
        ),
        act: (bloc) => bloc.add(const SortTasks('title', true)),
        expect: () => [
          isA<TaskLoaded>().having(
            (s) => s.filteredTasks.first.title,
            'first task title',
            'Another Task',
          ),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'does nothing when state is not TaskLoaded',
        build: buildBloc,
        act: (bloc) => bloc.add(const SortTasks('title', true)),
        expect: () => [],
      );
    });

    group('LoadSubtasks', () {
      blocTest<TaskBloc, TaskState>(
        'does nothing when state is already TaskLoaded (subtasks in allTasks)',
        build: buildBloc,
        seed: () =>
            TaskLoaded(allTasks: [tTask, tSubtask], filteredTasks: [tTask]),
        act: (bloc) => bloc.add(const LoadSubtasks('task-1')),
        expect: () => [],
      );

      blocTest<TaskBloc, TaskState>(
        'dispatches LoadTasks when state is not TaskLoaded',
        build: buildBloc,
        setUp: () {
          when(() => mockGetTasks()).thenAnswer((_) async => [tTask, tSubtask]);
        },
        act: (bloc) => bloc.add(const LoadSubtasks('task-1')),
        expect: () => [const TaskLoading(), isA<TaskLoaded>()],
      );
    });
  });
}
