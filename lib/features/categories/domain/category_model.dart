import 'package:hive_flutter/hive_flutter.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  int get id => key as int;

  @HiveField(0)
  late String name;

  @HiveField(1)
  late int colorValue;

  @HiveField(2)
  late int iconCodePoint;

  @HiveField(3)
  DateTime createdAt = DateTime.now();
}
