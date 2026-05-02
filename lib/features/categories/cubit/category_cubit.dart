import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/categories/data/category_repository.dart';
import 'package:todo_app/features/categories/domain/category_model.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;
  StreamSubscription<List<Category>>? _subscription;

  CategoryCubit(this._repository) : super(const CategoryInitial()) {
    _load();
  }

  void _load() {
    emit(const CategoryLoading());
    _subscription = _repository.watchAll().listen(
      (cats) => emit(CategoryLoaded(cats)),
      onError: (e) => emit(CategoryError(e.toString())),
    );
  }

  Future<void> addCategory(Category category) async {
    try {
      await _repository.create(category);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _repository.update(category);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _repository.delete(id);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
