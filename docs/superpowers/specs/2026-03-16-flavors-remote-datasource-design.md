# Flavors & Remote Datasource Design

## Goal

Enable the todo app to switch between local-only (Hive) and remote (Supabase-backed with local cache) data sources via Flutter flavors, with separate entry points per flavor.

## Flavors

| Flavor | Entry point | Data source | Description |
|--------|------------|-------------|-------------|
| dev | `lib/main_dev.dart` | Hive only | Current behavior, local-only |
| prod | `lib/main_prod.dart` | Remote (Supabase) + Hive cache | Remote source of truth with local caching |

**Run commands:**
```
flutter run -t lib/main_dev.dart    # development
flutter run -t lib/main_prod.dart   # production
```

## Architecture

### What changes

1. **New remote datasources** (cache-through pattern)
2. **App config class** for flavor identification
3. **Split DI setup** into flavor-specific wiring
4. **Two entry points** replacing single `main.dart`
5. **New dependency**: `supabase_flutter`

### What stays the same

- Domain layer (entities, use cases, repository interfaces) — zero changes
- Presentation layer (BLoCs, pages, widgets) — zero changes
- Repository implementations — zero changes (they depend on datasource interfaces)
- NotificationLocalDatasource — always local in both flavors
- Hive models & adapters — unchanged, used for local caching in both flavors

## Remote Datasources (cache-through pattern)

Each remote datasource implements the same abstract interface as the local one and wraps the local datasource for caching:

```dart
class TaskRemoteDatasourceImpl implements TaskLocalDatasource {
  final SupabaseClient _client;
  final TaskLocalDatasource _localDatasource; // Hive, for caching

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      // 1. Fetch from Supabase
      // 2. Write to Hive cache
      // 3. Return results
    } catch (e) {
      // Offline fallback: read from Hive cache
      return _localDatasource.getAllTasks();
    }
  }

  @override
  Future<void> createTask(TaskModel task) async {
    // 1. Push to Supabase
    // 2. Update Hive cache
  }

  // Same pattern for update, delete, getById
}
```

Three remote datasources, same pattern:
- `TaskRemoteDatasourceImpl` implements `TaskLocalDatasource`
- `CategoryRemoteDatasourceImpl` implements `CategoryLocalDatasource`
- `TagRemoteDatasourceImpl` implements `TagLocalDatasource`

All live in `lib/data/datasources/remote/`.

### Write-failure policy

