import 'package:flutter/material.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

const Color seedColor = Color(0xFF6750A4);

const Map<Priority, Color> priorityColors = {
  Priority.high: Color(0xFFE53935),
  Priority.medium: Color(0xFFFB8C00),
  Priority.low: Color(0xFF43A047),
};

const Map<Priority, Color> priorityLightColors = {
  Priority.high: Color(0xFFFFEBEE),
  Priority.medium: Color(0xFFFFF3E0),
  Priority.low: Color(0xFFE8F5E9),
};

const List<Color> categoryPalette = [
  Color(0xFF1565C0),
  Color(0xFF2E7D32),
  Color(0xFFE65100),
  Color(0xFF6A1B9A),
  Color(0xFF00695C),
  Color(0xFFC62828),
  Color(0xFF4527A0),
  Color(0xFF283593),
];
