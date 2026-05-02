import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/features/categories/domain/category_model.dart';

class CategoryRepository {
  Box<Category> get _box => Hive.box<Category>('categories');

  Stream<List<Category>> watchAll() async* {
    yield _box.values.toList();
    await for (final _ in _box.watch()) {
      yield _box.values.toList();
    }
  }

  Future<List<Category>> getAll() async => _box.values.toList();

  Future<Category?> getById(int id) async => _box.get(id);

  Future<void> create(Category category) async {
    await _box.add(category);
  }

  Future<void> update(Category category) async {
    await category.save();
  }

  Future<void> delete(int id) async {
    await _box.delete(id);
  }
}
