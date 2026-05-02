import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/features/categories/domain/category_model.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

class IsarService {
  IsarService._();

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoAdapter());
    Hive.registerAdapter(CategoryAdapter());
    await Hive.openBox<Todo>('todos');
    await Hive.openBox<Category>('categories');
    await _seedCategories();
  }

  static Future<void> _seedCategories() async {
    final box = Hive.box<Category>('categories');
    if (box.isNotEmpty) return;

    final defaults = [
      Category()
        ..name = 'Personal'
        ..colorValue = 0xFF1565C0
        ..iconCodePoint = Icons.person_rounded.codePoint,
      Category()
        ..name = 'Work'
        ..colorValue = 0xFFE65100
        ..iconCodePoint = Icons.work_rounded.codePoint,
      Category()
        ..name = 'Shopping'
        ..colorValue = 0xFF2E7D32
        ..iconCodePoint = Icons.shopping_cart_rounded.codePoint,
    ];

    for (final cat in defaults) {
      await box.add(cat);
    }
  }
}
