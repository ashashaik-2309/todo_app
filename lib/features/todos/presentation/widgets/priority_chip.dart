import 'package:flutter/material.dart';
import 'package:todo_app/core/utils/priority_utils.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

class PriorityChip extends StatelessWidget {
  final Priority priority;
  final bool compact;

  const PriorityChip({super.key, required this.priority, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = PriorityUtils.color(priority);
    final lightColor = PriorityUtils.lightColor(priority);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PriorityUtils.icon(priority), size: compact ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            PriorityUtils.label(priority),
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
