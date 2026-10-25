import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/difficulty_badge.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../models/dsa_problem_model.dart';

class ProblemCard extends StatefulWidget {
  final DSAProblemModel problem;
  final Function(String status) onStatusChanged;
  final VoidCallback onBookmarkToggled;
  final Function(int days) onRescheduled;
  final VoidCallback onDelete;

  const ProblemCard({
    super.key,
    required this.problem,
    required this.onStatusChanged,
    required this.onBookmarkToggled,
    required this.onRescheduled,
    required this.onDelete,
  });

  @override
  State<ProblemCard> createState() => _ProblemCardState();
}

class _ProblemCardState extends State<ProblemCard> {
  bool _isExpanded = false;

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: url));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Problem link copied to clipboard')),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Problem link copied to clipboard')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final problem = widget.problem;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Topic, Platform, Badges, Bookmark
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    problem.platform,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    problem.topic,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
                const Spacer(),
                DifficultyBadge(difficulty: problem.difficulty),
                const SizedBox(width: 6),
                StatusBadge(status: problem.status),
                IconButton(
                  icon: Icon(
                    problem.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: problem.isBookmarked ? AppColors.primary : AppColors.textTertiaryLight,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onBookmarkToggled,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Problem Title + Open URL
            InkWell(
              onTap: () => _openUrl(problem.url),
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      problem.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ),

            // Revision Banner if due or scheduled
            if (problem.revisionScheduledDate != null && problem.status == 'solved') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    problem.isRevisionDue ? Icons.alarm_rounded : Icons.calendar_today_rounded,
                    size: 13,
                    color: problem.isRevisionDue ? AppColors.error : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    problem.isRevisionDue
                        ? 'Revision Due Now!'
                        : 'Next Revision: ${DateFormat.MMMd().format(problem.revisionScheduledDate!)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: problem.isRevisionDue ? FontWeight.w700 : FontWeight.w500,
                      color: problem.isRevisionDue ? AppColors.error : AppColors.textSecondaryLight,
                    ),
                  ),
                  const Spacer(),
                  // Reschedule Popup Menu
                  PopupMenuButton<int>(
                    tooltip: 'Reschedule revision',
                    child: const Row(
                      children: [
                        Text('Reschedule', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.primary),
                      ],
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 3, child: Text('In 3 Days')),
                      const PopupMenuItem(value: 7, child: Text('In 7 Days')),
                      const PopupMenuItem(value: 14, child: Text('In 14 Days')),
                      const PopupMenuItem(value: 30, child: Text('In 30 Days')),
                    ],
                    onSelected: widget.onRescheduled,
                  ),
                ],
              ),
            ],

            // Expand notes trigger
            if (problem.notes.isNotEmpty || problem.mistakes.isNotEmpty) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  children: [
                    Text(
                      _isExpanded ? 'Hide Notes' : 'View Notes & Mistakes',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ],

            // Expanded Notes Body
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              if (problem.notes.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notes:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(problem.notes, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
              if (problem.mistakes.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mistakes / Observations:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                      ),
                      const SizedBox(height: 2),
                      Text(problem.mistakes, style: const TextStyle(fontSize: 12, color: Color(0xFF78350F))),
                    ],
                  ),
                ),
              ],
            ],

            // Quick Status Actions Bar
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (problem.status != 'solved')
                  TextButton.icon(
                    onPressed: () => widget.onStatusChanged('solved'),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                    label: const Text('Mark Solved', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                if (problem.status == 'solved')
                  TextButton.icon(
                    onPressed: () => widget.onStatusChanged('attempted'),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Mark Attempted', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Delete problem',
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textTertiaryLight),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