Writes use an **optimistic local** strategy:
1. Write to Hive cache first (so the user's data is never lost)
2. Push to Supabase
3. If Supabase push fails, the local data persists — sync/retry is out of scope for v1

This means the local cache may temporarily diverge from remote, but data is never lost from the user's perspective.

### Supabase-to-model conversion

Each remote datasource includes static helpers to convert between Supabase JSON rows and Hive models:

```dart
static TaskModel _fromSupabaseRow(Map<String, dynamic> row) { ... }
static Map<String, dynamic> _toSupabaseRow(TaskModel model) { ... }
```

### Enum-to-integer mapping

Enums are stored as their `.index` value in Supabase:

| Priority | Index | RecurrenceType | Index |
|----------|-------|----------------|-------|
| none | 0 | daily | 0 |
| low | 1 | weekly | 1 |
| medium | 2 | monthly | 2 |
| high | 3 | custom | 3 |

### RecurrenceModel reconstruction

When reading from Supabase, the four nullable recurrence columns are reassembled into a `RecurrenceModel?`:

```dart
RecurrenceModel? _recurrenceFromRow(Map<String, dynamic> row) {
  final type = row['recurrence_type'] as int?;
  if (type == null) return null;
  return RecurrenceModel(
    type: RecurrenceType.values[type],
    interval: row['recurrence_interval'] as int,
    weekdays: row['recurrence_days_of_week'] != null
        ? List<int>.from(row['recurrence_days_of_week'])
        : [],
    endDate: row['recurrence_end_date'] != null
        ? DateTime.parse(row['recurrence_end_date'] as String)
        : null,
  );
}
```

When writing, the reverse: if `recurrence` is null, all four columns are null; otherwise, each field maps to its column.

## App Config

```dart
// lib/core/config/app_config.dart
enum Flavor { dev, prod }

class AppConfig {
  final Flavor flavor;
  final String? supabaseUrl;
  final String? supabaseAnonKey;

  const AppConfig({
    required this.flavor,
    this.supabaseUrl,
    this.supabaseAnonKey,
  });

  static late final AppConfig instance;

  bool get isProduction => flavor == Flavor.prod;
}
```

## Entry Points

### main_dev.dart

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.instance = const AppConfig(flavor: Flavor.dev);
  await initHive();
  tz.initializeTimeZones();
  setupDevDependencies();
  runApp(const TodoApp());
}
```

### main_prod.dart
```dart
Future<void> main() async {
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

**Run with secrets via `--dart-define`:**
```
flutter run -t lib/main_prod.dart \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

Shared helpers (`initHive` — registers adapters + opens boxes) extracted to `lib/core/init/app_init.dart`.

`TodoApp` widget extracted from `main.dart` to `lib/app.dart` so both entry points can import it.

## DI Setup

Split `injection.dart`.

Note: the current `setupDependencies()` is `async` but contains no `await` calls, so the new functions are synchronous `void`. This is a safe change.

```dart
// Shared — notification datasource (always local, both flavors)
void _registerNotificationDatasource() {
  sl.registerLazySingleton<NotificationLocalDatasource>(
    () => NotificationLocalDatasourceImpl(FlutterLocalNotificationsPlugin()),
  );
}

// Shared — repositories (same impls, wired to whatever datasource is registered)
void _registerRepositories() { ... }

// Shared — use cases + BLoCs (depend on repository interfaces)
void _registerUseCasesAndBlocs() { ... }

// Dev: register Hive datasources as the implementations
void setupDevDependencies() {
  _registerLocalDatasources();  // task, category, tag
  _registerNotificationDatasource();
  _registerRepositories();
  _registerUseCasesAndBlocs();
}

// Prod: register Hive datasources under a named key for caching,
// then register remote datasources as the primary implementations
void setupProdDependencies() {
  // Register local datasources under named instances (for cache usage)
  sl.registerLazySingleton<TaskLocalDatasource>(
    () => TaskLocalDatasourceImpl(Hive.box<TaskModel>('tasks')),
    instanceName: 'local',
  );
  // ... same for category, tag

  // Register remote datasources as the primary datasource implementations
  sl.registerLazySingleton<TaskLocalDatasource>(
    () => TaskRemoteDatasourceImpl(
      Supabase.instance.client,
      sl<TaskLocalDatasource>(instanceName: 'local'),
    ),
  );
  // ... same for category, tag

  _registerNotificationDatasource();
  _registerRepositories();
  _registerUseCasesAndBlocs();
}
```

## Supabase Table Schema

```sql
-- tasks
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  due_date TIMESTAMPTZ,
  priority INTEGER NOT NULL DEFAULT 0,
  category_id TEXT,
  tags TEXT[] DEFAULT '{}',
  parent_task_id TEXT,
  completed_at TIMESTAMPTZ,
  recurrence_type INTEGER,
  recurrence_interval INTEGER,
  recurrence_days_of_week INTEGER[],
  recurrence_end_date TIMESTAMPTZ
);

-- categories
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  "order" INTEGER NOT NULL DEFAULT 0
);

-- tags
CREATE TABLE tags (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL
);
```

Recurrence fields are flattened into the tasks table (nullable columns) rather than a separate table — keeps it simple and matches the current embedded model structure.

## New Dependency

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.8.0
```

## File Structure (new/modified files)

```
lib/
  app.dart                         # NEW — TodoApp widget (extracted from main.dart)
  core/
    config/
      app_config.dart              # NEW — Flavor enum + AppConfig
    init/
      app_init.dart                # NEW — shared Hive init (registerAdapters + openBoxes)
    di/
      injection.dart               # MODIFIED — split into dev/prod setup
  data/
    datasources/
      remote/
        task_remote_datasource.dart      # NEW
        category_remote_datasource.dart  # NEW
        tag_remote_datasource.dart       # NEW
  main_dev.dart                    # NEW (extracted from main.dart)
  main_prod.dart                   # NEW
  main.dart                        # DELETED (replaced by entry points)
```
