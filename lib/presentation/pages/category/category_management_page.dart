import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tasker/domain/entities/category.dart';
import 'package:tasker/presentation/blocs/category/category_bloc.dart';
import 'package:tasker/presentation/blocs/category/category_event.dart';
import 'package:tasker/presentation/blocs/category/category_state.dart';
import 'package:tasker/presentation/widgets/empty_state.dart';
import 'package:uuid/uuid.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CategoryError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is CategoryLoaded) {
          final categories = state.categories;

          if (categories.isEmpty) {
            return const EmptyState(
              icon: Icons.category_outlined,
              title: 'No categories yet',
              subtitle: 'Tap + to add one',
            );
          }

          return ReorderableListView.builder(
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex -= 1;
              final reordered = List<String>.from(categories.map((c) => c.id));
              final id = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, id);
              context.read<CategoryBloc>().add(ReorderCategories(reordered));
            },
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryTile(
                key: ValueKey(category.id),
                category: category,
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  static void showAddDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _CategoryDialog(
        onSave: (name, color) {
          final category = Category(
            id: const Uuid().v4(),
            name: name,
            color: color.toARGB32(),
            createdAt: DateTime.now(),
            order: 0,
          );
          context.read<CategoryBloc>().add(CreateCategoryEvent(category));
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    return Slidable(
      key: ValueKey(category.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showEditDialog(context),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => _confirmDelete(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 14),
        title: Text(category.name),
        trailing: const Icon(Icons.drag_handle, color: Colors.grey),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _CategoryDialog(
        initialName: category.name,
        initialColor: Color(category.color),
        onSave: (name, color) {
          final updated = category.copyWith(
            name: name,
            color: color.toARGB32(),
          );
          context.read<CategoryBloc>().add(UpdateCategoryEvent(updated));
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<CategoryBloc>().add(DeleteCategoryEvent(category.id));
    }
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({
    this.initialName = '',
    this.initialColor = Colors.blue,
    required this.onSave,
  });

  final String initialName;
  final Color initialColor;
  final void Function(String name, Color color) onSave;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _nameController;
  late Color _selectedColor;

  static const _colorOptions = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialName.isEmpty ? 'Add Category' : 'Edit Category',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorOptions.map((color) {
              final isSelected = color.toARGB32() == _selectedColor.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 2.5)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            widget.onSave(name, _selectedColor);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
