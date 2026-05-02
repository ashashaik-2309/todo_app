import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  const AnimatedFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    )
        .animate()
        .scale(duration: 300.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 200.ms);
  }
}
