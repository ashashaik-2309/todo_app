import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, unique: true)
  late String name;

  late int colorValue;
  late int iconCodePoint;

  DateTime createdAt = DateTime.now();
}
