import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasker/core/di/injection.dart';
import 'package:tasker/core/router/app_router.dart';
import 'package:tasker/core/theme/app_theme.dart';
import 'package:tasker/presentation/blocs/category/category_bloc.dart';
import 'package:tasker/presentation/blocs/notification/notification_bloc.dart';
import 'package:tasker/presentation/blocs/tag/tag_bloc.dart';
import 'package:tasker/presentation/blocs/task/task_bloc.dart';

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
