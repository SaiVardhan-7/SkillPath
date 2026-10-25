import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/difficulty_badge.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedDomain = ref.watch(projectDomainFilterProvider);
    final selectedDifficulty = ref.watch(projectDifficultyFilterProvider);
    final catalogProjectsAsync = ref.watch(allCatalogProjectsProvider);
    final userProjectsAsync = ref.watch(userProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Learning Hub'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Catalog'),
            Tab(text: 'My Learning Projects'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
            ),
            child: Column(
              children: [
                // Domain Horizontal Scroll
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: const Text('All Domains', style: TextStyle(fontSize: 11)),
                          selected: selectedDomain == 'All',
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selectedDomain == 'All' ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => ref.read(projectDomainFilterProvider.notifier).state = 'All',
                        ),
                      ),
                      ...AppConstants.projectDomains.map((domain) {
                        final isSel = selectedDomain == domain;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(domain, style: const TextStyle(fontSize: 11)),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : null,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) => ref.read(projectDomainFilterProvider.notifier).state = domain,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Difficulty Filter Chips
                Row(
                  children: [
                    const Text('Difficulty: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ...['All', 'Beginner', 'Intermediate', 'Advanced'].map((diff) {
                      final isSel = selectedDifficulty == diff;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(diff, style: const TextStyle(fontSize: 10)),
                          selected: isSel,
                          selectedColor: AppColors.secondary,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => ref.read(projectDifficultyFilterProvider.notifier).state = diff,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Catalog Projects
                catalogProjectsAsync.when(
                  loading: () => const LoadingIndicator(message: 'Loading project catalog...'),
                  error: (err, _) => ErrorView(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(allCatalogProjectsProvider),
                  ),
                  data: (projects) {
                    if (projects.isEmpty) {
                      return const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No Matching Projects',
                        message: 'Try clearing the domain filter to view available projects.',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final proj = projects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            onTap: () => context.push('/projects/${proj.id}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        proj.domain,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                      ),
                                    ),
                                    DifficultyBadge(difficulty: proj.difficulty),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  proj.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  proj.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Tech Stack Tags
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: proj.requiredTech.take(4).map((tech) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(tech, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '~${proj.estimatedHours} Hours • ${proj.milestones.length} Milestones',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                      ),
                                    ),
                                    const Row(
                                      children: [
                                        Text('View Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                        Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                // TAB 2: User Learning Projects
                userProjectsAsync.when(
                  loading: () => const LoadingIndicator(message: 'Loading your projects...'),
                  error: (err, _) => ErrorView(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(userProjectsProvider),
                  ),
                  data: (userProjects) {
                    if (userProjects.isEmpty) {
                      return EmptyState(
                        icon: Icons.rocket_launch_outlined,
                        title: 'No Projects Started Yet',
                        message: 'Explore the catalog to pick your first production project and start tracking milestones.',
                        actionLabel: 'Browse Projects',
                        onAction: () => _tabController.animateTo(0),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: userProjects.length,
                      itemBuilder: (context, index) {
                        final up = userProjects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            onTap: () => context.push('/projects/${up.project.id}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      up.project.title,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                    ),
                                    DifficultyBadge(difficulty: up.project.difficulty),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  up.project.domain,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: up.progressPercentage / 100.0,
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
                                      '${up.completedMilestonesCount} of ${up.totalMilestones} milestones completed',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    Text(
                                      '${up.progressPercentage}%',
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
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
