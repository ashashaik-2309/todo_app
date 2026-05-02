import 'package:isar/isar.dart';
import 'package:todo_app/core/database/isar_service.dart';
import 'package:todo_app/features/categories/domain/category_model.dart';

class CategoryRepository {
  Isar get _isar => IsarService.instance;

  Stream<List<Category>> watchAll() {
    return _isar.categorys.where().watch(fireImmediately: true);
  }

  Future<List<Category>> getAll() => _isar.categorys.where().findAll();

  Future<Category?> getById(int id) => _isar.categorys.get(id);

  Future<int> create(Category category) async {
    return _isar.writeTxn(() => _isar.categorys.put(category));
  }

  Future<void> update(Category category) async {
    await _isar.writeTxn(() => _isar.categorys.put(category));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.categorys.delete(id));
  }
}
