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
