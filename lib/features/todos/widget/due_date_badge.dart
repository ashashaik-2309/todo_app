import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:todo_app/core/utils/date_formatter.dart';

class DueDateBadge extends StatelessWidget {
  final DateTime? dueDate;
  final bool isCompleted;

  const DueDateBadge({super.key, this.dueDate, this.isCompleted = false});

  @override
  Widget build(BuildContext context) {
    if (dueDate == null) return const SizedBox.shrink();

    final overdue = !isCompleted && DateFormatter.isOverdue(dueDate);
    final label = DateFormatter.relativeLabel(dueDate);

    final color = overdue
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.outline;

    Widget badge = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_rounded, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ],
    );

    if (overdue) {
      badge = badge
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1200.ms, color: Theme.of(context).colorScheme.errorContainer);
    }

    return badge;
  }
}
