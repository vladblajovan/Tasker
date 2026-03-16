# Flavors & Remote Datasource Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable switching between local-only (Hive) and remote (Supabase + Hive cache) data sources via separate entry points.

**Architecture:** Cache-through remote datasources that implement existing datasource interfaces, wrapping local Hive datasources for caching. Two entry points (`main_dev.dart`, `main_prod.dart`) each wire their own DI graph. Domain, presentation, and repository layers are untouched.

**Tech Stack:** Flutter, Hive CE, Supabase Flutter, GetIt, BLoC

**Spec:** `docs/superpowers/specs/2026-03-16-flavors-remote-datasource-design.md`

---

## Chunk 1: Core Infrastructure

Extracts shared init, creates entry points, splits DI. All existing tests must keep passing — this is a refactor with no behavior change.

### Task 1: Add supabase_flutter dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependency**

Add `supabase_flutter` to pubspec.yaml under dependencies:

```yaml
  supabase_flutter: ^2.8.0
```

- [ ] **Step 2: Run pub get**

Run: `flutter pub get`
Expected: resolves successfully

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add supabase_flutter dependency"
```

### Task 2: Create AppConfig

**Files:**
- Create: `lib/core/config/app_config.dart`

- [ ] **Step 1: Create the config file**

```dart
enum Flavor { dev, prod }

class AppConfig {
  const AppConfig({
    required this.flavor,
    this.supabaseUrl,
    this.supabaseAnonKey,
  });

  final Flavor flavor;
  final String? supabaseUrl;
  final String? supabaseAnonKey;

  static late final AppConfig instance;

  bool get isProduction => flavor == Flavor.prod;
}
```

- [ ] **Step 2: Verify analysis passes**

Run: `flutter analyze lib/core/config/app_config.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/core/config/app_config.dart
git commit -m "feat: add AppConfig with Flavor enum"
```

### Task 3: Extract shared Hive init to app_init.dart

**Files:**
- Create: `lib/core/init/app_init.dart`

Extract the Hive adapter registration and box opening from `main.dart` into a reusable function.

- [ ] **Step 1: Create app_init.dart**

```dart
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:test_app/data/models/category_model.dart';
import 'package:test_app/data/models/priority_adapter.dart';
import 'package:test_app/data/models/recurrence_model.dart';
import 'package:test_app/data/models/recurrence_type_adapter.dart';
import 'package:test_app/data/models/tag_model.dart';
import 'package:test_app/data/models/task_model.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  // Register type adapters
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(RecurrenceModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TagModelAdapter());
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(RecurrenceTypeAdapter());

  // Open boxes
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<TagModel>('tags');
}
```

- [ ] **Step 2: Verify analysis passes**

Run: `flutter analyze lib/core/init/app_init.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/core/init/app_init.dart
git commit -m "refactor: extract shared Hive init to app_init.dart"
```

### Task 4: Extract TodoApp widget to app.dart

**Files:**
- Create: `lib/app.dart`

Extract the `TodoApp` widget from `main.dart` so both entry points can import it.

- [ ] **Step 1: Create app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/core/di/injection.dart';
import 'package:test_app/core/router/app_router.dart';
import 'package:test_app/core/theme/app_theme.dart';
import 'package:test_app/presentation/blocs/category/category_bloc.dart';
import 'package:test_app/presentation/blocs/notification/notification_bloc.dart';
import 'package:test_app/presentation/blocs/tag/tag_bloc.dart';
import 'package:test_app/presentation/blocs/task/task_bloc.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(create: (_) => sl<TaskBloc>()),
        BlocProvider<CategoryBloc>(create: (_) => sl<CategoryBloc>()),
        BlocProvider<TagBloc>(create: (_) => sl<TagBloc>()),
        BlocProvider<NotificationBloc>(create: (_) => sl<NotificationBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

- [ ] **Step 2: Verify analysis passes**

Run: `flutter analyze lib/app.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/app.dart
git commit -m "refactor: extract TodoApp widget to app.dart"
```

### Task 5: Create entry points and delete main.dart

**Files:**
- Create: `lib/main_dev.dart`
- Create: `lib/main_prod.dart`
- Delete: `lib/main.dart`

- [ ] **Step 1: Create main_dev.dart**

```dart
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:test_app/app.dart';
import 'package:test_app/core/config/app_config.dart';
import 'package:test_app/core/di/injection.dart';
import 'package:test_app/core/init/app_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.instance = const AppConfig(flavor: Flavor.dev);
  await initHive();
  tz.initializeTimeZones();
  setupDevDependencies();
  runApp(const TodoApp());
}
```

- [ ] **Step 2: Create main_prod.dart**

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:test_app/app.dart';
import 'package:test_app/core/config/app_config.dart';
import 'package:test_app/core/di/injection.dart';
import 'package:test_app/core/init/app_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  AppConfig.instance = const AppConfig(
    flavor: Flavor.prod,
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
  await initHive();
  tz.initializeTimeZones();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  setupProdDependencies();
  runApp(const TodoApp());
}
```

