import 'package:hive_flutter/hive_flutter.dart';

part 'todo_model.g.dart';

enum Priority { low, medium, high }

@HiveType(typeId: 0)
class Todo extends HiveObject {
  int get id => key as int;

  @HiveField(0)
  late String title;

  @HiveField(1)
  String? description;

  @HiveField(2)
  int priorityIndex = 1; // Priority.medium

  @HiveField(3)
  bool isCompleted = false;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  DateTime createdAt = DateTime.now();

  @HiveField(6)
  DateTime updatedAt = DateTime.now();

  @HiveField(7)
  int categoryId = -1; // -1 = uncategorized

  @HiveField(8)
  List<String> tags = [];

  Priority get priority => Priority.values[priorityIndex];
  set priority(Priority p) => priorityIndex = p.index;
}
