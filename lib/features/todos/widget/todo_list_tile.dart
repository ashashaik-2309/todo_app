import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/utils/priority_utils.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';
import 'package:todo_app/features/todos/cubit/todo_cubit.dart';
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
    final priorityColor = PriorityUtils.color(todo.priority);
    final dimmed = todo.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable(
        key: ValueKey(todo.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            SlidableAction(
              onPressed: (_) =>
                  context.read<TodoCubit>().toggleComplete(todo.id),
              backgroundColor:
                  todo.isCompleted ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              icon: todo.isCompleted
                  ? Icons.undo_rounded
                  : Icons.check_rounded,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            SlidableAction(
              onPressed: (_) async {
                final confirm = await ConfirmDeleteDialog.show(context);
                if (confirm && context.mounted) {
                  context.read<TodoCubit>().deleteTodo(todo.id);
                }
              },
              backgroundColor: scheme.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline_rounded,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: Material(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          elevation: dimmed ? 0 : 1,
          shadowColor: priorityColor.withValues(alpha: 0.15),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/todo/${todo.id}'),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Priority colour strip
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: dimmed
                          ? scheme.outlineVariant
                          : priorityColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),

                  // Checkbox
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12, right: 4, top: 14, bottom: 14),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: todo.isCompleted,
                        onChanged: (_) =>
                            context.read<TodoCubit>().toggleComplete(todo.id),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(6, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            todo.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: dimmed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor:
                                      scheme.onSurface.withValues(alpha: 0.4),
                                  color: dimmed
                                      ? scheme.onSurface.withValues(alpha: 0.38)
                                      : scheme.onSurface,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Description
                          if (todo.description != null &&
                              todo.description!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              todo.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: dimmed
                                        ? scheme.onSurfaceVariant
                                            .withValues(alpha: 0.45)
                                        : scheme.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const SizedBox(height: 8),

                          // Badges row
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              PriorityChip(
                                  priority: todo.priority, compact: true),
                              DueDateBadge(
                                dueDate: todo.dueDate,
                                isCompleted: todo.isCompleted,
                              ),
                              ...todo.tags.take(2).map((tag) => _TagChip(
                                    tag: tag,
                                    dimmed: dimmed,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .slideX(
          begin: 0.2,
          duration: 280.ms,
          delay: (index * 35).ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: 280.ms, delay: (index * 35).ms);
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  final bool dimmed;

  const _TagChip({required this.tag, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: dimmed
            ? scheme.secondaryContainer.withValues(alpha: 0.45)
            : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: dimmed
              ? scheme.onSecondaryContainer.withValues(alpha: 0.45)
              : scheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
