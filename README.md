# Tasker

A task management application built with Flutter.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Flavors and Running

This project uses Flutter flavors to support different environments.

### 🛠 Dev Flavor
Uses a local database (Hive) for development.

```bash
flutter run -t lib/main_dev.dart
```

### 🚀 Prod Flavor
Uses a remote database (Supabase) with local caching. Requires Supabase credentials provided via `--dart-define`.

```bash
flutter run -t lib/main_prod.dart \
  --dart-define=SUPABASE_URL=<YOUR_SUPABASE_URL> \
  --dart-define=SUPABASE_ANON_KEY=<YOUR_SUPABASE_ANON_KEY>
```

Replace `<YOUR_SUPABASE_URL>` and `<YOUR_SUPABASE_ANON_KEY>` with your project's credentials from the Supabase dashboard.
