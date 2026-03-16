import 'package:flutter/material.dart';
import 'package:test_app/domain/entities/category.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          category.name,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontSize: 12,
          ),
        ),
        backgroundColor:
            selected ? color : color.withValues(alpha: 0.1),
        side: BorderSide(color: color),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
