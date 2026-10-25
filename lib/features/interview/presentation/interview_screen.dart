import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/difficulty_badge.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/interview_model.dart';
import '../providers/interview_provider.dart';
import 'widgets/question_detail_sheet.dart';

class InterviewScreen extends ConsumerWidget {
  const InterviewScreen({super.key});

  void _showQuestionDetail(BuildContext context, WidgetRef ref, InterviewQuestionModel q) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionDetailSheet(
        question: q,
        onUpdated: () => ref.invalidate(interviewQuestionsProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedCategory = ref.watch(interviewCategoryFilterProvider);
    final questionsAsync = ref.watch(interviewQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview & Career Prep'),
      ),
      body: Column(
        children: [
          // Filter Chips Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Categories', style: TextStyle(fontSize: 11)),
                    selected: selectedCategory == 'All',
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selectedCategory == 'All' ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => ref.read(interviewCategoryFilterProvider.notifier).state = 'All',
                  ),
                  const SizedBox(width: 8),
                  ...AppConstants.interviewCategories.map((cat) {
                    final isSel = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat, style: const TextStyle(fontSize: 11)),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => ref.read(interviewCategoryFilterProvider.notifier).state = cat,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Questions List & Readiness Card
          Expanded(
            child: questionsAsync.when(
              loading: () => const LoadingIndicator(message: 'Loading interview questions...'),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(interviewQuestionsProvider),
              ),
              data: (questions) {
                final practicedCount = questions.where((q) => q.isPracticed).length;
                final totalCount = questions.length;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Interview Readiness Checklist Card
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AppCard(
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
                          border: Border.all(
                            color: isDark ? const Color(0xFF047857).withOpacity(0.3) : const Color(0xFFA7F3D0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Interview Readiness Checklist',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.successLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$practicedCount / $totalCount Practiced',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF047857),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Practice standard technical questions, system design architectures, and behavioral STAR stories.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF065F46),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final q = questions[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        onTap: () => _showQuestionDetail(context, ref, q),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${q.category} • ${q.topic}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (q.isPracticed) ...[
                                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                                      const SizedBox(width: 4),
                                    ],
                                    DifficultyBadge(difficulty: q.difficulty),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              q.question,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            if (q.companyTags.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 4,
                                children: q.companyTags.take(3).map((tag) {
                                  return Text(
                                    '#$tag ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
