import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app.dart';
import 'package:todo_app/core/database/isar_service.dart';

class _AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('[BlocError] ${bloc.runtimeType}: $error');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = _AppBlocObserver();
  await IsarService.init();
  runApp(const TodoApp());
}
