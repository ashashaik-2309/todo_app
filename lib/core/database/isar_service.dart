import 'package:flutter/foundation.dart' hide Category;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/features/categories/domain/category_model.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

class IsarService {
  IsarService._();

  static Isar? _isar;

  static Isar get instance {
    assert(_isar != null, 'IsarService.init() must be called before use');
    return _isar!;
  }

  static Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;

    final dir = kIsWeb ? '' : (await getApplicationDocumentsDirectory()).path;

    _isar = await Isar.open(
      [TodoSchema, CategorySchema],
      directory: dir,
    );

    await _seedCategories();
  }

  static Future<void> _seedCategories() async {
    final count = await _isar!.categorys.count();
    if (count > 0) return;

    final defaults = [
      Category()
        ..name = 'Personal'
        ..colorValue = 0xFF1565C0
        ..iconCodePoint = 0xe7fd,
      Category()
        ..name = 'Work'
        ..colorValue = 0xFFE65100
        ..iconCodePoint = 0xe8d2,
      Category()
        ..name = 'Shopping'
        ..colorValue = 0xFF2E7D32
        ..iconCodePoint = 0xe8cc,
    ];

    await _isar!.writeTxn(() async {
      for (final cat in defaults) {
        await _isar!.categorys.put(cat);
      }
    });
  }
}
