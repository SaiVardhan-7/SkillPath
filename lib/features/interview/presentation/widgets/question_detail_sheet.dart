import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/difficulty_badge.dart';
import '../../models/interview_model.dart';
import '../../providers/interview_provider.dart';

class QuestionDetailSheet extends ConsumerStatefulWidget {
  final InterviewQuestionModel question;
  final VoidCallback onUpdated;

  const QuestionDetailSheet({
    super.key,
    required this.question,
    required this.onUpdated,
  });

  @override
  ConsumerState<QuestionDetailSheet> createState() => _QuestionDetailSheetState();
}

class _QuestionDetailSheetState extends ConsumerState<QuestionDetailSheet> {
  final _notesController = TextEditingController();
  late bool _isPracticed;
  late bool _isBookmarked;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isPracticed = widget.question.isPracticed;
    _isBookmarked = widget.question.isBookmarked;
    _notesController.text = widget.question.userNotes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(interviewRepositoryProvider);
      await repo.updateProgress(
        questionId: widget.question.id,
        isPracticed: _isPracticed,
        isBookmarked: _isBookmarked,
        userNotes: _notesController.text.trim(),
      );
      widget.onUpdated();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interview practice notes saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final q = widget.question;

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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${q.category} • ${q.topic}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                  DifficultyBadge(difficulty: q.difficulty),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                q.question,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),

              // Company tags
              if (q.companyTags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: q.companyTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '🏢 $tag',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
              ],

              // Answer Key Points
              const Text('Key Discussion Points & Structure', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...q.answerKeyPoints.map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✓ ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.success)),
                      Expanded(
                        child: Text(
                          point,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 18),

              // Notes Input
              AppTextField(
                controller: _notesController,
                label: 'Personal Answer Draft / Notes',
                hint: 'Note your specific STAR story or design breakdown...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Practice & Bookmark Toggles
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Practiced')),
                      selected: _isPracticed,
                      selectedColor: AppColors.success,
                      labelStyle: TextStyle(
                        color: _isPracticed ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) => setState(() => _isPracticed = val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Bookmarked')),
                      selected: _isBookmarked,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _isBookmarked ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) => setState(() => _isBookmarked = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              AppButton(
                text: 'Save Progress',
                width: double.infinity,
                isLoading: _isSaving,
                onPressed: _saveChanges,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
