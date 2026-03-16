import 'package:flutter/material.dart';
import 'package:test_app/domain/entities/priority.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final Priority priority;

  Color get _color => switch (priority) {
        Priority.high => Colors.red,
        Priority.medium => Colors.orange,
        Priority.low => Colors.blue,
        Priority.none => Colors.grey,
      };

  String get _label => switch (priority) {
        Priority.high => 'High',
        Priority.medium => 'Medium',
        Priority.low => 'Low',
        Priority.none => '',
      };

  @override
  Widget build(BuildContext context) {
    if (priority == Priority.none) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color, width: 1),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
