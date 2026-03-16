# Todo List App — Design Spec

## Overview

A full-featured todo list app for mobile (iOS + Android) built with Flutter, using Hive CE for local persistence, BLoC for state management, and strict clean architecture (data / domain / presentation layers).

## Tech Stack

| Package | Purpose |
|---------|---------|
| flutter_bloc | State management |
| equatable | BLoC event/state equality |
| hive_ce + hive_ce_flutter | Local storage |
| hive_ce_generator | Hive type adapter code gen |
| get_it | Dependency injection |
| freezed + freezed_annotation | Immutable domain entities with copyWith/equality |
| build_runner | Code generation (freezed, hive_ce_generator) |
| go_router | Declarative routing |
| uuid | Unique IDs |
| intl | Date/time formatting |
| flutter_local_notifications | Task reminders |
| flutter_slidable | Swipe actions on list items |
| mocktail | Mocking for tests |
| bloc_test | BLoC testing utilities |

## Data Model

### Task
| Field | Type | Notes |
|-------|------|-------|
| id | String | UUID |
| title | String | Required |
| description | String? | Optional |
| isCompleted | bool | Default false |
| createdAt | DateTime | |
| updatedAt | DateTime | |
| dueDate | DateTime? | Optional |
| priority | Priority | Enum: none, low, medium, high |
| categoryId | String? | FK to Category |
| tags | List\<String\> | List of Tag IDs |
| parentTaskId | String? | null = top-level; non-null = subtask |
| recurrence | Recurrence? | Embedded value object |
| completedAt | DateTime? | Set when completed |

### Recurrence (value object)
| Field | Type | Notes |
|-------|------|-------|
| type | RecurrenceType | Enum: daily, weekly, monthly, custom (custom = every N weeks on specific weekdays, e.g. every 2 weeks on Tue/Thu) |
| interval | int | Every N units |
| weekdays | List\<int\>? | 1=Mon..7=Sun, for weekly/custom |
| endDate | DateTime? | Optional end date |

### Category
| Field | Type | Notes |
|-------|------|-------|
| id | String | UUID |
| name | String | |
| color | int | Color value as int |
| createdAt | DateTime | |
| order | int | For manual sorting |

### Tag
| Field | Type | Notes |
|-------|------|-------|
| id | String | UUID |
| name | String | |
| createdAt | DateTime | |

### Key decisions
- Subtasks are Tasks with non-null `parentTaskId` — no separate model, flat in Hive. Only one level of nesting allowed (subtasks cannot have their own subtasks). Enforced via validation in `CreateTask` use case.
- Tags are their own entity (not just strings) so they can be renamed/deleted consistently.
- Recurrence is a value object embedded in Task, not a separate Hive box.
- Category color stored as int for easy Hive serialization.

## Architecture

### Layer Structure

