import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.foregroundColor = AppColors.chipText,
    this.translucentOnDark = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color foregroundColor;
  final bool translucentOnDark;

  @override
  Widget build(BuildContext context) {
    final background = translucentOnDark
        ? Colors.white.withValues(alpha: 0.16)
        : color.withValues(alpha: 0.11);
    final border = translucentOnDark
        ? Border.all(color: Colors.white.withValues(alpha: 0.16))
        : null;
    final iconColor = translucentOnDark ? Colors.white : color;
    final textColor = translucentOnDark ? Colors.white : foregroundColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: background,
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