- [ ] **Step 3: Delete main.dart**

```bash
rm lib/main.dart
```

- [ ] **Step 4: Verify analysis passes**

Run: `flutter analyze lib/main_dev.dart lib/main_prod.dart`
Expected: No issues found (note: `setupDevDependencies` and `setupProdDependencies` don't exist yet — they will be created in Task 6. This step may show errors until Task 6 is complete. Defer verification to Task 6.)

- [ ] **Step 5: Commit**

```bash
git add lib/main_dev.dart lib/main_prod.dart
git rm lib/main.dart
git commit -m "feat: add dev/prod entry points, remove main.dart"
```

### Task 6: Split DI into dev/prod setup

**Files:**
- Modify: `lib/core/di/injection.dart`

Refactor the single `setupDependencies()` into `setupDevDependencies()` and `setupProdDependencies()`, with shared helpers for repositories, use cases, BLoCs, and notifications.

- [ ] **Step 1: Rewrite injection.dart**

Replace the entire contents of `lib/core/di/injection.dart` with:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_app/data/datasources/category_local_datasource.dart';
import 'package:test_app/data/datasources/notification_local_datasource.dart';
import 'package:test_app/data/datasources/remote/category_remote_datasource.dart';
import 'package:test_app/data/datasources/remote/tag_remote_datasource.dart';
import 'package:test_app/data/datasources/remote/task_remote_datasource.dart';
import 'package:test_app/data/datasources/tag_local_datasource.dart';
import 'package:test_app/data/datasources/task_local_datasource.dart';
import 'package:test_app/data/models/category_model.dart';
import 'package:test_app/data/models/tag_model.dart';
import 'package:test_app/data/models/task_model.dart';
import 'package:test_app/data/repositories/category_repository_impl.dart';
import 'package:test_app/data/repositories/notification_repository_impl.dart';
import 'package:test_app/data/repositories/tag_repository_impl.dart';
import 'package:test_app/data/repositories/task_repository_impl.dart';
import 'package:test_app/domain/repositories/category_repository.dart';
import 'package:test_app/domain/repositories/notification_repository.dart';
import 'package:test_app/domain/repositories/tag_repository.dart';
import 'package:test_app/domain/repositories/task_repository.dart';
import 'package:test_app/domain/usecases/category/create_category.dart';
import 'package:test_app/domain/usecases/category/delete_category.dart';
import 'package:test_app/domain/usecases/category/get_categories.dart';
import 'package:test_app/domain/usecases/category/update_category.dart';
import 'package:test_app/domain/usecases/notification/cancel_notification.dart';
import 'package:test_app/domain/usecases/notification/schedule_notification.dart';
import 'package:test_app/domain/usecases/tag/create_tag.dart';
import 'package:test_app/domain/usecases/tag/delete_tag.dart';
import 'package:test_app/domain/usecases/tag/get_tags.dart';
import 'package:test_app/domain/usecases/tag/update_tag.dart';
import 'package:test_app/domain/usecases/task/create_task.dart';
import 'package:test_app/domain/usecases/task/delete_task.dart';
import 'package:test_app/domain/usecases/task/get_subtasks.dart';
import 'package:test_app/domain/usecases/task/get_tasks.dart';
import 'package:test_app/domain/usecases/task/search_tasks.dart';
import 'package:test_app/domain/usecases/task/toggle_task.dart';
import 'package:test_app/domain/usecases/task/update_task.dart';
import 'package:test_app/presentation/blocs/category/category_bloc.dart';
import 'package:test_app/presentation/blocs/notification/notification_bloc.dart';
import 'package:test_app/presentation/blocs/tag/tag_bloc.dart';
import 'package:test_app/presentation/blocs/task/task_bloc.dart';

final sl = GetIt.instance;

// ──── Dev Flavor ────

void setupDevDependencies() {
  _registerLocalDatasources();
  _registerNotificationDatasource();
  _registerRepositories();
  _registerUseCasesAndBlocs();
}

// ──── Prod Flavor ────

void setupProdDependencies() {
  // Local datasources under named instances (used as cache by remote datasources)
  sl.registerLazySingleton<TaskLocalDatasource>(
    () => TaskLocalDatasourceImpl(Hive.box<TaskModel>('tasks')),
    instanceName: 'local',
  );
  sl.registerLazySingleton<CategoryLocalDatasource>(
    () => CategoryLocalDatasourceImpl(Hive.box<CategoryModel>('categories')),
    instanceName: 'local',
  );
  sl.registerLazySingleton<TagLocalDatasource>(
    () => TagLocalDatasourceImpl(Hive.box<TagModel>('tags')),
    instanceName: 'local',
  );

  // Remote datasources as the primary implementations
  sl.registerLazySingleton<TaskLocalDatasource>(
    () => TaskRemoteDatasourceImpl(
      Supabase.instance.client,
      sl<TaskLocalDatasource>(instanceName: 'local'),
    ),
  );
  sl.registerLazySingleton<CategoryLocalDatasource>(
    () => CategoryRemoteDatasourceImpl(
      Supabase.instance.client,
      sl<CategoryLocalDatasource>(instanceName: 'local'),
    ),
  );
  sl.registerLazySingleton<TagLocalDatasource>(
    () => TagRemoteDatasourceImpl(
      Supabase.instance.client,
      sl<TagLocalDatasource>(instanceName: 'local'),
    ),
  );

  _registerNotificationDatasource();
  _registerRepositories();
  _registerUseCasesAndBlocs();
}

// ──── Shared Helpers ────

void _registerLocalDatasources() {
  sl.registerLazySingleton<TaskLocalDatasource>(
    () => TaskLocalDatasourceImpl(Hive.box<TaskModel>('tasks')),
  );
  sl.registerLazySingleton<CategoryLocalDatasource>(
    () => CategoryLocalDatasourceImpl(Hive.box<CategoryModel>('categories')),
  );
  sl.registerLazySingleton<TagLocalDatasource>(
    () => TagLocalDatasourceImpl(Hive.box<TagModel>('tags')),
  );
}

void _registerNotificationDatasource() {
  sl.registerLazySingleton<NotificationLocalDatasource>(
    () => NotificationLocalDatasourceImpl(FlutterLocalNotificationsPlugin()),
  );
}

void _registerRepositories() {
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl<TaskLocalDatasource>()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<CategoryLocalDatasource>()),
  );
  sl.registerLazySingleton<TagRepository>(
    () => TagRepositoryImpl(sl<TagLocalDatasource>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationLocalDatasource>()),
  );
}

