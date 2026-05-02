import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/core/constants/app_strings.dart';
import 'package:todo_app/features/categories/domain/category_model.dart';
import 'package:todo_app/core/theme/theme_cubit.dart';
import 'package:todo_app/features/categories/cubit/category_cubit.dart';
import 'package:todo_app/features/todos/cubit/todo_cubit.dart';
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
    return Scaffold(
      floatingActionButton: _isActive
          ? AnimatedFab(
              onPressed: () => context.push('/todo/add'),
              tooltip: AppStrings.addTodo,
            )
          : null,
      body: BlocBuilder<TodoCubit, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading || state is TodoInitial) {
            return const _LoadingBody();
          }
          if (state is TodoError) {
            return _ErrorBody(message: state.message);
          }
          if (state is TodoLoaded) {
            return _HomeContent(todoState: state, isActive: _isActive);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeaderSkeleton(),
        const Expanded(child: Center(child: CircularProgressIndicator())),
      ],
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6750A4), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<TodoCubit>().load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final TodoLoaded todoState;
  final bool isActive;

  const _HomeContent({required this.todoState, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final todos = isActive ? todoState.activeTodos : todoState.completedTodos;

    return Column(
      children: [
        if (isActive)
          _ActiveHeader(todoState: todoState)
        else
          _CompletedHeader(count: todoState.completedTodos.length),

        // Sync indicator
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: todoState.isSyncing ? 3 : 0,
          child: todoState.isSyncing
              ? LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                )
              : const SizedBox.shrink(),
        ),

        if (isActive) ...[
          const SizedBox(height: 8),
          SearchBarWidget(
            onChanged: (q) => context.read<TodoCubit>().searchChanged(q),
          ),
          BlocBuilder<CategoryCubit, CategoryState>(
            builder: (_, catState) {
              final cats =
                  catState is CategoryLoaded ? catState.categories : <Category>[];
              return FilterBar(categories: cats);
            },
          ),
          const SizedBox(height: 4),
        ] else
          const SizedBox(height: 8),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<TodoCubit>().syncFromApi();
            },
            child: todos.isEmpty
                ? _buildEmpty(isActive, todoState)
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 96),
                    itemCount: todos.length,
                    itemBuilder: (context, index) =>
                        TodoListTile(todo: todos[index], index: index),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(bool isActive, TodoLoaded state) {
    if (isActive) {
      final hasFilter = state.filter.searchQuery.isNotEmpty ||
          state.filter.priority != null ||
          state.filter.categoryId != null;
      return TodoEmptyState(
        title: hasFilter ? AppStrings.noSearchResults : AppStrings.noTodosActive,
        subtitle:
            hasFilter ? 'Try clearing the filters' : AppStrings.addFirstTodo,
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
}

// ─── Active tab header ────────────────────────────────────────────────────────

class _ActiveHeader extends StatelessWidget {
  final TodoLoaded todoState;
  const _ActiveHeader({required this.todoState});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final total = todoState.allTodos.length;
    final done = todoState.allTodos.where((t) => t.isCompleted).length;
    final active = total - done;
    final pct = total == 0 ? 0.0 : done / total;
    final today = DateFormat('EEE, MMM d').format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6750A4), Color(0xFF7B2FBE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: greeting (left) + date + toggle (right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'My Tasks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        today,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Builder(builder: (ctx) {
                        final isDark =
                            ctx.watch<ThemeCubit>().state == ThemeMode.dark;
                        return IconButton(
                          icon: Icon(
                            isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => ctx.read<ThemeCubit>().toggle(),
                          tooltip: 'Toggle theme',
                          visualDensity: VisualDensity.compact,
                        );
                      }),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(pct * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Stat cards
              Row(
                children: [
                  _StatCard(label: 'Total', value: total,
                      bg: Colors.white,
                      fg: const Color(0xFF6750A4)),
                  const SizedBox(width: 10),
                  _StatCard(label: 'Active', value: active,
                      bg: const Color(0xFFFFF3E0),
                      fg: const Color(0xFFE65100)),
                  const SizedBox(width: 10),
                  _StatCard(label: 'Done', value: done,
                      bg: const Color(0xFFE8F5E9),
                      fg: const Color(0xFF2E7D32)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color bg;
  final Color fg;

  const _StatCard({
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: fg,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Completed tab header ─────────────────────────────────────────────────────

class _CompletedHeader extends StatelessWidget {
  final int count;
  const _CompletedHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Container(
      color: scheme.surfaceContainerHighest,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completed',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count == 0
                          ? 'Nothing done yet'
                          : '$count task${count == 1 ? '' : 's'} completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded),
                onPressed: () => context.read<ThemeCubit>().toggle(),
                tooltip: 'Toggle theme',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
