import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasker/presentation/blocs/task/task_bloc.dart';
import 'package:tasker/presentation/blocs/task/task_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is! TaskLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTasks = state.allTasks;
          final completedTasks = allTasks.where((t) => t.isCompleted).toList();
          final pendingTasks = allTasks.where((t) => !t.isCompleted).toList();

          if (allTasks.isEmpty) {
            return const Center(
              child: Text('No tasks to analyze yet.'),
            );
          }

          final completionRate = completedTasks.length / allTasks.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatCard(
                context,
                title: 'Total Tasks',
                value: allTasks.length.toString(),
                icon: Icons.checklist,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Completed',
                      value: completedTasks.length.toString(),
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Pending',
                      value: pendingTasks.length.toString(),
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Completion Rate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: completionRate,
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              Text(
                '${(completionRate * 100).toStringAsFixed(1)}%',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
