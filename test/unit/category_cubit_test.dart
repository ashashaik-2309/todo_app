import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/categories/data/category_repository.dart';
import 'package:todo_app/features/categories/domain/category_model.dart';
import 'package:todo_app/features/categories/presentation/cubit/category_cubit.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class FakeCategory extends Fake implements Category {}

void main() {
  setUpAll(() => registerFallbackValue(FakeCategory()));

  late MockCategoryRepository repo;
  late StreamController<List<Category>> controller;

  setUp(() {
    repo = MockCategoryRepository();
    controller = StreamController<List<Category>>.broadcast();
    when(() => repo.watchAll()).thenAnswer((_) => controller.stream);
    when(() => repo.create(any())).thenAnswer((_) async => 1);
    when(() => repo.update(any())).thenAnswer((_) async {});
    when(() => repo.delete(any())).thenAnswer((_) async {});
  });

  tearDown(() => controller.close());

  test('emits CategoryLoading on init', () {
    final cubit = CategoryCubit(repo);
    expect(cubit.state, isA<CategoryLoading>());
    cubit.close();
  });

  test('emits CategoryLoaded when stream fires', () async {
    final cubit = CategoryCubit(repo);
    final states = <CategoryState>[];
    final sub = cubit.stream.listen(states.add);

    final cat = Category()
      ..name = 'Work'
      ..colorValue = 0xFF1565C0
      ..iconCodePoint = 0xe8d2;
    controller.add([cat]);
    await Future.delayed(const Duration(milliseconds: 50));

    expect(states.last, isA<CategoryLoaded>());
    expect((states.last as CategoryLoaded).categories.first.name, 'Work');

    await sub.cancel();
    await cubit.close();
  });

  test('addCategory calls repository.create', () async {
    final cubit = CategoryCubit(repo);
    final cat = Category()
      ..name = 'Personal'
      ..colorValue = 0xFF1565C0
      ..iconCodePoint = 0xe7fd;

    await cubit.addCategory(cat);
    verify(() => repo.create(any())).called(1);
    await cubit.close();
  });

  test('deleteCategory calls repository.delete', () async {
    final cubit = CategoryCubit(repo);
    await cubit.deleteCategory(1);
    verify(() => repo.delete(1)).called(1);
    await cubit.close();
  });
}
