import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';
import 'package:todo_app/features/todos/bloc/todo_bloc.dart';
import 'package:todo_app/features/todos/bloc/todo_event.dart';
import 'package:todo_app/features/todos/widget/due_date_badge.dart';
import 'package:todo_app/features/todos/widget/priority_chip.dart';
import 'package:todo_app/common/widgets/confirm_delete_dialog.dart';

class TodoListTile extends StatelessWidget {
  final Todo todo;
  final int index;

  const TodoListTile({super.key, required this.todo, required this.index});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Slidable(
      key: ValueKey(todo.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) =>
                context.read<TodoBloc>().add(ToggleComplete(todo.id)),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: todo.isCompleted
                ? Icons.undo_rounded
                : Icons.check_rounded,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) async {
              final confirm =
                  await ConfirmDeleteDialog.show(context);
              if (confirm && context.mounted) {
                context.read<TodoBloc>().add(DeleteTodo(todo.id));
              }
            },
            backgroundColor: scheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/todo/${todo.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (_) =>
                          context.read<TodoBloc>().add(ToggleComplete(todo.id)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.isCompleted
                                  ? scheme.onSurface.withValues(alpha: 0.4)
                                  : null,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (todo.description != null &&
                          todo.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          todo.description!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          PriorityChip(priority: todo.priority, compact: true),
                          DueDateBadge(
                              dueDate: todo.dueDate,
                              isCompleted: todo.isCompleted),
                        ],
                      ),
                      if (todo.tags.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: todo.tags
                              .take(3)
                              .map((tag) => _TagChip(tag: tag))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .slideX(
          begin: 0.3,
          duration: 300.ms,
          delay: (index * 40).ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 300.ms, delay: (index * 40).ms);
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
