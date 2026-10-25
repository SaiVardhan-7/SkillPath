import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;
  String _selectedRole = 'Software Development Engineer';
  String _selectedSkillLevel = 'Beginner';
  int _dailyStudyMinutes = 60;
  final Set<String> _selectedGoals = {
    'Crack technical coding interviews',
    'Build production-ready portfolio projects',
  };
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roleOptions = [
    {
      'title': 'Software Development Engineer',
      'subtitle': 'Full DSA curriculum, Core CS (OS, DBMS, Networks), system design, and coding rounds.',
      'icon': Icons.terminal_rounded,
    },
    {
      'title': 'Flutter Developer',
      'subtitle': 'Dart null-safety, widget architectures, Riverpod state management, and app releases.',
      'icon': Icons.flutter_dash_rounded,
    },
    {
      'title': 'Frontend Developer',
      'subtitle': 'Modern JavaScript, TypeScript, React, Next.js, and responsive design systems.',
      'icon': Icons.web_rounded,
    },
    {
      'title': 'Backend Developer',
      'subtitle': 'Node.js/Go, databases, microservices, distributed caching, and REST/gRPC APIs.',
      'icon': Icons.dns_rounded,
    },
    {
      'title': 'Full-Stack Developer',
      'subtitle': 'End-to-end web & mobile engineering with full-stack deployments.',
      'icon': Icons.layers_rounded,
    },
  ];

  final List<String> _goalOptions = [
    'Crack technical coding interviews',
    'Master Data Structures & Algorithms',
    'Build production-ready portfolio projects',
    'Strengthen core Computer Science foundations',
    'Land an internship or full-time tech role',
    'Prepare for behavioral and STAR interview rounds',
  ];

  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    final success = await ref.read(authNotifierProvider.notifier).updateProfile(
          targetRole: _selectedRole,
          currentSkillLevel: _selectedSkillLevel,
          dailyStudyTimeMinutes: _dailyStudyMinutes,
          learningGoals: _selectedGoals.toList(),
          isOnboarded: true,
        );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        context.go('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save career goals. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Roadmap Setup'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: _buildCurrentStep(isDark),
              ),
            ),

            // Bottom Navigation Controls
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: AppButton(
                text: _currentStep == 3 ? 'Generate My Career Roadmap' : 'Continue',
                width: double.infinity,
                isLoading: _isLoading,
                icon: _currentStep == 3 ? Icons.auto_awesome_rounded : Icons.arrow_forward_rounded,
                onPressed: () {
                  if (_currentStep < 3) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    _completeOnboarding();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildRoleStep(isDark);
      case 1:
        return _buildSkillStep(isDark);
      case 2:
        return _buildCommitmentStep(isDark);
      case 3:
      default:
        return _buildGoalsStep(isDark);
    }
  }

  Widget _buildRoleStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your target role',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'We will customize your curriculum, project recommendations, and interview topics.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 20),
        ..._roleOptions.map((role) {
          final isSelected = _selectedRole == role['title'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: () {
                setState(() {
                  _selectedRole = role['title'];
                });
              },
              backgroundColor: isSelected
                  ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF))
                  : null,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: isSelected ? 2 : 1,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      role['icon'] as IconData,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role['title'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSkillStep(bool isDark) {
    final levels = [
      {
        'title': 'Beginner',
        'subtitle': 'New to coding or switching fields. Want strong step-by-step fundamentals.',
        'icon': Icons.spa_rounded,
      },
      {
        'title': 'Intermediate',
        'subtitle': 'Familiar with basic syntax and projects. Ready for DSA problem-solving and clean code.',
        'icon': Icons.bolt_rounded,
      },
      {
        'title': 'Advanced',
        'subtitle': 'Experienced coder. Focus on mock interviews, complex system design, and competitive coding.',
        'icon': Icons.military_tech_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your current skill level?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This helps calibrate topic prerequisites and starting suggestions.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 24),
        ...levels.map((lvl) {
          final isSelected = _selectedSkillLevel == lvl['title'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: AppCard(
              onTap: () {
                setState(() {
                  _selectedSkillLevel = lvl['title'] as String;
                });
              },
              backgroundColor: isSelected
                  ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF))
                  : null,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: isSelected ? 2 : 1,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtleLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      lvl['icon'] as IconData,
                      color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lvl['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lvl['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCommitmentStep(bool isDark) {
    final studyOptions = [30, 45, 60, 90, 120, 180];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily study commitment',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Consistent daily practice is the key factor in cracking coding interviews.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Text(
                '$_dailyStudyMinutes',
                style: const TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
              const Text(
                'minutes per day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: studyOptions.map((mins) {
            final isSelected = _dailyStudyMinutes == mins;
            return ChoiceChip(
              label: Text('$mins min'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _dailyStudyMinutes = mins;
                  });
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGoalsStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary learning goals',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select everything you want SkillPath to help you achieve.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 20),
        ..._goalOptions.map((goal) {
          final isSelected = _selectedGoals.contains(goal);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_selectedGoals.length > 1) {
                      _selectedGoals.remove(goal);
                    }
                  } else {
                    _selectedGoals.add(goal);
                  }
                });
              },
              backgroundColor: isSelected
                  ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF))
                  : null,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: isSelected ? 1.5 : 1,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                    color: isSelected ? AppColors.primary : AppColors.textTertiaryLight,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
