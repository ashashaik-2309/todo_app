import 'package:flutter/material.dart';
import 'package:todo_app/core/constants/app_strings.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String message;
  const ConfirmDeleteDialog({super.key, this.message = AppStrings.deleteConfirmMsg});

  static Future<bool> show(BuildContext context, {String? message}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        message: message ?? AppStrings.deleteConfirmMsg,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.confirmDelete),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text(AppStrings.delete),
        ),
      ],
    );
  }
}
