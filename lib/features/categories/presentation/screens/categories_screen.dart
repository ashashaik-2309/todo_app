import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/constants/app_strings.dart';
import 'package:todo_app/features/categories/presentation/cubit/category_cubit.dart';
import 'package:todo_app/features/categories/presentation/widgets/add_edit_category_dialog.dart';
import 'package:todo_app/features/categories/presentation/widgets/category_list_tile.dart';
import 'package:todo_app/features/todos/presentation/widgets/todo_empty_state.dart';
import 'package:todo_app/shared/widgets/animated_fab.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.categories)),
      floatingActionButton: AnimatedFab(
        onPressed: () => AddEditCategoryDialog.show(context),
        tooltip: AppStrings.addCategory,
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryError) {
            return Center(child: Text(state.message));
          }
          if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return const TodoEmptyState(
                title: AppStrings.noCategoriesYet,
                subtitle: 'Tap + to add a category',
                icon: Icons.label_outline_rounded,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.categories.length,
              itemBuilder: (context, index) => CategoryListTile(
                category: state.categories[index],
                index: index,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
