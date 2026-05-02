import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/core/constants/app_strings.dart';
import 'package:todo_app/core/utils/priority_utils.dart';
import 'package:todo_app/features/categories/domain/category_model.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';
import 'package:todo_app/features/todos/bloc/todo_bloc.dart';
import 'package:todo_app/features/todos/bloc/todo_event.dart';
import 'package:todo_app/features/todos/bloc/todo_state.dart';

class FilterBar extends StatelessWidget {
  final List<Category> categories;

  const FilterBar({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (prev, curr) => curr is TodoLoaded,
      builder: (context, state) {
        final filter = state is TodoLoaded ? state.filter : const FilterState();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _chip(
                context,
                label: AppStrings.all,
                selected: filter.priority == null && filter.categoryId == null,
                onTap: () {
                  context.read<TodoBloc>()
                    ..add(const PriorityFilterChanged(null))
                    ..add(const CategoryFilterChanged(null));
                },
              ),
              const SizedBox(width: 8),
              ...Priority.values.map((p) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _chip(
                      context,
                      label: PriorityUtils.label(p),
                      selected: filter.priority == p,
                      color: PriorityUtils.color(p),
                      icon: PriorityUtils.icon(p),
                      onTap: () => context.read<TodoBloc>().add(
                            PriorityFilterChanged(filter.priority == p ? null : p),
                          ),
                    ),
                  )),
              ...categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _chip(
                      context,
                      label: cat.name,
                      selected: filter.categoryId == cat.id,
                      color: Color(cat.colorValue),
                      onTap: () => context.read<TodoBloc>().add(
                            CategoryFilterChanged(
                                filter.categoryId == cat.id ? null : cat.id),
                          ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool selected,
    Color? color,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? scheme.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: selected ? Colors.white : effectiveColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : effectiveColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: effectiveColor,
      backgroundColor: effectiveColor.withValues(alpha: 0.1),
      checkmarkColor: Colors.white,
      showCheckmark: false,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}
