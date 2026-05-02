import 'package:flutter/material.dart';
import 'package:todo_app/core/constants/app_colors.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

class PriorityUtils {
  static Color color(Priority p) => priorityColors[p]!;
  static Color lightColor(Priority p) => priorityLightColors[p]!;

  static String label(Priority p) => switch (p) {
        Priority.high => 'High',
        Priority.medium => 'Medium',
        Priority.low => 'Low',
      };

  static IconData icon(Priority p) => switch (p) {
        Priority.high => Icons.keyboard_double_arrow_up_rounded,
        Priority.medium => Icons.drag_handle_rounded,
        Priority.low => Icons.keyboard_double_arrow_down_rounded,
      };
}
