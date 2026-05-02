import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/constants/app_strings.dart';
import 'package:todo_app/core/utils/date_formatter.dart';
import 'package:todo_app/features/categories/cubit/category_cubit.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';
import 'package:todo_app/features/todos/cubit/todo_cubit.dart';
import 'package:todo_app/features/todos/widget/due_date_badge.dart';
import 'package:todo_app/features/todos/widget/priority_chip.dart';
import 'package:todo_app/common/widgets/confirm_delete_dialog.dart';

class TodoDetailView extends StatelessWidget {
  final int todoId;
  const TodoDetailView({super.key, required this.todoId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        if (state is! TodoLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final todo = state.allTodos.where((t) => t.id == todoId).firstOrNull;
        if (todo == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Todo not found')),
          );
        }

        return _TodoDetailContent(todo: todo);
      },
    );
  }
}

class _TodoDetailContent extends StatelessWidget {
  final Todo todo;
  const _TodoDetailContent({required this.todo});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: AppStrings.edit,
            onPressed: () {
              context.pop();
              context.push('/todo/edit', extra: todo);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
            tooltip: AppStrings.delete,
            onPressed: () async {
              final confirm = await ConfirmDeleteDialog.show(context);
              if (confirm && context.mounted) {
                context.read<TodoCubit>().deleteTodo(todo.id);
                context.pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) =>
                      context.read<TodoCubit>().toggleComplete(todo.id),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    todo.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration:
                              todo.isCompleted ? TextDecoration.lineThrough : null,
                          color: todo.isCompleted
                              ? scheme.onSurface.withValues(alpha: 0.4)
                              : null,
                        ),
                  ),
                ),
              ],
            ),
            if (todo.description != null && todo.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                todo.description!,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.flag_rounded,
              label: AppStrings.priority,
              child: PriorityChip(priority: todo.priority),
            ),
            if (todo.dueDate != null) ...[
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: AppStrings.dueDate,
                child: DueDateBadge(
                    dueDate: todo.dueDate, isCompleted: todo.isCompleted),
              ),
            ],
            const SizedBox(height: 12),
            _CategoryDetailRow(categoryId: todo.categoryId),
            if (todo.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.tag_rounded,
                label: AppStrings.tags,
                child: Wrap(
                  spacing: 6,
                  children: todo.tags
                      .map((tag) => Chip(
                            label: Text('#$tag',
                                style: const TextStyle(fontSize: 12)),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.access_time_rounded,
              label: 'Created',
              child: Text(
                DateFormatter.format(todo.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _DetailRow(
      {required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _CategoryDetailRow extends StatelessWidget {
  final int categoryId;
  const _CategoryDetailRow({required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        String name = AppStrings.uncategorized;
        Color? color;

        if (state is CategoryLoaded && categoryId != -1) {
          final cat =
              state.categories.where((c) => c.id == categoryId).firstOrNull;
          if (cat != null) {
            name = cat.name;
            color = Color(cat.colorValue);
          }
        }

        return _DetailRow(
          icon: Icons.label_outline_rounded,
          label: AppStrings.category,
          child: Row(
            children: [
              if (color != null) ...[
                CircleAvatar(radius: 6, backgroundColor: color),
                const SizedBox(width: 6),
              ],
              Text(name, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}
