import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status; // 'completed', 'in_progress', 'locked', 'ready', 'solved', 'attempted', 'saved'
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData? icon;
    String label = customLabel ?? '';

    switch (status.toLowerCase()) {
      case 'completed':
      case 'solved':
        bg = AppColors.successLight;
        fg = const Color(0xFF065F46); // Dark emerald
        icon = Icons.check_circle_rounded;
        label = customLabel ?? (status.toLowerCase() == 'solved' ? 'Solved' : 'Completed');
        break;

      case 'in_progress':
      case 'attempted':
        bg = AppColors.warningLight;
        fg = const Color(0xFF92400E); // Dark amber
        icon = Icons.timelapse_rounded;
        label = customLabel ?? (status.toLowerCase() == 'attempted' ? 'Attempted' : 'In Progress');
        break;

      case 'locked':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        icon = Icons.lock_outline_rounded;
        label = customLabel ?? 'Locked';
        break;

      case 'ready':
      case 'ready to start':
        bg = const Color(0xFFE0E7FF);
        fg = AppColors.primary;
        icon = Icons.play_arrow_rounded;
        label = customLabel ?? 'Ready';
        break;

      case 'saved':
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        icon = Icons.bookmark_outline_rounded;
        label = customLabel ?? 'Saved';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
