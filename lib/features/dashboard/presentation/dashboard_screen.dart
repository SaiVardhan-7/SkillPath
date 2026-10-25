import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/difficulty_badge.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/dashboard_model.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardDataProvider);
          },
          child: dashboardAsync.when(
            loading: () => const LoadingIndicator(message: 'Loading your career dashboard...'),
            error: (err, stack) => ErrorView(
              message: err.toString(),
              onRetry: () => ref.invalidate(dashboardDataProvider),
            ),
            data: (data) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Greeting & Role
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${user?.name.split(' ').first ?? 'Developer'} 👋',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  user?.targetRole ?? 'Software Engineer',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Streak Flame Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.flame.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.flame.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: AppColors.flame, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${data.streak.currentStreak} Day${data.streak.currentStreak == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.flame,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Priority Rule-Based Recommendations Card
                    if (data.recommendations.isNotEmpty) ...[
                      _buildRecommendationCard(context, data.recommendations.first, isDark),
                      const SizedBox(height: 18),
                    ],

                    // Roadmap Overview Card
                    _buildRoadmapCard(context, data.roadmap, isDark),
                    const SizedBox(height: 18),

                    // DSA Progress & Streak Statistics
                    _buildDSAProgressSection(context, data.dsa, isDark),
                    const SizedBox(height: 18),

                    // Weekly Activity Chart
                    _buildWeeklyActivityChart(data.weeklyActivity, isDark),
                    const SizedBox(height: 18),

                    // Active Project in Progress (if any)
                    if (data.activeProject != null) ...[
                      const SectionHeader(title: 'Active Project'),
                      _buildActiveProjectCard(context, data.activeProject!, isDark),
                      const SizedBox(height: 18),
                    ],

                    // Quick Actions
                    const SectionHeader(title: 'Quick Actions'),
                    _buildQuickActionGrid(context, isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, RecommendationItem rec, bool isDark) {
    Color accentColor = AppColors.primary;
    IconData icon = Icons.lightbulb_rounded;

    if (rec.type == 'revision_due') {
      accentColor = AppColors.warning;
      icon = Icons.replay_rounded;
    } else if (rec.type == 'project_next_step') {
      accentColor = AppColors.secondary;
      icon = Icons.terminal_rounded;
    } else if (rec.type == 'prerequisite_incomplete') {
      accentColor = AppColors.error;
      icon = Icons.lock_clock_rounded;
    }

    return AppCard(
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
      border: Border.all(color: accentColor.withOpacity(0.35), width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'RECOMMENDED NEXT ACTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rec.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rec.description,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              text: rec.actionLabel,
              height: 36,
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                context.go(rec.actionRoute);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapCard(BuildContext context, RoadmapSummary roadmap, bool isDark) {
    return AppCard(
      onTap: () => context.go('/roadmap'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.map_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roadmap.roadmapTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'Stage ${roadmap.currentStageNumber}: ${roadmap.currentStageTitle}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${roadmap.percentage}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: roadmap.percentage / 100.0,
              minHeight: 8,
              backgroundColor: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${roadmap.completedTopics} of ${roadmap.totalTopics} topics completed',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const Row(
                children: [
                  Text(
                    'Open Roadmap',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDSAProgressSection(BuildContext context, DSASummary dsa, bool isDark) {
    return AppCard(
      onTap: () => context.go('/dsa'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DSA Practice Tracker',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              if (dsa.dueRevisionsCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: Color(0xFFB45309)),
                      const SizedBox(width: 4),
                      Text(
                        '${dsa.dueRevisionsCount} Due for Revision',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Total Solved', '${dsa.totalSolved}', AppColors.primary, isDark),
              ),
              Container(width: 1, height: 36, color: isDark ? AppColors.borderDark : AppColors.borderLight),
              Expanded(
                child: _buildStatItem('Easy', '${dsa.easySolved}', AppColors.easy, isDark),
              ),
              Container(width: 1, height: 36, color: isDark ? AppColors.borderDark : AppColors.borderLight),
              Expanded(
                child: _buildStatItem('Medium', '${dsa.mediumSolved}', AppColors.medium, isDark),
              ),
              Container(width: 1, height: 36, color: isDark ? AppColors.borderDark : AppColors.borderLight),
              Expanded(
                child: _buildStatItem('Hard', '${dsa.hardSolved}', AppColors.hard, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyActivityChart(List<DayActivity> activity, bool isDark) {
    final maxCount = activity.fold<int>(0, (prev, curr) => curr.count > prev ? curr.count : prev);
    final maxY = (maxCount < 5 ? 5 : maxCount + 1).toDouble();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Coding & Learning Activity',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text(
                'Past 7 Days',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < activity.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              activity[idx].day,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: activity.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: item.count.toDouble(),
                        color: item.count > 0 ? AppColors.primaryLight : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProjectCard(BuildContext context, ActiveProjectSummary project, bool isDark) {
    return AppCard(
      onTap: () => context.go('/projects/${project.projectId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              DifficultyBadge(difficulty: project.difficulty),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            project.domain,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: project.progressPercentage / 100.0,
              minHeight: 6,
              backgroundColor: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${project.completedMilestones} of ${project.totalMilestones} milestones completed',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                '${project.progressPercentage}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context, bool isDark) {
    final actions = [
      {
        'title': 'Solve Problems',
        'subtitle': '40+ curated patterns',
        'icon': Icons.code_rounded,
        'color': AppColors.primary,
        'route': '/dsa',
      },
      {
        'title': 'Career Roadmap',
        'subtitle': 'Topics & prerequisites',
        'icon': Icons.map_rounded,
        'color': AppColors.secondary,
        'route': '/roadmap',
      },
      {
        'title': 'Practical Projects',
        'subtitle': 'Step-by-step builds',
        'icon': Icons.rocket_launch_rounded,
        'color': AppColors.success,
        'route': '/projects',
      },
      {
        'title': 'Interview Prep',
        'subtitle': 'Tech & behavioral QA',
        'icon': Icons.psychology_rounded,
        'color': AppColors.flame,
        'route': '/interview',
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];
        final color = item['color'] as Color;
        return AppCard(
          onTap: () => context.go(item['route'] as String),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item['icon'] as IconData, size: 18, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                item['title'] as String,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Text(
                item['subtitle'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
