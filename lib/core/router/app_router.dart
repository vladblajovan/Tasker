import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/presentation/pages/category/category_management_page.dart';
import 'package:test_app/presentation/pages/home/home_page.dart';
import 'package:test_app/presentation/pages/search/search_page.dart';
import 'package:test_app/presentation/pages/tag/tag_management_page.dart';
import 'package:test_app/presentation/pages/task_detail/task_detail_page.dart';
import 'package:test_app/presentation/pages/task_form/task_form_page.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoryManagementPage(),
      ),
      GoRoute(
        path: '/tags',
        name: 'tags',
        builder: (context, state) => const TagManagementPage(),
      ),
      GoRoute(
        path: '/task/new',
        name: 'taskNew',
        builder: (context, state) => const TaskFormPage(),
      ),
      GoRoute(
        path: '/task/:id',
        name: 'taskDetail',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return TaskDetailPage(taskId: taskId);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: 'taskEdit',
            builder: (context, state) {
              final taskId = state.pathParameters['id']!;
              return TaskFormPage(taskId: taskId);
            },
          ),
          GoRoute(
            path: 'subtask/new',
            name: 'subtaskNew',
            builder: (context, state) {
              final parentTaskId = state.pathParameters['id']!;
              return TaskFormPage(parentTaskId: parentTaskId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
    ],
  );
}
