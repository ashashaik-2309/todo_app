import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/router/app_router.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/core/theme/theme_cubit.dart';
import 'package:todo_app/features/categories/data/category_repository.dart';
import 'package:todo_app/features/categories/cubit/category_cubit.dart';
import 'package:todo_app/features/todos/data/todo_repository.dart';
import 'package:todo_app/features/todos/bloc/todo_bloc.dart';
import 'package:todo_app/features/todos/bloc/todo_event.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()..init()),
        BlocProvider(
          create: (_) => TodoBloc(TodoRepository())..add(const LoadTodos()),
        ),
        BlocProvider(
          create: (_) => CategoryCubit(CategoryRepository()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Todo App',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
