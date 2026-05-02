import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_app/features/categories/domain/category_model.dart';
import 'package:todo_app/features/categories/cubit/category_cubit.dart';
import 'package:todo_app/features/categories/widget/add_edit_category_dialog.dart';
import 'package:todo_app/common/widgets/confirm_delete_dialog.dart';

class CategoryListTile extends StatelessWidget {
  final Category category;
  final int index;

  const CategoryListTile({super.key, required this.category, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);

    return Slidable(
      key: ValueKey(category.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (_) async {
              final confirm = await ConfirmDeleteDialog.show(context);
              if (confirm && context.mounted) {
                context.read<CategoryCubit>().deleteCategory(category.id);
              }
            },
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(
              IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_rounded, size: 18),
            onPressed: () => AddEditCategoryDialog.show(context, category: category),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    )
        .animate()
        .slideX(begin: 0.3, duration: 300.ms, delay: (index * 50).ms, curve: Curves.easeOut)
        .fadeIn(duration: 300.ms, delay: (index * 50).ms);
  }
}