```
lib/
├── core/
│   ├── di/                     # get_it setup
│   │   └── injection.dart
│   ├── error/                  # failure classes
│   │   └── failures.dart
│   ├── router/                 # go_router config
│   │   └── app_router.dart
│   └── theme/
│       └── app_theme.dart
│
├── data/
│   ├── datasources/
│   │   ├── task_local_datasource.dart
│   │   ├── category_local_datasource.dart
│   │   ├── tag_local_datasource.dart
│   │   └── notification_local_datasource.dart  # wraps flutter_local_notifications
│   ├── models/
│   │   ├── task_model.dart          # @HiveType + toEntity/fromEntity
│   │   ├── recurrence_model.dart
│   │   ├── category_model.dart
│   │   └── tag_model.dart
│   └── repositories/
│       ├── task_repository_impl.dart
│       ├── category_repository_impl.dart
│       ├── tag_repository_impl.dart
│       └── notification_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── task.dart                # freezed, pure Dart
│   │   ├── recurrence.dart
│   │   ├── category.dart
│   │   ├── tag.dart
│   │   └── priority.dart            # enum
│   ├── repositories/
│   │   ├── task_repository.dart      # abstract interface
│   │   ├── category_repository.dart
│   │   ├── tag_repository.dart
│   │   └── notification_repository.dart
│   └── usecases/
│       ├── task/
│       │   ├── create_task.dart
│       │   ├── update_task.dart
│       │   ├── delete_task.dart
│       │   ├── get_tasks.dart
│       │   ├── toggle_task.dart          # handles recurring completion flow
│       │   ├── get_subtasks.dart
│       │   └── search_tasks.dart
│       ├── category/
│       │   ├── create_category.dart
│       │   ├── update_category.dart
│       │   ├── delete_category.dart
│       │   └── get_categories.dart
│       ├── tag/
│       │   ├── create_tag.dart
│       │   ├── update_tag.dart
│       │   ├── delete_tag.dart
│       │   └── get_tags.dart
│       └── notification/
│           ├── schedule_notification.dart
│           └── cancel_notification.dart
│
├── presentation/
│   ├── blocs/
│   │   ├── task/
│   │   │   ├── task_bloc.dart
│   │   │   ├── task_event.dart
│   │   │   └── task_state.dart
│   │   ├── category/
│   │   │   ├── category_bloc.dart
│   │   │   ├── category_event.dart
│   │   │   └── category_state.dart
│   │   ├── tag/
│   │   │   ├── tag_bloc.dart
│   │   │   ├── tag_event.dart
│   │   │   └── tag_state.dart
│   │   └── notification/
│   │       ├── notification_bloc.dart
│   │       ├── notification_event.dart
│   │       └── notification_state.dart
│   ├── pages/
│   │   ├── home/
│   │   │   └── home_page.dart
│   │   ├── task_detail/
│   │   │   └── task_detail_page.dart
│   │   ├── task_form/
│   │   │   └── task_form_page.dart
│   │   ├── category/
│   │   │   └── category_management_page.dart
│   │   ├── tag/
│   │   │   └── tag_management_page.dart
│   │   └── search/
│   │       └── search_page.dart
│   └── widgets/
│       ├── task_tile.dart
│       ├── priority_badge.dart
│       ├── category_chip.dart
│       ├── tag_chip.dart
│       ├── recurrence_picker.dart
│       └── filter_bar.dart
│
└── main.dart
```

### Data Flow

```
Widget → BLoC → UseCase → Repository (interface) → RepositoryImpl → Datasource → Hive Box
```

- Domain layer has pure Dart entities + repository interfaces + use cases. Zero dependencies on Flutter or Hive.
- Data layer has Hive-annotated models that map to/from domain entities, repository implementations, and local datasources wrapping Hive boxes.
- Presentation layer has BLoCs that depend only on use cases, plus pages/widgets.
- DI via get_it wires it all together.
- Domain entities use `freezed` only (pure Dart, no Hive annotations). Data models use `@HiveType`/`@HiveField` only and provide `toEntity()`/`fromEntity()` mapping methods. These are strictly separate classes — never combine freezed and Hive annotations on the same class.

## Hive Storage

### Boxes
| Box | Type | Key |
|-----|------|-----|
| `tasks` | Box\<TaskModel\> | UUID string |
| `categories` | Box\<CategoryModel\> | UUID string |
| `tags` | Box\<TagModel\> | UUID string |

