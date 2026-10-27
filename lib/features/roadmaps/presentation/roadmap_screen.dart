import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/roadmap_model.dart';
import '../providers/roadmap_provider.dart';
import 'widgets/topic_detail_sheet.dart';

class RoadmapScreen extends ConsumerStatefulWidget {
  const RoadmapScreen({super.key});

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  final Set<int> _expandedStages = {1}; // Stage 1 expanded by default

  void _showTopicDetail(String roadmapId, TopicModel topic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TopicDetailSheet(
        roadmapId: roadmapId,
        topic: topic,
        onProgressUpdated: () {
          ref.invalidate(userRoadmapProvider);
        },
      ),
    );
  }

  void _showRoleSwitcher(List<RoadmapModel> roadmaps, String currentRoadmapId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Switch Career Roadmap',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select a target role to view its structured learning roadmap.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 16),
                ...roadmaps.map((r) {
                  final isCurrent = r.id == currentRoadmapId;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      r.title,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent ? AppColors.primary : null,
                      ),
                    ),
                    subtitle: Text('${r.estimatedWeeks} Weeks estimated curriculum'),
                    trailing: isCurrent ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                    onTap: () {
                      ref.read(selectedRoadmapIdProvider.notifier).set(r.id);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final roadmapAsync = ref.watch(userRoadmapProvider);
    final allRoadmapsAsync = ref.watch(allRoadmapsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Roadmap'),
        actions: [
          allRoadmapsAsync.when(
            data: (roadmaps) => roadmapAsync.when(
              data: (userRoadmap) => IconButton(
                icon: const Icon(Icons.swap_horiz_rounded),
                tooltip: 'Switch Roadmap',
                onPressed: () => _showRoleSwitcher(roadmaps, userRoadmap.roadmap.id),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userRoadmapProvider);
        },
        child: roadmapAsync.when(
          loading: () => const LoadingIndicator(message: 'Loading curriculum...'),
          error: (err, stack) => ErrorView(
            message: err.toString(),
            onRetry: () => ref.invalidate(userRoadmapProvider),
          ),
          data: (data) {
            final roadmap = data.roadmap;
            final progress = data.progress;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Roadmap Overview Header Card
                  AppCard(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
                    border: Border.all(
                      color: isDark ? const Color(0xFF3730A3).withOpacity(0.4) : const Color(0xFFC7D2FE),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                roadmap.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1E1B4B),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${progress.overallPercentage}% Done',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          roadmap.description,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF4338CA),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress.overallPercentage / 100.0,
                            minHeight: 8,
                            backgroundColor: isDark ? AppColors.surfaceSubtleDark : const Color(0xFFE0E7FF),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${progress.completedTopicsCount} of ${progress.totalTopics} topics mastered',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : const Color(0xFF4338CA),
                              ),
                            ),
                            Text(
                              '~${roadmap.estimatedWeeks} Weeks',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : const Color(0xFF4338CA),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stage Accordions
                  const Text(
                    'Roadmap Stages',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  ...roadmap.stages.map((stage) {
                    final isExpanded = _expandedStages.contains(stage.stageNumber);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            // Stage Header
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expandedStages.remove(stage.stageNumber);
                                  } else {
                                    _expandedStages.add(stage.stageNumber);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.vertical(
                                top: const Radius.circular(16),
                                bottom: isExpanded ? Radius.zero : const Radius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: stage.progressPercentage == 100
                                            ? AppColors.successLight
                                            : AppColors.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: stage.progressPercentage == 100
                                            ? const Icon(Icons.check_rounded, color: AppColors.success, size: 20)
                                            : Text(
                                                '${stage.stageNumber}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stage.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${stage.completedTopics}/${stage.totalTopics} topics (${stage.progressPercentage}%)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Stage Topics (when expanded)
                            if (isExpanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: stage.topics.map((topic) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: InkWell(
                                        onTap: () => _showTopicDetail(roadmap.id, topic),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                topic.status == 'completed'
                                                    ? Icons.check_circle_rounded
                                                    : (topic.status == 'in_progress'
                                                        ? Icons.timelapse_rounded
                                                        : (topic.isUnlocked
                                                            ? Icons.radio_button_unchecked_rounded
                                                            : Icons.lock_outline_rounded)),
                                                size: 20,
                                                color: topic.status == 'completed'
                                                    ? AppColors.success
                                                    : (topic.status == 'in_progress'
                                                        ? AppColors.warning
                                                        : (topic.isUnlocked
                                                            ? AppColors.primary
                                                            : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight))),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      topic.title,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                                      ),
                                                    ),
                                                    if (!topic.isUnlocked && topic.missingPrerequisites.isNotEmpty) ...[
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Prereq: ${topic.missingPrerequisites.first}',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          color: AppColors.error,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              StatusBadge(status: topic.status),
                                              const SizedBox(width: 6),
                                              const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textTertiaryLight),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
