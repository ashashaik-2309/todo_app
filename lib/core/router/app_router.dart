import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/features/categories/presentation/screens/categories_screen.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';
import 'package:todo_app/features/todos/presentation/screens/add_edit_todo_screen.dart';
import 'package:todo_app/features/todos/presentation/screens/home_screen.dart';
import 'package:todo_app/features/todos/presentation/screens/todo_detail_screen.dart';
import 'package:todo_app/shared/widgets/app_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/todos',
  routes: [
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/todos',
          pageBuilder: (context, state) => _fadePage(const HomeScreen(tab: 0)),
        ),
        GoRoute(
          path: '/completed',
          pageBuilder: (context, state) => _fadePage(const HomeScreen(tab: 1)),
        ),
        GoRoute(
          path: '/categories',
          pageBuilder: (context, state) => _fadePage(const CategoriesScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/todo/add',
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) {
        return _slidePage(const AddEditTodoScreen());
      },
    ),
    GoRoute(
      path: '/todo/edit',
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) {
        final todo = state.extra as Todo;
        return _slidePage(AddEditTodoScreen(todo: todo));
      },
    ),
    GoRoute(
      path: '/todo/:id',
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _slidePage(TodoDetailScreen(todoId: id));
      },
    ),
  ],
);

CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slidePage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
