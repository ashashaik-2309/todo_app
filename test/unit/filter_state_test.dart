import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';
import 'package:todo_app/features/todos/presentation/bloc/todo_state.dart';

void main() {
  group('FilterState.copyWith', () {
    test('copies with new searchQuery', () {
      const original = FilterState(searchQuery: 'abc');
      final copy = original.copyWith(searchQuery: 'xyz');
      expect(copy.searchQuery, 'xyz');
      expect(copy.priority, isNull);
    });

    test('clears priority when null passed', () {
      const original = FilterState(priority: Priority.high);
      final cleared = original.copyWith(priority: null);
      expect(cleared.priority, isNull);
    });

    test('clears categoryId when null passed', () {
      const original = FilterState(categoryId: 5);
      final cleared = original.copyWith(categoryId: null);
      expect(cleared.categoryId, isNull);
    });
  });

  group('TodoLoaded sorting', () {
    test('sorts high priority before low priority', () {
      final low = Todo()
        ..title = 'Low'
        ..priority = Priority.low
        ..isCompleted = false;
      final high = Todo()
        ..title = 'High'
        ..priority = Priority.high
        ..isCompleted = false;

      final state = TodoLoaded(allTodos: [low, high]);
      expect(state.activeTodos.first.priority, Priority.high);
    });
  });
}
