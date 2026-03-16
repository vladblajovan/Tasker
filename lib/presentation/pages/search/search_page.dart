import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/presentation/blocs/task/task_bloc.dart';
import 'package:test_app/presentation/blocs/task/task_state.dart';
import 'package:test_app/presentation/widgets/task_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  List<Task> _filterTasks(List<Task> allTasks) {
    if (_query.isEmpty) return [];
    return allTasks.where((task) {
      if (task.title.toLowerCase().contains(_query)) return true;
      if (task.description != null &&
          task.description!.toLowerCase().contains(_query)) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search tasks…',
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (_query.isEmpty) {
            return const Center(
              child: Text(
                'Start typing to search tasks.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Task> results = [];
          if (state is TaskLoaded) {
            results = _filterTasks(state.allTasks);
          }

          if (results.isEmpty) {
            return Center(
              child: Text(
                'No tasks found for "$_query".',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final task = results[index];
              return TaskTile(
                task: task,
                onTap: () => context.push('/task/${task.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
