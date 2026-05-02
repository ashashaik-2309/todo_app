import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/constants/app_strings.dart';
import 'package:todo_app/core/utils/date_formatter.dart';
import 'package:todo_app/core/utils/priority_utils.dart';
import 'package:todo_app/features/categories/domain/category_model.dart';
import 'package:todo_app/features/categories/presentation/cubit/category_cubit.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';
import 'package:todo_app/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:todo_app/features/todos/presentation/bloc/todo_event.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo? todo;
  const AddEditTodoScreen({super.key, this.todo});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late Priority _priority;
  DateTime? _dueDate;
  int _categoryId = 0;
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    final t = widget.todo;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _priority = t?.priority ?? Priority.medium;
    _dueDate = t?.dueDate;
    _categoryId = t?.categoryId ?? 0;
    if (t != null) _tags.addAll(t.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final todo = (widget.todo ?? Todo())
      ..title = _titleController.text.trim()
      ..description =
          _descController.text.trim().isEmpty ? null : _descController.text.trim()
      ..priority = _priority
      ..dueDate = _dueDate
      ..categoryId = _categoryId
      ..tags = List.from(_tags);

    if (_isEditing) {
      context.read<TodoBloc>().add(UpdateTodo(todo));
    } else {
      context.read<TodoBloc>().add(AddTodo(todo));
    }
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _addTag(String value) {
    final tag = value.trim().replaceAll('#', '');
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _tagController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editTodo : AppStrings.addTodo),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              AppStrings.save,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
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
                labelText: AppStrings.todoTitle,
                prefixIcon: Icon(Icons.title_rounded),
              ),
              autofocus: !_isEditing,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? AppStrings.titleRequired : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: AppStrings.todoDescription,
                prefixIcon: Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            _SectionLabel(label: AppStrings.priority),
            const SizedBox(height: 8),
            _PrioritySelector(
              selected: _priority,
              onChanged: (p) => setState(() => _priority = p),
            ),
            const SizedBox(height: 20),
            _SectionLabel(label: AppStrings.dueDate),
            const SizedBox(height: 8),
            _DatePickerField(
              dueDate: _dueDate,
              onPick: _pickDate,
              onClear: () => setState(() => _dueDate = null),
            ),
            const SizedBox(height: 20),
            _SectionLabel(label: AppStrings.category),
            const SizedBox(height: 8),
            BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                final cats = state is CategoryLoaded ? state.categories : <Category>[];
                return _CategoryDropdown(
                  categories: cats,
                  selectedId: _categoryId,
                  onChanged: (id) => setState(() => _categoryId = id),
                );
              },
            ),
            const SizedBox(height: 20),
            _SectionLabel(label: AppStrings.tags),
            const SizedBox(height: 8),
            _TagInput(
              tags: _tags,
              controller: _tagController,
              onAdd: _addTag,
              onRemove: (tag) => setState(() => _tags.remove(tag)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final Priority selected;
  final ValueChanged<Priority> onChanged;

  const _PrioritySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Priority.values.map((p) {
        final isSelected = p == selected;
        final color = PriorityUtils.color(p);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: isSelected ? null : Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onChanged(p),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Icon(PriorityUtils.icon(p),
                          size: 18,
                          color: isSelected ? Colors.white : color),
                      const SizedBox(height: 4),
                      Text(
                        PriorityUtils.label(p),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? dueDate;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _DatePickerField({
    required this.dueDate,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today_rounded),
          suffixIcon: dueDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: onClear,
                )
              : null,
        ),
        child: Text(
          dueDate != null ? DateFormatter.format(dueDate!) : 'No due date',
          style: TextStyle(
            color: dueDate != null
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final List<Category> categories;
  final int selectedId;
  final ValueChanged<int> onChanged;

  const _CategoryDropdown({
    required this.categories,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: selectedId,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.label_outline_rounded),
      ),
      items: [
        const DropdownMenuItem(
          value: 0,
          child: Text(AppStrings.uncategorized),
        ),
        ...categories.map(
          (cat) => DropdownMenuItem(
            value: cat.id,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 8,
                  backgroundColor: Color(cat.colorValue),
                ),
                const SizedBox(width: 8),
                Text(cat.name),
              ],
            ),
          ),
        ),
      ],
      onChanged: (v) => onChanged(v ?? 0),
    );
  }
}

class _TagInput extends StatelessWidget {
  final List<String> tags;
  final TextEditingController controller;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _TagInput({
    required this.tags,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            ...tags.map((tag) => Chip(
                  label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => onRemove(tag),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )),
          ],
        ),
        if (tags.isNotEmpty) const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: AppStrings.addTag,
            prefixIcon: Icon(Icons.tag_rounded, size: 18),
          ),
          onSubmitted: onAdd,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
