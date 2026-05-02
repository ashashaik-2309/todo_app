import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/network/dio_client.dart';
import 'package:todo_app/core/router/app_router.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/core/theme/theme_cubit.dart';
import 'package:todo_app/features/categories/data/category_repository.dart';
import 'package:todo_app/features/categories/cubit/category_cubit.dart';
import 'package:todo_app/features/todos/data/todo_api_service.dart';
import 'package:todo_app/features/todos/data/todo_repository.dart';
import 'package:todo_app/features/todos/cubit/todo_cubit.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = DioClient.create();
    final apiService = TodoApiService(dio);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()..init()),
        BlocProvider(
          create: (_) => TodoCubit(TodoRepository(apiService: apiService))..load(),
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
