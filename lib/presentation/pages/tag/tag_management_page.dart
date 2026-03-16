import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tasker/domain/entities/tag.dart';
import 'package:tasker/presentation/blocs/tag/tag_bloc.dart';
import 'package:tasker/presentation/blocs/tag/tag_event.dart';
import 'package:tasker/presentation/blocs/tag/tag_state.dart';
import 'package:uuid/uuid.dart';

class TagManagementPage extends StatelessWidget {
  const TagManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagBloc, TagState>(
      builder: (context, state) {
        if (state is TagLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TagError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is TagLoaded) {
          final tags = state.tags;

          if (tags.isEmpty) {
            return const Center(
              child: Text(
                'No tags yet.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return _TagTile(key: ValueKey(tag.id), tag: tag);
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
      builder: (ctx) => _TagDialog(
        onSave: (name) {
          final tag = Tag(
            id: const Uuid().v4(),
            name: name,
            createdAt: DateTime.now(),
          );
          context.read<TagBloc>().add(CreateTagEvent(tag));
        },
      ),
    );
  }
}

class _TagTile extends StatelessWidget {
  const _TagTile({super.key, required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(tag.id),
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
        leading: const Icon(Icons.label_outline),
        title: Text(tag.name),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _TagDialog(
        initialName: tag.name,
        onSave: (name) {
          final updated = tag.copyWith(name: name);
          context.read<TagBloc>().add(UpdateTagEvent(updated));
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Are you sure you want to delete "${tag.name}"?'),
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
      context.read<TagBloc>().add(DeleteTagEvent(tag.id));
    }
  }
}

class _TagDialog extends StatefulWidget {
  const _TagDialog({this.initialName = '', required this.onSave});

  final String initialName;
  final void Function(String name) onSave;

  @override
  State<_TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<_TagDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName.isEmpty ? 'Add Tag' : 'Edit Tag'),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Name',
          border: OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _submit(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.onSave(name);
    Navigator.of(context).pop();
  }
}
