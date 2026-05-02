import 'package:isar/isar.dart';

part 'todo_model.g.dart';

enum Priority { low, medium, high }

@collection
class Todo {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title;

  String? description;

  @Enumerated(EnumType.name)
  Priority priority = Priority.medium;

  @Index(type: IndexType.value)
  bool isCompleted = false;

  DateTime? dueDate;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  @Index(type: IndexType.value)
  int categoryId = 0;

  List<String> tags = [];
}
