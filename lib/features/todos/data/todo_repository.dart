import 'package:isar/isar.dart';
import 'package:todo_app/core/database/isar_service.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

class TodoRepository {
  Isar get _isar => IsarService.instance;

  Stream<List<Todo>> watchAll() {
    return _isar.todos.where().watch(fireImmediately: true);
  }

  Future<List<Todo>> getAll() => _isar.todos.where().findAll();

  Future<Todo?> getById(int id) => _isar.todos.get(id);

  Future<int> create(Todo todo) async {
    return _isar.writeTxn(() => _isar.todos.put(todo));
  }

  Future<void> update(Todo todo) async {
    todo.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.todos.put(todo));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.todos.delete(id));
  }

  Future<void> toggleComplete(int id) async {
    final todo = await _isar.todos.get(id);
    if (todo == null) return;
    todo.isCompleted = !todo.isCompleted;
    todo.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.todos.put(todo));
  }
}
