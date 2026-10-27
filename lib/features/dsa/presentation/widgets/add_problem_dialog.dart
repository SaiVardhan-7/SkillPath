import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../providers/dsa_provider.dart';

class AddProblemDialog extends ConsumerStatefulWidget {
  final VoidCallback onProblemAdded;

  const AddProblemDialog({super.key, required this.onProblemAdded});

  @override
  ConsumerState<AddProblemDialog> createState() => _AddProblemDialogState();
}

class _AddProblemDialogState extends ConsumerState<AddProblemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();
  final _mistakesController = TextEditingController();

  String _selectedPlatform = 'LeetCode';
  String _selectedTopic = 'Arrays';
  String _selectedDifficulty = 'Easy';
  String _status = 'solved';
  final int _revisionDays = 3;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    _mistakesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = ref.read(dsaRepositoryProvider);
      await repo.addProblem(
        title: _titleController.text.trim(),
        url: _urlController.text.trim(),
        platform: _selectedPlatform,
        topic: _selectedTopic,
        difficulty: _selectedDifficulty,
        status: _status,
        notes: _notesController.text.trim(),
        mistakes: _mistakesController.text.trim(),
        revisionIntervalDays: _revisionDays,
      );

      widget.onProblemAdded();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Problem tracked successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Track Coding Problem',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _titleController,
                    label: 'Problem Title',
                    hint: 'e.g. Subarray Sum Equals K',
                    validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 12),

                  AppTextField(
                    controller: _urlController,
                    label: 'Problem URL',
                    hint: 'https://leetcode.com/problems/...',
                    keyboardType: TextInputType.url,
                    validator: (v) => v == null || v.isEmpty ? 'URL is required' : null,
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      // Platform Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Platform', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedPlatform,
                              isExpanded: true,
                              items: AppConstants.platforms.map((p) {
                                return DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedPlatform = val!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Difficulty Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Difficulty', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDifficulty,
                              isExpanded: true,
                              items: AppConstants.difficulties.map((d) {
                                return DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedDifficulty = val!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Topic dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Topic Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTopic,
                        isExpanded: true,
                        items: AppConstants.dsaCategories.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedTopic = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Status toggle
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Solved')),
                          selected: _status == 'solved',
                          selectedColor: AppColors.success,
                          labelStyle: TextStyle(
                            color: _status == 'solved' ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => setState(() => _status = 'solved'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Attempted')),
                          selected: _status == 'attempted',
                          selectedColor: AppColors.warning,
                          labelStyle: TextStyle(
                            color: _status == 'attempted' ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => setState(() => _status = 'attempted'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _notesController,
                    label: 'Approach & Solution Notes',
                    hint: 'Key intuition, data structure, time complexity...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  AppTextField(
                    controller: _mistakesController,
                    label: 'Mistakes & Observations',
                    hint: 'Edge cases missed, off-by-one errors...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  AppButton(
                    text: 'Save Problem',
                    width: double.infinity,
                    isLoading: _isLoading,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
