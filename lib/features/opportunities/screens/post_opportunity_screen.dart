import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/opportunity.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/tag_chip.dart';
import '../../../core/constants/app_colors.dart';

class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillController = TextEditingController();
  final List<String> _skills = ['Python', 'React'];
  bool _loading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  Future<void> _postOpportunity() async {
    setState(() => _loading = true);
    try {
      final opp = Opportunity(
        id: '',
        startupId: 'demoStartup123',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        skillsRequired: _skills,
        duration: '3 Months',
        location: 'Remote',
        deadline: DateTime.now().add(const Duration(days: 30)),
        status: 'open',
        companyName: 'VentureTech Labs',
      );
      await FirebaseFirestore.instance
          .collection('opportunities')
          .add(opp.toMap());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity posted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 1,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Post a New Opportunity',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find the next generation of talent for your startup ecosystem.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _StepIndicator(currentStep: _currentStep),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Role Title'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Backend Engineering Intern',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SectionLabel('Description'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        onChanged: (_) => setState(() {}),
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText:
                              'Describe the day-to-day responsibilities, culture, and what a candidate can expect to learn...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SectionLabel('Required Skills'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _skills
                            .map(
                              (s) => TagChip(
                                s,
                                onRemove: () =>
                                    setState(() => _skills.remove(s)),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _skillController,
                              decoration: const InputDecoration(
                                hintText: 'Type a skill and press Enter',
                              ),
                              onSubmitted: (_) => _addSkill(),
                            ),
                          ),
                          IconButton(
                            onPressed: _addSkill,
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(Icons.add, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPeach,
                            foregroundColor: AppColors.textOnPeach,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: _loading
                              ? null
                              : () {
                                  if (_currentStep < 2) {
                                    setState(() => _currentStep++);
                                  } else {
                                    _postOpportunity();
                                  }
                                },
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Continue'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Live Preview',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'CANDIDATE VIEW',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.cardGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.business, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _titleController.text.isEmpty
                                      ? 'Backend Intern'
                                      : _titleController.text,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Text(
                                  'VentureTech Labs • Remote',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        _descriptionController.text.isEmpty
                            ? 'Your description will appear here as you type. Ensure you highlight the key impact areas of the role to attract the best...'
                            : _descriptionController.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Wrap(
                        spacing: 8,
                        children: [
                          TagChip('3 Months'),
                          TagChip('Equity Eligible'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: AppColors.accentPeach, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Premium Placement — Startups with complete profiles get 40% more applications.',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = ['Role Details', 'Logistics', 'Media & Post'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final leftStep = (i - 1) ~/ 2;
            final lineActive = leftStep < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: lineActive ? AppColors.accentPeach : AppColors.border,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive = stepIndex <= currentStep;
          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accentPeach : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      color: isActive ? AppColors.textOnPeach : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: stepIndex == currentStep
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: stepIndex == currentStep
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