- Each entity stored with its UUID as the Hive key for O(1) lookups.
- Subtasks live in the same `tasks` box — queried by `parentTaskId`.
- Filtering/sorting done in-memory after loading from box (Hive CE doesn't support queries).
- Hive initialization sequence in `main.dart` before `runApp`: init Hive, register all type adapters, open all boxes.
- No schema migration strategy for v1. If the model changes in future versions, a migration helper will be added to handle typeId versioning at that time.

## Screens & Navigation

### Screens

- **Home Page** — Task list with filter bar (category, tag, priority), bottom nav (Tasks / Categories / Tags), FAB to add task.
- **Task Detail Page** — Full task view with subtasks list and add subtask button. Complete/delete actions.
- **Task Form Page** — Create/edit task with title, description, priority dropdown, category picker, tag multi-select, due date picker, recurrence config.
- **Search Page** — Search bar with results list, same filters as home. Search is case-insensitive, matches against title and description, supports partial matching (substring).
- **Category Management Page** — List of categories with add (name + color), swipe to edit/delete, drag to reorder.
- **Tag Management Page** — List of tags with add, swipe to edit/delete.

### Routes (go_router)
| Route | Screen |
|-------|--------|
| `/` | Home (task list tab) |
| `/categories` | Category management tab |
| `/tags` | Tag management tab |
| `/task/new` | Task form (create) |
| `/task/:id` | Task detail |
| `/task/:id/edit` | Task form (edit) |
| `/task/:id/subtask/new` | Task form (create subtask) |
| `/search` | Search page |

- Bottom nav switches between Tasks / Categories / Tags tabs.
- FAB on home navigates to `/task/new`.
- Search accessible via icon in app bar.

## BLoC Design

### TaskBloc
**Events:** LoadTasks, CreateTask(task), UpdateTask(task), DeleteTask(id), ToggleTask(id), FilterTasks(category, tags, priority, search), SortTasks(sortBy, ascending)

**States:** TaskInitial, TaskLoading, TaskLoaded(tasks, filters), TaskError(message)

- `ToggleTask` is responsible for the full recurring completion flow: flip `isCompleted`, set `completedAt`, and if the task has a `recurrence`, calculate the next due date, create a new Task via the TaskRepository, and schedule its notification via the NotificationRepository. This is the most complex use case in the app.
- `FilterTasks` applies in-memory filtering on the loaded list.
- Tasks are sorted by computed properties only (due date, priority, creation date). No manual ordering. Default sort: incomplete first, then by due date (soonest first), then by priority (high first).

### CategoryBloc
**Events:** LoadCategories, CreateCategory(category), UpdateCategory(category), DeleteCategory(id), ReorderCategories(ids)

**States:** CategoryInitial, CategoryLoading, CategoryLoaded(categories), CategoryError(message)

- `DeleteCategory` use case depends on both CategoryRepository and TaskRepository. It deletes the category, then clears `categoryId` on all affected tasks. This cross-repository dependency is acceptable at the use case layer.

### TagBloc
**Events:** LoadTags, CreateTag(tag), UpdateTag(tag), DeleteTag(id)

**States:** TagInitial, TagLoading, TagLoaded(tags), TagError(message)

- `DeleteTag` use case depends on both TagRepository and TaskRepository. It deletes the tag, then removes the tag ID from all affected tasks' tag lists. Same cross-repository pattern as DeleteCategory.

### NotificationBloc
**Events:** ScheduleNotification(task), CancelNotification(taskId), HandleNotificationTap(taskId)

**States:** NotificationInitial, NotificationReady, NotificationError(message)

- Listens to task changes rather than being called directly.

### Cross-BLoC Coordination
- Deleting a category/tag triggers a use case that also updates affected tasks at the use case layer.
- BLoCs remain independent — no BLoC-to-BLoC communication.
- The widget layer is responsible for dispatching `LoadTasks` to TaskBloc after a CategoryBloc or TagBloc delete completes. This is done via `BlocListener` in the parent widget that wraps both BLoCs.

## Notifications

- `flutter_local_notifications` schedules a notification at each task's `dueDate`.
- When a task is created/updated with a due date → schedule notification.
- When a task is completed/deleted → cancel notification.
- Recurring tasks: on completion, auto-create next occurrence based on recurrence rules, schedule its notification.
- Notification tap → deep link via go_router to `/task/:id`.

### Recurring Task Completion Flow
1. User completes recurring task.
2. Mark current instance as completed.
3. Calculate next due date from recurrence rules.
4. Create new Task (same title/desc/priority/category/tags) with new dueDate and same recurrence.
5. Schedule notification for new task.

## Testing Strategy

- **Domain layer:** Unit test use cases with mocked repositories (mocktail).
- **Data layer:** Unit test repository implementations with mocked datasources. Test model mapping (toEntity/fromEntity).
- **Presentation layer:** BLoC tests with bloc_test — verify state transitions for each event. Widget tests for key UI components.
