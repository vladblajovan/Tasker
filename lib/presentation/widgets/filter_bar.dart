import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasker/domain/entities/category.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/tag.dart';
import 'package:tasker/presentation/blocs/category/category_bloc.dart';
import 'package:tasker/presentation/blocs/category/category_state.dart';
import 'package:tasker/presentation/blocs/tag/tag_bloc.dart';
import 'package:tasker/presentation/blocs/tag/tag_state.dart';
import 'package:tasker/presentation/blocs/task/task_bloc.dart';
import 'package:tasker/presentation/blocs/task/task_event.dart';

class FilterBar extends StatefulWidget {
  const FilterBar({super.key});

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  String? _selectedCategoryId;
  List<String> _selectedTagIds = [];
  Priority? _selectedPriority;

  bool get _hasActiveFilters =>
      _selectedCategoryId != null ||
      _selectedTagIds.isNotEmpty ||
      _selectedPriority != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildCategoryDropdown(),
          const SizedBox(width: 8),
          _buildTagDropdown(),
          const SizedBox(width: 8),
          _buildPriorityDropdown(),
          if (_hasActiveFilters) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: _clearFilters,
              tooltip: 'Clear filters',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = state is CategoryLoaded
            ? state.categories
            : <Category>[];
        return DropdownButton<String?>(
          value: _selectedCategoryId,
          hint: const Text('Category'),
          underline: const SizedBox.shrink(),
          isDense: true,
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Categories'),
            ),
            ...categories.map(
              (c) => DropdownMenuItem<String?>(
                value: c.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(c.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(c.name),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() => _selectedCategoryId = value);
            _dispatchFilter();
          },
        );
      },
    );
  }

  Widget _buildTagDropdown() {
    return BlocBuilder<TagBloc, TagState>(
      builder: (context, state) {
        final tags = state is TagLoaded ? state.tags : <Tag>[];
        return PopupMenuButton<String>(
          child: Chip(
            label: Text(
              _selectedTagIds.isEmpty
                  ? 'Tags'
                  : 'Tags (${_selectedTagIds.length})',
            ),
            visualDensity: VisualDensity.compact,
          ),
          itemBuilder: (context) => tags
              .map(
                (t) => CheckedPopupMenuItem<String>(
                  value: t.id,
                  checked: _selectedTagIds.contains(t.id),
                  child: Text(t.name),
                ),
              )
              .toList(),
          onSelected: (tagId) {
            setState(() {
              if (_selectedTagIds.contains(tagId)) {
                _selectedTagIds = _selectedTagIds
                    .where((id) => id != tagId)
                    .toList();
              } else {
                _selectedTagIds = [..._selectedTagIds, tagId];
              }
            });
            _dispatchFilter();
          },
        );
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButton<Priority?>(
      value: _selectedPriority,
      hint: const Text('Priority'),
      underline: const SizedBox.shrink(),
      isDense: true,
      items: [
        const DropdownMenuItem<Priority?>(
          value: null,
          child: Text('All Priorities'),
        ),
        ...Priority.values
            .where((p) => p != Priority.none)
            .map(
              (p) => DropdownMenuItem<Priority?>(
                value: p,
                child: Text(p.name[0].toUpperCase() + p.name.substring(1)),
              ),
            ),
      ],
      onChanged: (value) {
        setState(() => _selectedPriority = value);
        _dispatchFilter();
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedTagIds = [];
      _selectedPriority = null;
    });
    _dispatchFilter();
  }

  void _dispatchFilter() {
    context.read<TaskBloc>().add(
      FilterTasks(
        categoryId: _selectedCategoryId,
        tagIds: _selectedTagIds,
        priority: _selectedPriority,
      ),
    );
  }
}
