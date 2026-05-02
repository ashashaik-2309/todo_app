import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

class TodoRepository {
  Box<Todo> get _box => Hive.box<Todo>('todos');

  Stream<List<Todo>> watchAll() async* {
    yield _box.values.toList();
    await for (final _ in _box.watch()) {
      yield _box.values.toList();
    }
  }

  Future<List<Todo>> getAll() async => _box.values.toList();

  Future<Todo?> getById(int id) async => _box.get(id);

  Future<void> create(Todo todo) async {
    await _box.add(todo);
  }

  Future<void> update(Todo todo) async {
    todo.updatedAt = DateTime.now();
    await todo.save();
  }

  Future<void> delete(int id) async {
    await _box.delete(id);
  }

  Future<void> toggleComplete(int id) async {
    final todo = _box.get(id);
    if (todo == null) return;
    todo.isCompleted = !todo.isCompleted;
    todo.updatedAt = DateTime.now();
    await todo.save();
  }
}
