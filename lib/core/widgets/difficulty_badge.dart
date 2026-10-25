import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const DifficultyBadge({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'beginner':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF047857);
        break;
      case 'medium':
      case 'intermediate':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case 'hard':
      case 'advanced':
      default:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
