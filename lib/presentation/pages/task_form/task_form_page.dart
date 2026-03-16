import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:test_app/domain/entities/category.dart';
import 'package:test_app/domain/entities/priority.dart';
import 'package:test_app/domain/entities/recurrence.dart';
import 'package:test_app/domain/entities/tag.dart';
import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/presentation/blocs/category/category_bloc.dart';
import 'package:test_app/presentation/blocs/category/category_state.dart';
import 'package:test_app/presentation/blocs/tag/tag_bloc.dart';
import 'package:test_app/presentation/blocs/tag/tag_state.dart';
import 'package:test_app/presentation/blocs/task/task_bloc.dart';
import 'package:test_app/presentation/blocs/task/task_event.dart';
import 'package:test_app/presentation/blocs/task/task_state.dart';
import 'package:test_app/presentation/widgets/recurrence_picker.dart';

enum _TaskFormMode { create, edit, createSubtask }

class TaskFormPage extends StatefulWidget {
  /// Pass [taskId] for edit mode, [parentTaskId] for create-subtask mode,
  /// or neither for plain create mode.
  const TaskFormPage({super.key, this.taskId, this.parentTaskId});

  final String? taskId;
  final String? parentTaskId;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Priority _priority = Priority.none;
  String? _categoryId;
  List<String> _selectedTagIds = [];
  DateTime? _dueDate;
  Recurrence? _recurrence;
  Task? _existingTask;

  _TaskFormMode get _mode {
    if (widget.taskId != null) return _TaskFormMode.edit;
    if (widget.parentTaskId != null) return _TaskFormMode.createSubtask;
    return _TaskFormMode.create;
  }

  String get _appBarTitle => switch (_mode) {
        _TaskFormMode.create => 'New Task',
        _TaskFormMode.edit => 'Edit Task',
        _TaskFormMode.createSubtask => 'New Subtask',
      };

  @override
  void initState() {
    super.initState();
    if (_mode == _TaskFormMode.edit && widget.taskId != null) {
      _loadExistingTask();
    }
  }

  void _loadExistingTask() {
    final taskState = context.read<TaskBloc>().state;
    if (taskState is TaskLoaded) {
      _existingTask = taskState.allTasks
          .where((t) => t.id == widget.taskId)
          .firstOrNull;
      if (_existingTask != null) {
        _titleController.text = _existingTask!.title;
        _descriptionController.text = _existingTask!.description ?? '';
        _priority = _existingTask!.priority;
        _categoryId = _existingTask!.categoryId;
        _selectedTagIds = List.from(_existingTask!.tags);
        _dueDate = _existingTask!.dueDate;
        _recurrence = _existingTask!.recurrence;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final rawDesc = _descriptionController.text.trim();
    final description = rawDesc.isEmpty ? null : rawDesc;

    switch (_mode) {
      case _TaskFormMode.create:
        final task = Task(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: description,
          createdAt: now,
          updatedAt: now,
          dueDate: _dueDate,
          priority: _priority,
          categoryId: _categoryId,
          tags: _selectedTagIds,
          recurrence: _recurrence,
        );
        context.read<TaskBloc>().add(CreateTaskEvent(task));

      case _TaskFormMode.edit:
        if (_existingTask != null) {
          final updated = _existingTask!.copyWith(
            title: _titleController.text.trim(),
            description: description,
            priority: _priority,
            categoryId: _categoryId,
            tags: _selectedTagIds,
            dueDate: _dueDate,
            recurrence: _recurrence,
            updatedAt: now,
          );
          context.read<TaskBloc>().add(UpdateTaskEvent(updated));
        }

      case _TaskFormMode.createSubtask:
        final subtask = Task(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: description,
          createdAt: now,
          updatedAt: now,
          dueDate: _dueDate,
          priority: _priority,
          categoryId: _categoryId,
          tags: _selectedTagIds,
          parentTaskId: widget.parentTaskId,
          recurrence: _recurrence,
        );
        context.read<TaskBloc>().add(CreateTaskEvent(subtask));
    }

    context.pop();
  }

  Widget _buildCategoryPicker() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories =
            state is CategoryLoaded ? state.categories : <Category>[];
        return DropdownButtonFormField<String?>(
          initialValue: _categoryId,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('None'),
            ),
            ...categories.map(
              (c) => DropdownMenuItem<String?>(
                value: c.id,
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(c.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(c.name),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _categoryId = value),
        );
      },
    );
  }

  Widget _buildTagMultiSelect() {
    return BlocBuilder<TagBloc, TagState>(
      builder: (context, state) {
        final tags = state is TagLoaded ? state.tags : <Tag>[];
        return InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Tags',
            border: OutlineInputBorder(),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: tags.map((tag) {
              final selected = _selectedTagIds.contains(tag.id);
              return FilterChip(
                label: Text(tag.name),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedTagIds.add(tag.id);
                    } else {
                      _selectedTagIds.remove(tag.id);
                    }
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDueDatePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        _dueDate != null
            ? 'Due: ${DateFormat.yMMMd().format(_dueDate!)}'
            : 'No due date',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_dueDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() => _dueDate = null),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dueDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _dueDate = picked);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Priority>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: Priority.values
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        p.name[0].toUpperCase() + p.name.substring(1),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildCategoryPicker(),
            const SizedBox(height: 16),
            _buildTagMultiSelect(),
            const SizedBox(height: 16),
            _buildDueDatePicker(),
            const SizedBox(height: 16),
            RecurrencePicker(
              initialRecurrence: _recurrence,
              onChanged: (value) => setState(() => _recurrence = value),
            ),
          ],
        ),
      ),
    );
  }
}
