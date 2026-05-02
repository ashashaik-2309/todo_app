import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TodoEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const TodoEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.check_circle_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.3);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: color)
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .slideY(begin: 0.3, duration: 300.ms, delay: 100.ms, curve: Curves.easeOut)
                .fadeIn(duration: 300.ms, delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .slideY(begin: 0.3, duration: 300.ms, delay: 180.ms, curve: Curves.easeOut)
                .fadeIn(duration: 300.ms, delay: 180.ms),
          ],
        ),
      ),
    );
  }
}
