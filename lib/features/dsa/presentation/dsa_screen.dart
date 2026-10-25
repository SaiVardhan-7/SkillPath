import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/difficulty_badge.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/dsa_problem_model.dart';
import '../providers/dsa_provider.dart';
import 'widgets/add_problem_dialog.dart';
import 'widgets/problem_card.dart';

class DSAScreen extends ConsumerStatefulWidget {
  const DSAScreen({super.key});

  @override
  ConsumerState<DSAScreen> createState() => _DSAScreenState();
}

class _DSAScreenState extends ConsumerState<DSAScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openAddProblemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProblemDialog(
        onProblemAdded: () {
          ref.invalidate(userProblemsProvider);
        },
      ),
    );
  }

  Future<void> _updateStatus(String problemId, String newStatus) async {
    final repo = ref.read(dsaRepositoryProvider);
    await repo.updateProblem(id: problemId, status: newStatus);
    ref.invalidate(userProblemsProvider);
  }

  Future<void> _toggleBookmark(String problemId, bool current) async {
    final repo = ref.read(dsaRepositoryProvider);
    await repo.updateProblem(id: problemId, isBookmarked: !current);
    ref.invalidate(userProblemsProvider);
  }

  Future<void> _reschedule(String problemId, int days) async {
    final repo = ref.read(dsaRepositoryProvider);
    await repo.updateProblem(id: problemId, rescheduleDays: days);
    ref.invalidate(userProblemsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Revision scheduled in $days days')),
      );
    }
  }

  Future<void> _deleteProblem(String problemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Problem?'),
        content: const Text('Are you sure you want to remove this problem from your tracking list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(dsaRepositoryProvider);
      await repo.deleteProblem(problemId);
      ref.invalidate(userProblemsProvider);
    }
  }

  Future<void> _trackCatalogProblem(DSAProblemModel catalogProblem) async {
    try {
      final repo = ref.read(dsaRepositoryProvider);
      await repo.addProblem(
        problemId: catalogProblem.id,
        title: catalogProblem.title,
        url: catalogProblem.url,
        platform: catalogProblem.platform,
        topic: catalogProblem.topic,
        difficulty: catalogProblem.difficulty,
        status: 'attempted',
      );
      ref.invalidate(userProblemsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added "${catalogProblem.title}" to your tracking list!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedTopic = ref.watch(dsaTopicFilterProvider);
    final selectedDifficulty = ref.watch(dsaDifficultyFilterProvider);
    final selectedStatus = ref.watch(dsaStatusFilterProvider);
    final userProblemsAsync = ref.watch(userProblemsProvider);
    final catalogProblemsAsync = ref.watch(catalogProblemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DSA Progress Tracker'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'My Tracked Problems'),
            Tab(text: 'Curated Catalog'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddProblemDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Track Problem', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
            ),
            child: Column(
              children: [
                // Search Input
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      ref.read(dsaSearchQueryProvider.notifier).state = val;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search problems by title...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(dsaSearchQueryProvider.notifier).state = '';
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Horizontal Topic Chips
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: const Text('All Topics', style: TextStyle(fontSize: 11)),
                          selected: selectedTopic == 'All',
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selectedTopic == 'All' ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => ref.read(dsaTopicFilterProvider.notifier).state = 'All',
                        ),
                      ),
                      ...AppConstants.dsaCategories.map((cat) {
                        final isSel = selectedTopic == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(cat, style: const TextStyle(fontSize: 11)),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : null,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) => ref.read(dsaTopicFilterProvider.notifier).state = cat,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Difficulty & Status Filter Chips
                Row(
                  children: [
                    // Difficulty
                    PopupMenuButton<String>(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Difficulty: $selectedDifficulty',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.arrow_drop_down_rounded, size: 16),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'All', child: Text('All Difficulties')),
                        const PopupMenuItem(value: 'Easy', child: Text('Easy')),
                        const PopupMenuItem(value: 'Medium', child: Text('Medium')),
                        const PopupMenuItem(value: 'Hard', child: Text('Hard')),
                      ],
                      onSelected: (val) => ref.read(dsaDifficultyFilterProvider.notifier).state = val,
                    ),
                    const SizedBox(width: 8),

                    // Status
                    PopupMenuButton<String>(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Status: $selectedStatus',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.arrow_drop_down_rounded, size: 16),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'All', child: Text('All Statuses')),
                        const PopupMenuItem(value: 'solved', child: Text('Solved')),
                        const PopupMenuItem(value: 'attempted', child: Text('Attempted')),
                      ],
                      onSelected: (val) => ref.read(dsaStatusFilterProvider.notifier).state = val,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: User Tracked Problems
                userProblemsAsync.when(
                  loading: () => const LoadingIndicator(message: 'Loading your solved problems...'),
                  error: (err, _) => ErrorView(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(userProblemsProvider),
                  ),
                  data: (data) {
                    final problems = data.problems;
                    final analytics = data.analytics;

                    if (problems.isEmpty) {
                      return EmptyState(
                        icon: Icons.code_rounded,
                        title: 'No Problems Tracked Yet',
                        message: 'Add coding problems manually or pick from our curated catalog to begin tracking your progress.',
                        actionLabel: 'Browse Curated Catalog',
                        onAction: () => _tabController.animateTo(1),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                      itemCount: problems.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Analytics Banner at top of user list
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: AppCard(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSummaryItem('Total', '${analytics.totalSolved}', AppColors.primary),
                                  _buildSummaryItem('Easy', '${analytics.easySolved}', AppColors.easy),
                                  _buildSummaryItem('Med', '${analytics.mediumSolved}', AppColors.medium),
                                  _buildSummaryItem('Hard', '${analytics.hardSolved}', AppColors.hard),
                                  _buildSummaryItem('Revisions', '${analytics.dueRevisionsCount}', AppColors.warning),
                                ],
                              ),
                            ),
                          );
                        }

                        final problem = problems[index - 1];
                        return ProblemCard(
                          problem: problem,
                          onStatusChanged: (status) => _updateStatus(problem.id, status),
                          onBookmarkToggled: () => _toggleBookmark(problem.id, problem.isBookmarked),
                          onRescheduled: (days) => _reschedule(problem.id, days),
                          onDelete: () => _deleteProblem(problem.id),
                        );
                      },
                    );
                  },
                ),

                // TAB 2: Curated Catalog Problems
                catalogProblemsAsync.when(
                  loading: () => const LoadingIndicator(message: 'Loading curated problems...'),
                  error: (err, _) => ErrorView(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(catalogProblemsProvider),
                  ),
                  data: (catalog) {
                    if (catalog.isEmpty) {
                      return const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No Matching Problems Found',
                        message: 'Try clearing your category or difficulty filter to view more curated challenges.',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                      itemCount: catalog.length,
                      itemBuilder: (context, index) {
                        final item = catalog[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.topic,
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          DifficultyBadge(difficulty: item.difficulty),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AppButton(
                                  text: '+ Track',
                                  type: AppButtonType.secondary,
                                  height: 32,
                                  onPressed: () => _trackCatalogProblem(item),
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

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textTertiaryLight),
        ),
      ],
    );
  }
}
