import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/constants/app_strings.dart';
import 'package:todo_app/features/categories/domain/category_model.dart';
import 'package:todo_app/core/theme/theme_cubit.dart';
import 'package:todo_app/features/categories/cubit/category_cubit.dart';
import 'package:todo_app/features/todos/bloc/todo_bloc.dart';
import 'package:todo_app/features/todos/bloc/todo_event.dart';
import 'package:todo_app/features/todos/bloc/todo_state.dart';
import 'package:todo_app/features/todos/widget/filter_bar.dart';
import 'package:todo_app/features/todos/widget/search_bar_widget.dart';
import 'package:todo_app/features/todos/widget/todo_empty_state.dart';
import 'package:todo_app/features/todos/widget/todo_list_tile.dart';
import 'package:todo_app/common/widgets/animated_fab.dart';

class HomeView extends StatelessWidget {
  final int tab;
  const HomeView({super.key, required this.tab});

  bool get _isActive => tab == 0;

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isActive ? AppStrings.todos : AppStrings.completed),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => context.read<ThemeCubit>().toggle(),
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      floatingActionButton: _isActive
          ? AnimatedFab(
              onPressed: () => context.push('/todo/add'),
              tooltip: AppStrings.addTodo,
            )
          : null,
      body: Column(
        children: [
          if (_isActive) ...[
            SearchBarWidget(
              onChanged: (q) => context.read<TodoBloc>().add(SearchChanged(q)),
            ),
            BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                final cats = state is CategoryLoaded ? state.categories : <Category>[];
                return FilterBar(categories: cats);
              },
            ),
          ],
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TodoError) {
                  return Center(child: Text(state.message));
                }
                if (state is TodoLoaded) {
                  final todos =
                      _isActive ? state.activeTodos : state.completedTodos;

                  if (todos.isEmpty) {
                    if (_isActive) {
                      final hasFilter = state.filter.searchQuery.isNotEmpty ||
                          state.filter.priority != null ||
                          state.filter.categoryId != null;
                      return TodoEmptyState(
                        title: hasFilter
                            ? AppStrings.noSearchResults
                            : AppStrings.noTodosActive,
                        subtitle: hasFilter
                            ? 'Try different filters'
                            : AppStrings.addFirstTodo,
                        icon: hasFilter
                            ? Icons.search_off_rounded
                            : Icons.add_task_rounded,
                      );
                    }
                    return const TodoEmptyState(
                      title: AppStrings.noTodosCompleted,
                      subtitle: 'Complete your todos to see them here',
                      icon: Icons.check_circle_outline_rounded,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 88),
                    itemCount: todos.length,
                    itemBuilder: (context, index) => TodoListTile(
                      todo: todos[index],
                      index: index,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
