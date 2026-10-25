import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/difficulty_badge.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final _githubController = TextEditingController();
  final _demoController = TextEditingController();
  final _notesController = TextEditingController();

  Set<String> _completedMilestones = {};
  List<String> _resumeBullets = [];
  bool _isInitialized = false;
  bool _isSaving = false;
  bool _isGeneratingBullets = false;

  @override
  void dispose() {
    _githubController.dispose();
    _demoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initUserProjectData(List<UserProjectModel> userProjects) {
    if (_isInitialized) return;
    final match = userProjects.where((up) => up.project.id == widget.projectId).toList();
    if (match.isNotEmpty) {
      final up = match.first;
      _githubController.text = up.githubUrl;
      _demoController.text = up.liveDemoUrl;
      _notesController.text = up.notes;
      _completedMilestones = Set.from(up.completedMilestones);
      _resumeBullets = List.from(up.userResumeBullets);
      _isInitialized = true;
    }
  }

  Future<void> _toggleMilestone(String milestoneId, bool currentCompleted) async {
    setState(() {
      if (currentCompleted) {
        _completedMilestones.remove(milestoneId);
      } else {
        _completedMilestones.add(milestoneId);
      }
    });

    try {
      final repo = ref.read(projectRepositoryProvider);
      await repo.updateProjectProgress(
        userProjectIdOrProjectId: widget.projectId,
        milestoneId: milestoneId,
        completed: !currentCompleted,
      );
      ref.invalidate(userProjectsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _saveLinks() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(projectRepositoryProvider);
      await repo.updateProjectProgress(
        userProjectIdOrProjectId: widget.projectId,
        githubUrl: _githubController.text.trim(),
        liveDemoUrl: _demoController.text.trim(),
        notes: _notesController.text.trim(),
      );
      ref.invalidate(userProjectsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project links and notes saved!')),
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

  Future<void> _generateResumeBullets() async {
    setState(() => _isGeneratingBullets = true);
    try {
      final repo = ref.read(projectRepositoryProvider);
      final bullets = await repo.generateResumeBullets(widget.projectId);
      setState(() {
        _resumeBullets = bullets;
      });
      ref.invalidate(userProjectsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isGeneratingBullets = false);
    }
  }

  Future<void> _startProject() async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.startOrSaveProject(projectId: widget.projectId, status: 'in_progress');
    ref.invalidate(userProjectsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project added to your active learning list!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final projectAsync = ref.watch(projectDetailProvider(widget.projectId));
    final userProjectsAsync = ref.watch(userProjectsProvider);

    userProjectsAsync.whenData((list) => _initUserProjectData(list));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Guide'),
      ),
      body: projectAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading project guide...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(projectDetailProvider(widget.projectId)),
        ),
        data: (project) {
          final totalMilestones = project.milestones.length;
          final completedCount = _completedMilestones.length;
          final progressPercent = totalMilestones > 0 ? ((completedCount / totalMilestones) * 100).round() : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                AppCard(
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              project.domain,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                            ),
                          ),
                          DifficultyBadge(difficulty: project.difficulty),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        project.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        project.description,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textSecondaryLight),
                          const SizedBox(width: 4),
                          Text(
                            'Estimated Time: ~${project.estimatedHours} Hours',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Tech Stack Chips
                const Text('Required Technology Stack', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: project.requiredTech.map((tech) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Text(tech, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Interactive Milestones Progress Checklist
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Interactive Milestones', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(
                      '$completedCount of $totalMilestones Completed ($progressPercent%)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: totalMilestones > 0 ? (completedCount / totalMilestones) : 0,
                    minHeight: 8,
                    backgroundColor: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                  ),
                ),
                const SizedBox(height: 12),

                ...project.milestones.map((m) {
                  final isDone = _completedMilestones.contains(m.milestoneId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isDone,
                            activeColor: AppColors.success,
                            onChanged: (_) => _toggleMilestone(m.milestoneId, isDone),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  m.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // GitHub Repository & Live Demo Deployment URLs
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Project Delivery Links',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Store your GitHub repository and live deployment URL for reviews and resumes.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _githubController,
                        label: 'GitHub Repository URL',
                        hint: 'https://github.com/username/project',
                        prefixIcon: const Icon(Icons.code_rounded, size: 20),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _demoController,
                        label: 'Live Demo URL',
                        hint: 'https://myproject.web.app',
                        prefixIcon: const Icon(Icons.link_rounded, size: 20),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppButton(
                          text: 'Save Project Links',
                          isLoading: _isSaving,
                          height: 38,
                          onPressed: _saveLinks,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Step-by-Step Implementation Guide
                const Text('Step-by-Step Implementation Plan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ...project.stepByStepPlan.map((step) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${step.stepNumber}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  step.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Verified Resume Bullets Generator Section
                AppCard(
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F3FF),
                  border: Border.all(
                    color: isDark ? const Color(0xFF6366F1).withOpacity(0.3) : const Color(0xFFDDD6FE),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Verified Resume Bullet Points',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          AppButton(
                            text: 'Generate',
                            height: 32,
                            isLoading: _isGeneratingBullets,
                            icon: Icons.auto_awesome_rounded,
                            onPressed: _generateResumeBullets,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Accurately derived from your completed milestones and technologies. Never hallucinates false metrics.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF4C1D95),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_resumeBullets.isEmpty)
                        Text(
                          'Click "Generate" to create resume bullets tailored to your milestone achievements.',
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                        )
                      else
                        ..._resumeBullets.map((bullet) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                                Expanded(
                                  child: SelectableText(
                                    bullet,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: bullet));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Resume bullet copied to clipboard!')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
