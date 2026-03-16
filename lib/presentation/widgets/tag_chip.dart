import 'package:flutter/material.dart';
import 'package:test_app/domain/entities/tag.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.onTap,
  });

  final Tag tag;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          '#${tag.name}',
          style: TextStyle(
            color: selected ? Colors.white : primary,
            fontSize: 12,
          ),
        ),
        backgroundColor:
            selected ? primary : primary.withValues(alpha: 0.1),
        side: BorderSide(color: primary),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