void _registerUseCasesAndBlocs() {
  // ──── Use Cases — Task ────
  sl.registerLazySingleton(() => GetTasks(sl<TaskRepository>()));
  sl.registerLazySingleton(() => CreateTask(sl<TaskRepository>()));
  sl.registerLazySingleton(() => UpdateTask(sl<TaskRepository>()));
  sl.registerLazySingleton(() => DeleteTask(sl<TaskRepository>()));
  sl.registerLazySingleton(
    () => ToggleTask(sl<TaskRepository>(), sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(() => SearchTasks(sl<TaskRepository>()));
  sl.registerLazySingleton(() => GetSubtasks(sl<TaskRepository>()));

  // ──── Use Cases — Category ────
  sl.registerLazySingleton(() => GetCategories(sl<CategoryRepository>()));
  sl.registerLazySingleton(() => CreateCategory(sl<CategoryRepository>()));
  sl.registerLazySingleton(() => UpdateCategory(sl<CategoryRepository>()));
  sl.registerLazySingleton(
    () => DeleteCategory(sl<CategoryRepository>(), sl<TaskRepository>()),
  );

  // ──── Use Cases — Tag ────
  sl.registerLazySingleton(() => GetTags(sl<TagRepository>()));
  sl.registerLazySingleton(() => CreateTag(sl<TagRepository>()));
  sl.registerLazySingleton(() => UpdateTag(sl<TagRepository>()));
  sl.registerLazySingleton(
    () => DeleteTag(sl<TagRepository>(), sl<TaskRepository>()),
  );

  // ──── Use Cases — Notification ────
  sl.registerLazySingleton(
    () => ScheduleNotification(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton(
    () => CancelNotification(sl<NotificationRepository>()),
  );

  // ──── BLoCs ────
  sl.registerFactory(
    () => TaskBloc(
      getTasks: sl<GetTasks>(),
      createTask: sl<CreateTask>(),
      updateTask: sl<UpdateTask>(),
      deleteTask: sl<DeleteTask>(),
      toggleTask: sl<ToggleTask>(),
      searchTasks: sl<SearchTasks>(),
      getSubtasks: sl<GetSubtasks>(),
    ),
  );
  sl.registerFactory(
    () => CategoryBloc(
      getCategories: sl<GetCategories>(),
      createCategory: sl<CreateCategory>(),
      updateCategory: sl<UpdateCategory>(),
      deleteCategory: sl<DeleteCategory>(),
    ),
  );
  sl.registerFactory(
    () => TagBloc(
      getTags: sl<GetTags>(),
      createTag: sl<CreateTag>(),
      updateTag: sl<UpdateTag>(),
      deleteTag: sl<DeleteTag>(),
    ),
  );
  sl.registerFactory(
    () => NotificationBloc(
      scheduleNotification: sl<ScheduleNotification>(),
      cancelNotification: sl<CancelNotification>(),
    ),
  );
}
```

Note: This file imports the remote datasource files which don't exist yet. Analysis will fail until Chunk 2 is complete. However, the dev path (`setupDevDependencies`) does not reference any remote datasource classes — only the prod path and the import statements do. To keep the build green between chunks, add the three remote datasource files as stubs (empty classes) in Task 7/8/9 of Chunk 2 before running analysis.

- [ ] **Step 2: Run all existing tests**

Run: `flutter test`
Expected: All 126 tests pass (tests only use mocks, not the DI container)

- [ ] **Step 3: Verify dev flavor analysis**

Run: `flutter analyze`
Expected: May have errors from missing remote datasource imports — these are resolved in Chunk 2. All existing tests should still pass regardless.

- [ ] **Step 4: Commit**

```bash
git add lib/core/di/injection.dart
git commit -m "refactor: split DI into setupDevDependencies/setupProdDependencies"
```

---

## Chunk 2: Remote Datasources

Create the three cache-through remote datasources. Each wraps a local Hive datasource and a SupabaseClient. Reads fetch from Supabase and cache to Hive with offline fallback. Writes are optimistic-local (write Hive first, then push to Supabase).

### Task 7: Create TaskRemoteDatasourceImpl

**Files:**
- Create: `lib/data/datasources/remote/task_remote_datasource.dart`
- Create: `test/data/datasources/remote/task_remote_datasource_test.dart`

- [ ] **Step 1: Write the test file**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_app/data/datasources/remote/task_remote_datasource.dart';
import 'package:test_app/data/datasources/task_local_datasource.dart';
import 'package:test_app/data/models/recurrence_model.dart';
import 'package:test_app/data/models/task_model.dart';
import 'package:test_app/domain/entities/priority.dart';
import 'package:test_app/domain/entities/recurrence.dart';

class MockTaskLocalDatasource extends Mock implements TaskLocalDatasource {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {}

void main() {
  late TaskRemoteDatasourceImpl datasource;
  late MockTaskLocalDatasource mockLocal;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;

  final now = DateTime(2026, 1, 1);

  final tTaskModel = TaskModel(
    id: 'task-1',
    title: 'Test Task',
    description: 'A test task',
    isCompleted: false,
    createdAt: now,
    updatedAt: now,
    priority: Priority.medium,
    tags: ['tag-1'],
  );

  setUp(() {
    mockLocal = MockTaskLocalDatasource();
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    datasource = TaskRemoteDatasourceImpl(mockClient, mockLocal);
  });

  setUpAll(() {
    registerFallbackValue(tTaskModel);
  });

  group('toSupabaseRow / fromSupabaseRow', () {
    test('round-trips a TaskModel correctly', () {
      final row = TaskRemoteDatasourceImpl.toSupabaseRow(tTaskModel);
      final result = TaskRemoteDatasourceImpl.fromSupabaseRow(row);

      expect(result.id, tTaskModel.id);
      expect(result.title, tTaskModel.title);
      expect(result.description, tTaskModel.description);
      expect(result.isCompleted, tTaskModel.isCompleted);
      expect(result.priority, tTaskModel.priority);
      expect(result.tags, tTaskModel.tags);
      expect(result.recurrence, isNull);
    });

    test('round-trips a TaskModel with recurrence', () {
      final taskWithRecurrence = TaskModel(
        id: 'task-2',
        title: 'Recurring',
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
        priority: Priority.high,
        tags: [],
        recurrence: RecurrenceModel(
          type: RecurrenceType.weekly,
          interval: 2,
          weekdays: [1, 3, 5],
          endDate: DateTime(2026, 12, 31),
        ),
      );

      final row = TaskRemoteDatasourceImpl.toSupabaseRow(taskWithRecurrence);
      final result = TaskRemoteDatasourceImpl.fromSupabaseRow(row);

      expect(result.recurrence, isNotNull);
      expect(result.recurrence!.type, RecurrenceType.weekly);
      expect(result.recurrence!.interval, 2);
      expect(result.recurrence!.weekdays, [1, 3, 5]);
      expect(result.recurrence!.endDate, DateTime(2026, 12, 31));
    });
  });

  group('createTask', () {
    test('writes to local first, then pushes to Supabase', () async {
      when(() => mockLocal.createTask(any())).thenAnswer((_) async {});
      when(() => mockClient.from('tasks')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.upsert(any()))
          .thenAnswer((_) async => []);

      await datasource.createTask(tTaskModel);

      verifyInOrder([
        () => mockLocal.createTask(tTaskModel),
        () => mockClient.from('tasks'),
      ]);
    });
  });

  group('deleteTask', () {
    test('deletes from local first, then from Supabase', () async {
      when(() => mockLocal.deleteTask(any())).thenAnswer((_) async {});
      when(() => mockClient.from('tasks')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(
        MockPostgrestFilterBuilder(),
      );
      final mockFilter = MockPostgrestFilterBuilder();
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilter);
      when(() => mockFilter.eq('id', any())).thenAnswer((_) async => []);

      await datasource.deleteTask('task-1');

      verify(() => mockLocal.deleteTask('task-1')).called(1);
    });
  });
}
```

Note: Testing Supabase mocks can be tricky due to the builder pattern. The round-trip tests for `toSupabaseRow`/`fromSupabaseRow` are the most valuable since they verify the conversion logic. Integration testing with a real Supabase instance is recommended for full coverage.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/datasources/remote/task_remote_datasource_test.dart`
Expected: FAIL — file not found / class not defined

- [ ] **Step 3: Create the implementation**

Create `lib/data/datasources/remote/task_remote_datasource.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_app/data/datasources/task_local_datasource.dart';
import 'package:test_app/data/models/recurrence_model.dart';
import 'package:test_app/data/models/task_model.dart';
import 'package:test_app/domain/entities/priority.dart';
import 'package:test_app/domain/entities/recurrence.dart';

class TaskRemoteDatasourceImpl implements TaskLocalDatasource {
  TaskRemoteDatasourceImpl(this._client, this._localDatasource);

  final SupabaseClient _client;
  final TaskLocalDatasource _localDatasource;

  static const _table = 'tasks';

  // ──── Reads ────

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final rows = await _client.from(_table).select();
      final tasks = rows.map(fromSupabaseRow).toList();
      // Cache to local
      for (final task in tasks) {
        await _localDatasource.createTask(task);
      }
      return tasks;
    } catch (_) {
      // Offline fallback
      return _localDatasource.getAllTasks();
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      final rows = await _client.from(_table).select().eq('id', id);
      if (rows.isEmpty) return null;
      final task = fromSupabaseRow(rows.first);
      await _localDatasource.createTask(task);
      return task;
    } catch (_) {
      return _localDatasource.getTaskById(id);
    }
  }

  // ──── Writes (optimistic local) ────

  @override
  Future<void> createTask(TaskModel task) async {
    await _localDatasource.createTask(task);
    try {
      await _client.from(_table).upsert(toSupabaseRow(task));
    } catch (_) {
      // Local data persists — sync/retry out of scope for v1
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _localDatasource.updateTask(task);
    try {
      await _client.from(_table).upsert(toSupabaseRow(task));
    } catch (_) {}
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDatasource.deleteTask(id);
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (_) {}
  }

  // ──── Conversion Helpers ────

  static TaskModel fromSupabaseRow(Map<String, dynamic> row) {
    return TaskModel(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String?,
      isCompleted: row['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      dueDate: row['due_date'] != null
          ? DateTime.parse(row['due_date'] as String)
          : null,
      priority: Priority.values[row['priority'] as int? ?? 0],
      categoryId: row['category_id'] as String?,
      tags: List<String>.from(row['tags'] ?? []),
      parentTaskId: row['parent_task_id'] as String?,
      recurrence: _recurrenceFromRow(row),
      completedAt: row['completed_at'] != null
          ? DateTime.parse(row['completed_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toSupabaseRow(TaskModel model) {
    return {
      'id': model.id,
      'title': model.title,
      'description': model.description,
      'is_completed': model.isCompleted,
      'created_at': model.createdAt.toIso8601String(),
      'updated_at': model.updatedAt.toIso8601String(),
      'due_date': model.dueDate?.toIso8601String(),
      'priority': model.priority.index,
      'category_id': model.categoryId,
      'tags': model.tags,
      'parent_task_id': model.parentTaskId,
      'completed_at': model.completedAt?.toIso8601String(),
      'recurrence_type': model.recurrence?.type.index,
      'recurrence_interval': model.recurrence?.interval,
      'recurrence_days_of_week': model.recurrence?.weekdays,
      'recurrence_end_date': model.recurrence?.endDate?.toIso8601String(),
    };
  }

  static RecurrenceModel? _recurrenceFromRow(Map<String, dynamic> row) {
    final type = row['recurrence_type'] as int?;
    if (type == null) return null;
    return RecurrenceModel(
      type: RecurrenceType.values[type],
      interval: row['recurrence_interval'] as int,
      weekdays: row['recurrence_days_of_week'] != null
          ? List<int>.from(row['recurrence_days_of_week'])
          : null,
      endDate: row['recurrence_end_date'] != null
          ? DateTime.parse(row['recurrence_end_date'] as String)
          : null,
    );
  }
}
```

- [ ] **Step 4: Run the round-trip tests**

Run: `flutter test test/data/datasources/remote/task_remote_datasource_test.dart`
Expected: Round-trip tests pass. Mock-based tests may need adjustment based on Supabase mock behavior — focus on the conversion tests passing.

- [ ] **Step 5: Commit**

```bash
git add lib/data/datasources/remote/task_remote_datasource.dart test/data/datasources/remote/task_remote_datasource_test.dart
git commit -m "feat: add TaskRemoteDatasourceImpl with cache-through pattern"
```

### Task 8: Create CategoryRemoteDatasourceImpl

**Files:**
- Create: `lib/data/datasources/remote/category_remote_datasource.dart`
- Create: `test/data/datasources/remote/category_remote_datasource_test.dart`

- [ ] **Step 1: Write the test file**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/datasources/remote/category_remote_datasource.dart';
import 'package:test_app/data/models/category_model.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  final tCategoryModel = CategoryModel(
    id: 'cat-1',
    name: 'Work',
    color: 0xFF2196F3,
    createdAt: now,
    order: 0,
  );

  group('toSupabaseRow / fromSupabaseRow', () {
    test('round-trips a CategoryModel correctly', () {
      final row = CategoryRemoteDatasourceImpl.toSupabaseRow(tCategoryModel);
      final result = CategoryRemoteDatasourceImpl.fromSupabaseRow(row);

      expect(result.id, tCategoryModel.id);
      expect(result.name, tCategoryModel.name);
      expect(result.color, tCategoryModel.color);
      expect(result.order, tCategoryModel.order);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/datasources/remote/category_remote_datasource_test.dart`
Expected: FAIL

- [ ] **Step 3: Create the implementation**

Create `lib/data/datasources/remote/category_remote_datasource.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_app/data/datasources/category_local_datasource.dart';
import 'package:test_app/data/models/category_model.dart';

class CategoryRemoteDatasourceImpl implements CategoryLocalDatasource {
  CategoryRemoteDatasourceImpl(this._client, this._localDatasource);

  final SupabaseClient _client;
  final CategoryLocalDatasource _localDatasource;

  static const _table = 'categories';

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final rows = await _client.from(_table).select();
      final categories = rows.map(fromSupabaseRow).toList();
      for (final cat in categories) {
        await _localDatasource.createCategory(cat);
      }
      return categories;
    } catch (_) {
      return _localDatasource.getAllCategories();
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final rows = await _client.from(_table).select().eq('id', id);
      if (rows.isEmpty) return null;
      final cat = fromSupabaseRow(rows.first);
      await _localDatasource.createCategory(cat);
      return cat;
    } catch (_) {
      return _localDatasource.getCategoryById(id);
    }
  }

  @override
  Future<void> createCategory(CategoryModel category) async {
    await _localDatasource.createCategory(category);
    try {
      await _client.from(_table).upsert(toSupabaseRow(category));
    } catch (_) {}
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _localDatasource.updateCategory(category);
    try {
      await _client.from(_table).upsert(toSupabaseRow(category));
    } catch (_) {}
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _localDatasource.deleteCategory(id);
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (_) {}
  }

  static CategoryModel fromSupabaseRow(Map<String, dynamic> row) {
    return CategoryModel(
      id: row['id'] as String,
      name: row['name'] as String,
      color: row['color'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      order: row['order'] as int? ?? 0,
    );
  }

  static Map<String, dynamic> toSupabaseRow(CategoryModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'color': model.color,
      'created_at': model.createdAt.toIso8601String(),
      'order': model.order,
    };
  }
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/data/datasources/remote/category_remote_datasource_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/datasources/remote/category_remote_datasource.dart test/data/datasources/remote/category_remote_datasource_test.dart
git commit -m "feat: add CategoryRemoteDatasourceImpl with cache-through pattern"
```

### Task 9: Create TagRemoteDatasourceImpl

**Files:**
- Create: `lib/data/datasources/remote/tag_remote_datasource.dart`
- Create: `test/data/datasources/remote/tag_remote_datasource_test.dart`

- [ ] **Step 1: Write the test file**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/datasources/remote/tag_remote_datasource.dart';
import 'package:test_app/data/models/tag_model.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  final tTagModel = TagModel(
    id: 'tag-1',
    name: 'urgent',
    createdAt: now,
  );

  group('toSupabaseRow / fromSupabaseRow', () {
    test('round-trips a TagModel correctly', () {
      final row = TagRemoteDatasourceImpl.toSupabaseRow(tTagModel);
      final result = TagRemoteDatasourceImpl.fromSupabaseRow(row);

      expect(result.id, tTagModel.id);
      expect(result.name, tTagModel.name);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/datasources/remote/tag_remote_datasource_test.dart`
Expected: FAIL

- [ ] **Step 3: Create the implementation**

Create `lib/data/datasources/remote/tag_remote_datasource.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_app/data/datasources/tag_local_datasource.dart';
import 'package:test_app/data/models/tag_model.dart';

class TagRemoteDatasourceImpl implements TagLocalDatasource {
  TagRemoteDatasourceImpl(this._client, this._localDatasource);

  final SupabaseClient _client;
  final TagLocalDatasource _localDatasource;

  static const _table = 'tags';

  @override
  Future<List<TagModel>> getAllTags() async {
    try {
      final rows = await _client.from(_table).select();
      final tags = rows.map(fromSupabaseRow).toList();
      for (final tag in tags) {
        await _localDatasource.createTag(tag);
      }
      return tags;
    } catch (_) {
      return _localDatasource.getAllTags();
    }
  }

  @override
  Future<TagModel?> getTagById(String id) async {
    try {
      final rows = await _client.from(_table).select().eq('id', id);
      if (rows.isEmpty) return null;
      final tag = fromSupabaseRow(rows.first);
      await _localDatasource.createTag(tag);
      return tag;
    } catch (_) {
      return _localDatasource.getTagById(id);
    }
  }

  @override
  Future<void> createTag(TagModel tag) async {
    await _localDatasource.createTag(tag);
    try {
      await _client.from(_table).upsert(toSupabaseRow(tag));
    } catch (_) {}
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    await _localDatasource.updateTag(tag);
    try {
      await _client.from(_table).upsert(toSupabaseRow(tag));
    } catch (_) {}
  }

  @override
  Future<void> deleteTag(String id) async {
    await _localDatasource.deleteTag(id);
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (_) {}
  }

  static TagModel fromSupabaseRow(Map<String, dynamic> row) {
    return TagModel(
      id: row['id'] as String,
      name: row['name'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  static Map<String, dynamic> toSupabaseRow(TagModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'created_at': model.createdAt.toIso8601String(),
    };
  }
}
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/data/datasources/remote/tag_remote_datasource_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/datasources/remote/tag_remote_datasource.dart test/data/datasources/remote/tag_remote_datasource_test.dart
git commit -m "feat: add TagRemoteDatasourceImpl with cache-through pattern"
```

### Task 10: Final verification

- [ ] **Step 1: Run full analysis**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 2: Run all tests**

Run: `flutter test`
Expected: All tests pass (126 existing + new remote datasource tests)

- [ ] **Step 3: Verify dev flavor builds**

Run: `flutter build apk -t lib/main_dev.dart --debug`
Expected: Build succeeds

- [ ] **Step 4: Commit any remaining fixes**

If any analysis or test issues were found, fix and commit.

- [ ] **Step 5: Final commit with all files**

```bash
git add -A
git commit -m "feat: complete flavors & remote datasource implementation"
```
