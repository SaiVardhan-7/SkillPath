import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showEditProfileDialog() {
    final user = ref.read(authNotifierProvider).user;
    final nameController = TextEditingController(text: user?.name ?? '');
    String selectedRole = user?.targetRole ?? 'Software Development Engineer';
    String selectedSkill = user?.currentSkillLevel ?? 'Beginner';
    int dailyMinutes = user?.dailyStudyTimeMinutes ?? 60;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Edit Career Profile', style: TextStyle(fontWeight: FontWeight.w800)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(controller: nameController, label: 'Full Name'),
                    const SizedBox(height: 12),
                    const Text('Target Career Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      isExpanded: true,
                      items: AppConstants.careerRoles.map((r) {
                        return DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedRole = val!),
                    ),
                    const SizedBox(height: 12),
                    const Text('Current Skill Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: selectedSkill,
                      isExpanded: true,
                      items: AppConstants.skillLevels.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedSkill = val!),
                    ),
                    const SizedBox(height: 12),
                    Text('Daily Study Goal: $dailyMinutes min', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Slider(
                      value: dailyMinutes.toDouble(),
                      min: 15,
                      max: 240,
                      divisions: 15,
                      label: '$dailyMinutes min',
                      activeColor: AppColors.primary,
                      onChanged: (val) => setDialogState(() => dailyMinutes = val.toInt()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                AppButton(
                  text: 'Save',
                  height: 38,
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).updateProfile(
                          name: nameController.text.trim(),
                          targetRole: selectedRole,
                          currentSkillLevel: selectedSkill,
                          dailyStudyTimeMinutes: dailyMinutes,
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully!')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of SkillPath? Your progress is securely saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
              if (mounted) {
                context.go('/welcome');
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authNotifierProvider).user;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // User Profile Card
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Developer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                user?.targetRole ?? 'Software Engineer',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                        tooltip: 'Edit Profile',
                        onPressed: _showEditProfileDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat('Skill Level', user?.currentSkillLevel ?? 'Beginner'),
                      Container(width: 1, height: 24, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      _buildProfileStat('Daily Goal', '${user?.dailyStudyTimeMinutes ?? 60}m'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings & Tools Card
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.psychology_rounded, color: AppColors.primary),
                    title: const Text('Interview & Resume Prep', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Practice QA and review interview readiness', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go('/interview'),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Icon(
                      themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppColors.secondary,
                    ),
                    title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(themeMode == ThemeMode.dark ? 'Enabled' : 'Disabled', style: const TextStyle(fontSize: 12)),
                    value: themeMode == ThemeMode.dark,
                    onChanged: (_) {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.tune_rounded, color: AppColors.success),
                    title: const Text('Career Goals & Roles', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Adjust target career and learning commitments', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showEditProfileDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About & Help
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondaryLight),
                    title: const Text('About SkillPath', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('v1.0.0 • Production Ready', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Sign Out Button
            AppButton(
              text: 'Sign Out',
              type: AppButtonType.outline,
              width: double.infinity,
              icon: Icons.logout_rounded,
              onPressed: _confirmLogout,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
