import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../models/roadmap_model.dart';
import '../../providers/roadmap_provider.dart';

class TopicDetailSheet extends ConsumerStatefulWidget {
  final String roadmapId;
  final TopicModel topic;
  final VoidCallback onProgressUpdated;

  const TopicDetailSheet({
    super.key,
    required this.roadmapId,
    required this.topic,
    required this.onProgressUpdated,
  });

  @override
  ConsumerState<TopicDetailSheet> createState() => _TopicDetailSheetState();
}

class _TopicDetailSheetState extends ConsumerState<TopicDetailSheet> {
  bool _isUpdating = false;

  Future<void> _updateStatus(String status) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final repo = ref.read(roadmapRepositoryProvider);
      await repo.updateTopicStatus(
        roadmapId: widget.roadmapId,
        topicId: widget.topic.topicId,
        status: status,
      );
      widget.onProgressUpdated();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Topic marked as ${status.replaceAll('_', ' ')}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _openResource(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: url));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link copied to clipboard')),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard')),
        );
      }
    }
  }

  Future<void> _toggleBookmark(ResourceModel res) async {
    try {
      final repo = ref.read(roadmapRepositoryProvider);
      await repo.toggleResourceBookmark(
        roadmapId: widget.roadmapId,
        topicId: widget.topic.topicId,
        title: res.title,
        url: res.url,
        type: res.type,
      );
      widget.onProgressUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.isBookmarked ? 'Removed from bookmarks' : 'Added to bookmarks'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topic = widget.topic;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Status and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: topic.status),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Text(
                        '~${topic.estimatedHours} Hours',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title & Description
              Text(
                topic.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                topic.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),

              // Prerequisites alert if locked
              if (!topic.isUnlocked) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lock_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prerequisites Required',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Complete the following prerequisite topic${topic.missingPrerequisites.length > 1 ? 's' : ''} to unlock: ${topic.missingPrerequisites.join(', ')}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Action buttons (if unlocked or already completed)
              if (topic.isUnlocked || topic.status == 'completed') ...[
                Row(
                  children: [
                    if (topic.status != 'completed')
                      Expanded(
                        child: AppButton(
                          text: 'Mark Completed',
                          icon: Icons.check_circle_rounded,
                          isLoading: _isUpdating,
                          onPressed: () => _updateStatus('completed'),
                        ),
                      ),
                    if (topic.status == 'completed')
                      Expanded(
                        child: AppButton(
                          text: 'Mark In Progress',
                          type: AppButtonType.secondary,
                          icon: Icons.replay_rounded,
                          isLoading: _isUpdating,
                          onPressed: () => _updateStatus('in_progress'),
                        ),
                      ),
                    const SizedBox(width: 10),
                    if (topic.status != 'in_progress' && topic.status != 'completed')
                      Expanded(
                        child: AppButton(
                          text: 'Start Topic',
                          type: AppButtonType.secondary,
                          icon: Icons.play_arrow_rounded,
                          isLoading: _isUpdating,
                          onPressed: () => _updateStatus('in_progress'),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Curated Resources List
              const Text(
                'Curated Learning Resources',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              if (topic.resources.isEmpty)
                Text(
                  'No curated resources attached for this topic.',
                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                )
              else
                ...topic.resources.map((res) {
                  IconData typeIcon = Icons.article_outlined;
                  if (res.type == 'video') typeIcon = Icons.play_circle_outline_rounded;
                  if (res.type == 'doc') typeIcon = Icons.menu_book_rounded;
                  if (res.type == 'tutorial') typeIcon = Icons.school_outlined;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => _openResource(res.url),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(typeIcon, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  res.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      res.type.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${res.durationMinutes} min',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              res.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: res.isBookmarked ? AppColors.primary : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                              size: 20,
                            ),
                            onPressed: () => _toggleBookmark(res),
                          ),
                          const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textTertiaryLight),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
